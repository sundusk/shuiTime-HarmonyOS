import { TimelineItemEntity, TimelineItemType } from '../model/TimelineItemEntity';

export interface TimelineRepository {
  listAll(): Promise<TimelineItemEntity[]>;
  listByDate(dayStart: number, dayEnd: number): Promise<TimelineItemEntity[]>;
  listByType(type: TimelineItemType): Promise<TimelineItemEntity[]>;
  search(keyword: string, scope?: TimelineItemType | 'all'): Promise<TimelineItemEntity[]>;
  getById(id: string): Promise<TimelineItemEntity | undefined>;
  create(item: TimelineItemEntity): Promise<TimelineItemEntity>;
  update(item: TimelineItemEntity): Promise<TimelineItemEntity>;
  remove(id: string): Promise<void>;
  removeAll(): Promise<void>;
  countByType(type: TimelineItemType): Promise<number>;
}
