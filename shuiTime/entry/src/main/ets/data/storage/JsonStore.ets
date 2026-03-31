import { TimelineItemEntity, TimelineStoreData } from '../model/TimelineItemEntity';
import { FileStorage } from './FileStorage';
import { StoragePaths } from './StoragePaths';

const CURRENT_SCHEMA_VERSION: number = 1;
export class JsonStore {
  private readonly fileStorage: FileStorage
  private readonly storagePaths: StoragePaths

  constructor(fileStorage: FileStorage, storagePaths: StoragePaths) {
    this.fileStorage = fileStorage;
    this.storagePaths = storagePaths;
  }

  async initialize(): Promise<void> {
    this.fileStorage.ensureDir(this.storagePaths.dataRootDir);
    this.fileStorage.ensureDir(this.storagePaths.imageRootDir);
    this.fileStorage.ensureDir(this.storagePaths.videoRootDir);
    this.fileStorage.ensureDir(this.storagePaths.tempRootDir);

    if (!this.fileStorage.exists(this.storagePaths.itemStorePath)) {
      this.persistStore(this.createEmptyStoreData());
    }
  }

  async load(): Promise<TimelineStoreData> {
    console.log('JsonStore.load: 开始加载数据');
    if (!this.fileStorage.exists(this.storagePaths.itemStorePath)) {
      console.log('JsonStore.load: 没有数据文件，创建空存储');
      const emptyStore = this.createEmptyStoreData();
      this.persistStore(emptyStore);
      return emptyStore;
    }

    try {
      return this.loadFromPath(this.storagePaths.itemStorePath, '主存储');
    } catch (primaryError) {
      console.error('JsonStore.load: 主存储读取失败，尝试从备份恢复', primaryError);

      if (!this.fileStorage.exists(this.storagePaths.itemStoreBackupPath)) {
        throw new Error('主存储读取失败，且没有可用备份');
      }

      const backupStore = this.loadFromPath(this.storagePaths.itemStoreBackupPath, '备份存储');
      this.persistToPath(this.storagePaths.itemStorePath, backupStore);
      return backupStore;
    }
  }

  async saveItems(items: TimelineItemEntity[]): Promise<void> {
    console.log('JsonStore.saveItems: 保存', items.length, '条记录');
    if (items.length > 0) {
      console.log('第一条记录内容:', items[0].content);
    }
    const storeData: TimelineStoreData = {
      schemaVersion: CURRENT_SCHEMA_VERSION,
      updatedAt: Date.now(),
      items
    };
    this.persistStore(storeData);
    console.log('JsonStore.saveItems: 保存完成');
  }

  private createEmptyStoreData(): TimelineStoreData {
    return {
      schemaVersion: CURRENT_SCHEMA_VERSION,
      updatedAt: Date.now(),
      items: []
    };
  }

  private loadFromPath(path: string, label: string): TimelineStoreData {
    const raw = this.fileStorage.readText(path).trim();
    if (raw.length === 0) {
      throw new Error(`${label}为空文件: ${path}`);
    }

    const parsed = JSON.parse(raw) as TimelineStoreData;
    const normalized = {
      schemaVersion: parsed.schemaVersion ?? CURRENT_SCHEMA_VERSION,
      updatedAt: parsed.updatedAt ?? Date.now(),
      items: Array.isArray(parsed.items) ? parsed.items : []
    } as TimelineStoreData;

    console.log(`JsonStore.load: ${label}加载到`, normalized.items.length, '条记录');
    if (normalized.items.length > 0) {
      console.log(`JsonStore.load: ${label}第一条记录内容:`, normalized.items[0].content);
    }

    return normalized;
  }

  private persistStore(data: TimelineStoreData): void {
    this.persistToPath(this.storagePaths.itemStorePath, data);
    this.persistToPath(this.storagePaths.itemStoreBackupPath, data);
  }

  private persistToPath(path: string, data: TimelineStoreData): void {
    this.fileStorage.writeText(path, JSON.stringify(data, null, 2));
  }
}
