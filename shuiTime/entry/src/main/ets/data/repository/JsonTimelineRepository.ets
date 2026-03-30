import { DEFAULT_ICON_NAME } from '../../common/constants/AppConstants';
import { extractTags } from '../../common/utils/TagUtils';
import { TimelineItemEntity, TimelineItemType } from '../model/TimelineItemEntity';
import { TimelineRepository } from './TimelineRepository';
import { JsonStore } from '../storage/JsonStore';
export class JsonTimelineRepository implements TimelineRepository {
  private readonly store: JsonStore

  constructor(store: JsonStore) {
    this.store = store;
  }

  async listAll(): Promise<TimelineItemEntity[]> {
    return this.sortByTimestampDesc((await this.store.load()).items);
  }

  async listByDate(dayStart: number, dayEnd: number): Promise<TimelineItemEntity[]> {
    const items = await this.listAll();
    return items.filter((item: TimelineItemEntity) => item.timestamp >= dayStart && item.timestamp <= dayEnd);
  }

  async listByType(type: TimelineItemType): Promise<TimelineItemEntity[]> {
    const items = await this.listAll();
    return items.filter((item: TimelineItemEntity) => item.type === type);
  }

  async search(keyword: string, scope: TimelineItemType | 'all' = 'all'): Promise<TimelineItemEntity[]> {
    const items = await this.listAll();
    const normalizedKeyword = keyword.trim().toLowerCase();

    return items.filter((item: TimelineItemEntity) => {
      if (scope !== 'all' && item.type !== scope) {
        return false;
      }

      if (!normalizedKeyword) {
        return true;
      }

      const tagMatches = extractTags(item.content).some((tag: string) => tag.toLowerCase().includes(normalizedKeyword));
      return item.content.toLowerCase().includes(normalizedKeyword)
        || item.type.toLowerCase().includes(normalizedKeyword)
        || (item.iconName ?? '').toLowerCase().includes(normalizedKeyword)
        || tagMatches;
    });
  }

  async getById(id: string): Promise<TimelineItemEntity | undefined> {
    return (await this.listAll()).find((item: TimelineItemEntity) => item.id === id);
  }

  async create(item: TimelineItemEntity): Promise<TimelineItemEntity> {
    const items = (await this.store.load()).items;
    const normalizedItem = this.normalizeItem(item);
    items.push(normalizedItem);
    await this.store.saveItems(this.sortByTimestampDesc(items));
    return normalizedItem;
  }

  async update(item: TimelineItemEntity): Promise<TimelineItemEntity> {
    const items = (await this.store.load()).items;
    const index = items.findIndex((current: TimelineItemEntity) => current.id === item.id);
    if (index < 0) {
      throw new Error(`Timeline item not found: ${item.id}`);
    }
    items[index] = this.normalizeItem(item);
    await this.store.saveItems(this.sortByTimestampDesc(items));
    return items[index];
  }

  async remove(id: string): Promise<void> {
    const items = (await this.store.load()).items.filter((item: TimelineItemEntity) => item.id !== id);
    await this.store.saveItems(this.sortByTimestampDesc(items));
  }

  async removeAll(): Promise<void> {
    await this.store.saveItems([]);
  }

  async countByType(type: TimelineItemType): Promise<number> {
    return (await this.listByType(type)).length;
  }
  private sortByTimestampDesc(items: TimelineItemEntity[]): TimelineItemEntity[] {
    const sortedItems = items.slice();
    return sortedItems.sort((left: TimelineItemEntity, right: TimelineItemEntity) => right.timestamp - left.timestamp);
  }

  private normalizeItem(item: TimelineItemEntity): TimelineItemEntity {
    const normalizedItem: TimelineItemEntity = {
      id: item.id,
      timestamp: item.timestamp,
      content: item.content,
      iconName: item.iconName || DEFAULT_ICON_NAME,
      type: item.type,
      isLivePhoto: item.isLivePhoto ?? false
    };

    if (item.imagePath) {
      normalizedItem.imagePath = item.imagePath;
    }
    if (item.livePhotoVideoPath) {
      normalizedItem.livePhotoVideoPath = item.livePhotoVideoPath;
    }
    if (item.borderColorHex) {
      normalizedItem.borderColorHex = item.borderColorHex;
    }

    return normalizedItem;
  }
}
