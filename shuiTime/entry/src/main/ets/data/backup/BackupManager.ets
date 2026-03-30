import { zlib } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import {
  BACKUP_FILE_PREFIX,
  BACKUP_FILE_VERSION,
  DEFAULT_ICON_NAME,
  IOS_BACKUP_JSON_FILE_NAME
} from '../../common/constants/AppConstants';
import { decodeBase64, encodeBase64 } from '../../common/utils/Base64Utils';
import { formatDisplayDate, parseIsoToTimestamp, toIsoString } from '../../common/utils/DateUtils';
import { generateId } from '../../common/utils/IdUtils';
import { BackupData, BackupItem, ImportResult } from '../model/BackupModels';
import { TimelineItemEntity, TimelineItemType } from '../model/TimelineItemEntity';
import { TimelineRepository } from '../repository/TimelineRepository';
import { FileStorage } from '../storage/FileStorage';
import { StoragePaths } from '../storage/StoragePaths';
export class BackupManager {
  private readonly repository: TimelineRepository
  private readonly fileStorage: FileStorage
  private readonly storagePaths: StoragePaths

  constructor(repository: TimelineRepository, fileStorage: FileStorage, storagePaths: StoragePaths) {
    this.repository = repository;
    this.fileStorage = fileStorage;
    this.storagePaths = storagePaths;
  }

  async importFromBackup(filePath: string, mode: 'merge' | 'overwrite'): Promise<ImportResult> {
    const backupData = await this.readBackupData(filePath);
    if (mode === 'overwrite') {
      await this.repository.removeAll();
    }

    const existingItems = await this.repository.listAll();
    const existingKeys = new Set<string>(
      existingItems.map((item: TimelineItemEntity) => this.buildDedupKey(item.content, item.timestamp, item.type))
    );

    let importedCount = 0;
    let skippedCount = 0;

    for (const backupItem of backupData.items) {
      const timestamp = parseIsoToTimestamp(backupItem.timestamp);
      if (timestamp <= 0) {
        skippedCount += 1;
        continue;
      }

      const type = this.normalizeType(backupItem.type);
      const dedupKey = this.buildDedupKey(backupItem.content, timestamp, type);
      if (mode === 'merge' && existingKeys.has(dedupKey)) {
        skippedCount += 1;
        continue;
      }

      const entity = await this.materializeBackupItem(backupItem, timestamp, type);
      await this.repository.create(entity);
      existingKeys.add(dedupKey);
      importedCount += 1;
    }

    return {
      importedCount,
      skippedCount,
      totalCount: backupData.items.length,
      mode
    };
  }

  async exportToBackupZip(): Promise<string> {
    const items = await this.repository.listAll();
    const backupData: BackupData = {
      version: BACKUP_FILE_VERSION,
      exportDate: toIsoString(Date.now()),
      items: items.map((item: TimelineItemEntity) => this.serializeItem(item))
    };

    this.fileStorage.ensureDir(this.storagePaths.tempRootDir);
    const timestamp = formatDisplayDate(Date.now()).replace(/-/g, '');
    const jsonPath = `${this.storagePaths.tempRootDir}/${IOS_BACKUP_JSON_FILE_NAME}`;
    const zipPath = `${this.storagePaths.tempRootDir}/${BACKUP_FILE_PREFIX}${timestamp}.zip`;
    this.fileStorage.writeText(jsonPath, JSON.stringify(backupData, null, 2));
    if (this.fileStorage.exists(zipPath)) {
      fs.unlinkSync(zipPath);
    }
    await zlib.compressFile(jsonPath, zipPath, {});
    return zipPath;
  }

  private async readBackupData(filePath: string): Promise<BackupData> {
    if (filePath.endsWith('.json')) {
      return JSON.parse(this.fileStorage.readText(filePath)) as BackupData;
    }

    if (filePath.endsWith('.zip')) {
      const extractionDir = `${this.storagePaths.tempRootDir}/import-${Date.now()}`;
      this.fileStorage.ensureDir(extractionDir);
      await zlib.decompressFile(filePath, extractionDir, {});
      const jsonCandidates = this.fileStorage.list(extractionDir).filter((name: string) => name.endsWith('.json'));
      if (jsonCandidates.length === 0) {
        throw new Error('Backup archive does not contain a JSON payload.');
      }
      const jsonPath = `${extractionDir}/${jsonCandidates[0]}`;
      return JSON.parse(this.fileStorage.readText(jsonPath)) as BackupData;
    }

    throw new Error(`Unsupported backup file: ${filePath}`);
  }

  private async materializeBackupItem(
    item: BackupItem,
    timestamp: number,
    type: TimelineItemType
  ): Promise<TimelineItemEntity> {
    const entityId = item.id || generateId();
    const imagePath = item.imageBase64
      ? this.persistMedia(`${entityId}-image.bin`, item.imageBase64, 'image')
      : undefined;
    const videoPath = item.livePhotoVideoBase64
      ? this.persistMedia(`${entityId}-live.bin`, item.livePhotoVideoBase64, 'video')
      : undefined;

    return {
      id: entityId,
      timestamp,
      content: item.content ?? '',
      iconName: item.iconName || DEFAULT_ICON_NAME,
      type,
      imagePath,
      isLivePhoto: item.isLivePhoto ?? false,
      livePhotoVideoPath: videoPath,
      borderColorHex: item.borderColorHex
    };
  }

  private serializeItem(item: TimelineItemEntity): BackupItem {
    const imageBase64 = item.imagePath ? encodeBase64(this.fileStorage.readBytes(item.imagePath)) : undefined;
    const livePhotoVideoBase64 = item.livePhotoVideoPath
      ? encodeBase64(this.fileStorage.readBytes(item.livePhotoVideoPath))
      : undefined;

    return {
      id: item.id,
      timestamp: toIsoString(item.timestamp),
      content: item.content,
      iconName: item.iconName,
      type: item.type,
      imageBase64,
      isLivePhoto: item.isLivePhoto,
      livePhotoVideoBase64,
      borderColorHex: item.borderColorHex
    };
  }

  private persistMedia(fileName: string, base64: string, kind: 'image' | 'video'): string {
    const dir = kind === 'image' ? this.storagePaths.imageRootDir : this.storagePaths.videoRootDir;
    const path = `${dir}/${fileName}`;
    this.fileStorage.writeBytes(path, decodeBase64(base64));
    return path;
  }

  private normalizeType(type: string): TimelineItemType {
    if (type === 'timeline' || type === 'inspiration' || type === 'moment') {
      return type;
    }
    return 'timeline';
  }

  private buildDedupKey(content: string, timestamp: number, type: string): string {
    return `${content}|${timestamp}|${type}`;
  }
}
