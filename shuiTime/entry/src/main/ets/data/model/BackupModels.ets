export interface BackupItem {
  id: string;
  timestamp: string;
  content: string;
  iconName: string;
  type: string;
  imageBase64?: string;
  isLivePhoto?: boolean;
  livePhotoVideoBase64?: string;
  borderColorHex?: string;
}

export interface BackupData {
  version: string;
  exportDate: string;
  items: BackupItem[];
}

export interface ImportResult {
  importedCount: number;
  skippedCount: number;
  totalCount: number;
  mode: 'merge' | 'overwrite';
}
