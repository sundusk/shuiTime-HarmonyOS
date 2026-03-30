export type TimelineItemType = 'timeline' | 'inspiration' | 'moment';

export interface TimelineItemEntity {
  id: string;
  timestamp: number;
  content: string;
  iconName: string;
  type: TimelineItemType;
  imagePath?: string;
  isLivePhoto: boolean;
  livePhotoVideoPath?: string;
  borderColorHex?: string;
}

export interface TimelineStoreData {
  schemaVersion: number;
  updatedAt: number;
  items: TimelineItemEntity[];
}
