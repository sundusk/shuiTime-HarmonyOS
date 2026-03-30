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
      this.persist({
        schemaVersion: CURRENT_SCHEMA_VERSION,
        updatedAt: Date.now(),
        items: []
      });
    }
  }

  async load(): Promise<TimelineStoreData> {
    const raw = this.fileStorage.readText(this.storagePaths.itemStorePath);
    if (!raw) {
      const emptyStore: TimelineStoreData = {
        schemaVersion: CURRENT_SCHEMA_VERSION,
        updatedAt: Date.now(),
        items: []
      } as TimelineStoreData;
      this.persist(emptyStore);
      return emptyStore;
    }

    const parsed = JSON.parse(raw) as TimelineStoreData;
    return {
      schemaVersion: parsed.schemaVersion ?? CURRENT_SCHEMA_VERSION,
      updatedAt: parsed.updatedAt ?? Date.now(),
      items: Array.isArray(parsed.items) ? parsed.items : []
    };
  }

  async saveItems(items: TimelineItemEntity[]): Promise<void> {
    this.persist({
      schemaVersion: CURRENT_SCHEMA_VERSION,
      updatedAt: Date.now(),
      items
    });
  }

  private persist(data: TimelineStoreData): void {
    this.fileStorage.writeText(this.storagePaths.itemStorePath, JSON.stringify(data, null, 2));
  }
}
