import { BackupManager } from '../data/backup/BackupManager';
import { JsonTimelineRepository } from '../data/repository/JsonTimelineRepository';
import { TimelineRepository } from '../data/repository/TimelineRepository';
import { FileStorage } from '../data/storage/FileStorage';
import { JsonStore } from '../data/storage/JsonStore';
import { StoragePaths } from '../data/storage/StoragePaths';

export interface BootstrapSnapshot {
  filesDir: string;
  storePath: string;
  totalCount: number;
  timelineCount: number;
  inspirationCount: number;
  momentCount: number;
  initializedAt: number;
}

let initialized: boolean = false;
let appFilesDir: string = '';
let fileStorageInstance: FileStorage | null = null;
let storagePathsInstance: StoragePaths | null = null;
let repositoryInstance: TimelineRepository | null = null;
let backupManagerInstance: BackupManager | null = null;
let bootstrapInitializedAt: number = 0;

export async function initializeAppBootstrap(filesDir: string): Promise<void> {
  if (initialized && appFilesDir === filesDir) {
    return;
  }

  appFilesDir = filesDir;
  fileStorageInstance = new FileStorage();
  storagePathsInstance = new StoragePaths(filesDir);
  const store = new JsonStore(fileStorageInstance, storagePathsInstance);
  await store.initialize();
  repositoryInstance = new JsonTimelineRepository(store);
  backupManagerInstance = new BackupManager(repositoryInstance, fileStorageInstance, storagePathsInstance);
  initialized = true;
  bootstrapInitializedAt = Date.now();
}

export function getTimelineRepository(): TimelineRepository {
  assertInitialized();
  return repositoryInstance as TimelineRepository;
}

export function getBackupManager(): BackupManager {
  assertInitialized();
  return backupManagerInstance as BackupManager;
}

export async function getBootstrapSnapshot(): Promise<BootstrapSnapshot> {
  assertInitialized();
  const repository = repositoryInstance as TimelineRepository;
  const storagePaths = storagePathsInstance as StoragePaths;

  return {
    filesDir: appFilesDir,
    storePath: storagePaths.itemStorePath,
    totalCount: (await repository.listAll()).length,
    timelineCount: await repository.countByType('timeline'),
    inspirationCount: await repository.countByType('inspiration'),
    momentCount: await repository.countByType('moment'),
    initializedAt: bootstrapInitializedAt
  };
}

function assertInitialized(): void {
  if (!initialized) {
    throw new Error('App bootstrap has not been initialized.');
  }
}
