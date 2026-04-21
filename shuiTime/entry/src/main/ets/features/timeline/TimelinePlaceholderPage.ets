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
      const loadedItems = await getTimelineRepository().listByDate(this.getTodayStart(), this.getTodayEnd());
      
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
        } else if (this.getTodayItems(this.items).length === 0) {
          Blank()
            .layoutWeight(3);

          this.buildEmptyState();

          Blank()
            .layoutWeight(4);
        } else {
          this.buildTimelineList(this.getTodayItems(this.items));
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
        .backgroundColor($r('app.color.app_background_base'));
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  private buildTopBar() {
    Row() {
      this.buildCircleActionButton('menu');

      Text('今日')
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
    List({ space: 0 }) {
      ForEach(items, (item: TimelineItemEntity, index: number) => {
        ListItem() {
          this.buildTimelineListItem(items, item, index);
        }
        .id(item.id)
      }, (item: TimelineItemEntity) => item.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 18, top: 20, bottom: 16 })
    .scrollBar(BarState.Off);
  }

  @Builder
  private buildTimelineListItem(items: TimelineItemEntity[], item: TimelineItemEntity, index: number) {
    this.buildTimelineCard(
      item,
      index > 0,
      index < items.length - 1,
      this.getItemBottomSpacing(items, index)
    );
  }

  @Builder
  private buildTimelineCard(
    item: TimelineItemEntity,
    showTopLine: boolean,
    showBottomLine: boolean,
    bottomSpacing: number
  ) {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Text(this.formatTime(item.timestamp))
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#8D96A5')
          .lineHeight(18)
          .width('100%');

        Column() {
          Text(this.getDisplayContent(item))
            .fontSize(16)
            .fontColor('#1F2430')
            .lineHeight(23)
            .width('100%');
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .margin({ top: 8 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({
          radius: 12,
          color: '#12000000',
          offsetX: 0,
          offsetY: 6
        });
      }
      .width('100%')
      .padding({ left: 32 });

      if (showTopLine) {
        Row() {}
          .width(2)
          .height(4)
          .backgroundColor('#BFD4FF')
          .position({ x: 9, y: 0 });
      }
      Column() {
        this.buildTimelineNode()
      }
      .position({ x: 4, y: 4 });

      if (showBottomLine) {
        Row() {}
          .width(2)
          .height(this.getConnectorHeight(item, bottomSpacing))
          .backgroundColor('#BFD4FF')
          .position({ x: 9, y: 14 });
      }
    }
    .width('100%')
    .padding({ bottom: bottomSpacing });
  }
  @Builder
  private buildTimelineNode() {
    Circle()
      .width(10)
      .height(10)
      .fill('#3F8CFF')
      .stroke('#F5F8FF')
      .strokeWidth(2);
  }

  private getItemBottomSpacing(items: TimelineItemEntity[], index: number): number {
    return index === items.length - 1 ? 18 : 12;
  }

  private getConnectorHeight(item: TimelineItemEntity, bottomSpacing: number): number {
    const content = this.getDisplayContent(item);
    const estimatedLineCount = Math.max(1, Math.ceil(content.length / 14));
    const estimatedCardHeight = 28 + estimatedLineCount * 23;
    return estimatedCardHeight + bottomSpacing + 16;
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

  private getTodayItems(items: TimelineItemEntity[]): TimelineItemEntity[] {
    const todayStart = this.getTodayStart();
    const todayEnd = this.getTodayEnd();
    return items
      .filter((item: TimelineItemEntity) => item.timestamp >= todayStart && item.timestamp <= todayEnd)
      .sort((a: TimelineItemEntity, b: TimelineItemEntity) => b.timestamp - a.timestamp);
  }

  private getTodayStart(): number {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return today.getTime();
  }

  private getTodayEnd(): number {
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    return today.getTime();
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hour = `${date.getHours()}`.padStart(2, '0');
    const minute = `${date.getMinutes()}`.padStart(2, '0');
    return `${hour}:${minute}`;
  }
}
