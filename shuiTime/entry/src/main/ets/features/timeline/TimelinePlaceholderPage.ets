import { TimelineItemEntity } from '../../data/model/TimelineItemEntity';
import { getTimelineRepository, initializeAppBootstrap } from '../../app/AppBootstrap';

@Component
export struct TimelinePlaceholderPage {
  @Link items: TimelineItemEntity[];
  @Prop isLoading: boolean = true;

  aboutToAppear(): void {
    console.log('TimelinePlaceholderPage: aboutToAppear, items count:', this.items.length);
    if (this.items.length === 0) {
      this.loadTodayItems();
    }
  }

  aboutToUpdate(): void {
    console.log('TimelinePlaceholderPage: aboutToUpdate, 外部数据长度:', this.items.length, 'isLoading:', this.isLoading);
  }

  private async loadTodayItems(): Promise<void> {
    console.log('开始加载今日记录...');
    
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) {
        throw new Error('无法获取应用上下文');
      }
      await initializeAppBootstrap(context.filesDir);
      const loadedItems = await getTimelineRepository().listAll();
      
      loadedItems.sort((a: TimelineItemEntity, b: TimelineItemEntity) => b.timestamp - a.timestamp);
      
      console.log('加载到', loadedItems.length, '条记录');
      if (loadedItems.length > 0) {
        console.log('第一条记录内容:', loadedItems[0].content);
      }
      
      // 直接更新父组件数据源
      this.items = [...loadedItems];
      
    } catch (error) {
      console.error('加载时间线失败:', error);
      this.items = [];
    }
  }

  build() {
    Stack() {
      this.buildBackgroundLayer();

      Column() {
        this.buildTopBar();

        if (this.isLoading) {
          Blank()
            .layoutWeight(1);

          Text('正在加载时间线...')
            .fontSize(16)
            .fontColor('#8E95A3');

          Blank()
            .layoutWeight(1);
        } else if (this.items.length === 0) {
          Blank()
            .layoutWeight(3);

          this.buildEmptyState();

          Blank()
            .layoutWeight(4);
        } else {
          this.buildTimelineList(this.items);
        }
      }
      .width('100%')
      .height('100%')
      .padding({ top: 14, bottom: 4 });
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildBackgroundLayer() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F8FAFD');

      Circle()
        .width(220)
        .height(220)
        .fill('#EDF3FF')
        .opacity(0.9)
        .position({ x: 96, y: 86 });

      Circle()
        .width(220)
        .height(220)
        .fill('#F5F0FF')
        .opacity(0.9)
        .position({ x: 208, y: 690 });
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  private buildTopBar() {
    Row() {
      this.buildCircleActionButton('menu');

      Text('时间线')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#232833');

      this.buildCircleActionButton('search');
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 14, right: 14, top: 8, bottom: 4 });
  }

  @Builder
  private buildCircleActionButton(symbol: string) {
    Stack() {
      if (symbol === 'menu') {
        Column({ space: 4 }) {
          Row() {}
            .width(16)
            .height(2)
            .borderRadius(2)
            .backgroundColor('#60A6FF');
          Row() {}
            .width(16)
            .height(2)
            .borderRadius(2)
            .backgroundColor('#60A6FF');
          Row() {}
            .width(16)
            .height(2)
            .borderRadius(2)
            .backgroundColor('#60A6FF');
        }
      } else {
        Image($r('app.media.search_icon'))
          .width(30)
          .height(30)
          .objectFit(ImageFit.Contain);
      }
    }
    .width(50)
    .height(50)
    .backgroundColor('#FCFDFF')
    .borderRadius(25);
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 18 }) {
      this.buildEmptyIcon();

      Text('还没有任何记录')
        .fontSize(17)
        .fontColor('#B0B5BE');
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildEmptyIcon() {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        this.buildTinyDot();

        Column({ space: 7 }) {
          Row() {}
            .width(50)
            .height(8)
            .borderRadius(4)
            .backgroundColor('#BFD7FF');

          Row() {}
            .width(66)
            .height(8)
            .borderRadius(4)
            .backgroundColor('#BFD7FF');
        }
      }

      Row({ space: 10 }) {
        this.buildTinyDot();

        Row() {}
          .width(66)
          .height(8)
          .borderRadius(4)
          .backgroundColor('#BFD7FF');
      }

      Row({ space: 10 }) {
        this.buildTinyDot();

        Row() {}
          .width(52)
          .height(8)
          .borderRadius(4)
          .backgroundColor('#BFD7FF');
      }
    }
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .border({
      width: 4,
      color: '#7FB6FF',
      radius: 18
    })
    .backgroundColor('#F7FBFFEE')
    .borderRadius(18)
    .opacity(0.95);
  }

  @Builder
  private buildTinyDot() {
    Circle()
      .width(8)
      .height(8)
      .fill('#9FC5FF')
      .margin({ top: 1 });
  }

  @Builder
  private buildTimelineList(items: TimelineItemEntity[]) {
    List({ space: 20 }) {
      ForEach(items, (item: TimelineItemEntity, index: number) => {
        ListItem() {
          this.buildTimelineListItem(items, item, index);
        }
        .id(item.id) // 添加唯一ID帮助ForEach识别变化
      }, (item: TimelineItemEntity) => item.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 20, right: 20, top: 24, bottom: 24 })
    .scrollBar(BarState.Off);
  }

  @Builder
  private buildTimelineListItem(items: TimelineItemEntity[], item: TimelineItemEntity, index: number) {
    Column({ space: 12 }) {
      if (this.shouldShowDayHeader(items, index)) {
        Text(this.formatDayLabel(this.getDayKey(item.timestamp)))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#7F8796')
          .width('100%');
      }

      this.buildTimelineCard(item, this.isLastItemOfDay(items, index));
    }
    .width('100%');
  }

  @Builder
  private buildTimelineCard(item: TimelineItemEntity, isLast: boolean) {
    Row({ space: 12 }) {
      Column() {
        Row() {}
          .width(2)
          .height(14)
          .backgroundColor('#C9DAFF');

        this.buildTimelineNode(item.type);

        if (!isLast) {
          Row() {}
            .width(2)
            .height(54)
            .backgroundColor('#C9DAFF');
        } else {
          Blank()
            .height(18);
        }
      }
      .width(22)
      .alignItems(HorizontalAlign.Center);

      Column({ space: 10 }) {
        Row() {
          Text(this.formatTime(item.timestamp))
            .fontSize(13)
            .fontColor('#8D96A5');

          Blank();

          Text(this.formatTypeLabel(item.type))
            .fontSize(11)
            .fontColor(this.getTypeColor(item.type))
            .padding({ left: 9, right: 9, top: 4, bottom: 4 })
            .backgroundColor(this.getTypeBackgroundColor(item.type))
            .borderRadius(10);
        }
        .width('100%');

        Text(this.getDisplayContent(item))
          .fontSize(16)
          .fontColor('#1F2430')
          .lineHeight(23)
          .width('100%');
      }
      .layoutWeight(1)
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFFE8')
      .borderRadius(18)
      .shadow({
        radius: 12,
        color: '#12000000',
        offsetX: 0,
        offsetY: 6
      });
    }
    .width('100%')
    .alignItems(VerticalAlign.Top);
  }

  @Builder
  private buildTimelineNode(type: string) {
    if (type === 'moment') {
      Stack() {
        Circle()
          .width(18)
          .height(18)
          .fill('#EAF2FF');

        Circle()
          .width(18)
          .height(18)
          .stroke('#4A7DFF')
          .strokeWidth(1.5);

        Circle()
          .width(8)
          .height(8)
          .fill('#4A7DFF');
      }
      .margin({ top: 4, bottom: 4 });
    } else {
      Circle()
        .width(10)
        .height(10)
        .fill(type === 'inspiration' ? '#FFBF47' : '#4A7DFF')
        .stroke('#F8FAFD')
        .strokeWidth(2)
        .margin({ top: 4, bottom: 4 });
    }
  }

  private shouldShowDayHeader(items: TimelineItemEntity[], index: number): boolean {
    if (index === 0) {
      return true;
    }
    return this.getDayKey(items[index - 1].timestamp) !== this.getDayKey(items[index].timestamp);
  }

  private isLastItemOfDay(items: TimelineItemEntity[], index: number): boolean {
    if (index >= items.length - 1) {
      return true;
    }
    return this.getDayKey(items[index].timestamp) !== this.getDayKey(items[index + 1].timestamp);
  }

  private getDayKey(timestamp: number): string {
    const date = new Date(timestamp);
    const year = `${date.getFullYear()}`;
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private formatDayLabel(dayKey: string): string {
    const parts = dayKey.split('-');
    const year = parts[0];
    const month = parts[1];
    const day = parts[2];
    const date = new Date(Number(year), Number(month) - 1, Number(day));
    const weekday = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][date.getDay()];
    const todayKey = this.getDayKey(Date.now());

    if (dayKey === todayKey) {
      return '今日';
    }

    return `${year}年${month}月${day}日 ${weekday}`;
  }

  private formatTypeLabel(type: string): string {
    if (type === 'moment') {
      return '瞬影';
    }
    if (type === 'inspiration') {
      return '瞬息';
    }
    return '时间线';
  }

  private getTypeColor(type: string): string {
    if (type === 'moment') {
      return '#4A7DFF';
    }
    if (type === 'inspiration') {
      return '#C48912';
    }
    return '#4A7DFF';
  }

  private getTypeBackgroundColor(type: string): string {
    if (type === 'moment') {
      return '#EAF1FF';
    }
    if (type === 'inspiration') {
      return '#FFF4D9';
    }
    return '#EAF1FF';
  }

  private getDisplayContent(item: TimelineItemEntity): string {
    if (item.content && item.content.trim().length > 0) {
      return item.content;
    }
    if (item.type === 'moment') {
      return '图片记录';
    }
    return '空白记录';
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hour = `${date.getHours()}`.padStart(2, '0');
    const minute = `${date.getMinutes()}`.padStart(2, '0');
    return `${hour}:${minute}`;
  }
}