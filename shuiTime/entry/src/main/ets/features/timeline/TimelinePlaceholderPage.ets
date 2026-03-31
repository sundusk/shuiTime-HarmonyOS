import { getTimelineRepository, initializeAppBootstrap } from '../../app/AppBootstrap';
import { getDayRange } from '../../common/utils/DateUtils';
import { generateId } from '../../common/utils/IdUtils';
import { TimelineItemEntity } from '../../data/model/TimelineItemEntity';

@Component
export struct TimelinePlaceholderPage {
  private readonly composerInputId: string = 'timeline-composer-input';

  @State private dayItems: TimelineItemEntity[] = [];
  @State private isLoading: boolean = true;
  @State private isComposerVisible: boolean = false;
  @State private draftContent: string = '';
  @State private isSaving: boolean = false;
  @State private composerFocused: boolean = false;

  aboutToAppear(): void {
    this.loadTodayItems();
  }

  build() {
    Stack() {
      this.buildBackgroundLayer();

      Column() {
        this.buildTopBar();

        if (this.isLoading) {
          Blank()
            .layoutWeight(1);

          Text('正在加载今日记录...')
            .fontSize(16)
            .fontColor('#8E95A3');

          Blank()
            .layoutWeight(1);
        } else if (this.dayItems.length === 0) {
          Blank()
            .layoutWeight(3);

          this.buildEmptyState();

          Blank()
            .layoutWeight(4);
        } else {
          this.buildTimelineList();
        }

        this.buildBottomBar();
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

      Row({ space: 6 }) {
        Text('今日')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#232833');

        Text('▼')
          .fontSize(9)
          .fontColor('#7F8796')
          .margin({ top: 4 });
      }

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

      Text('这一天没有记录')
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
  private buildTimelineList() {
    Scroll() {
      Column({ space: 14 }) {
        ForEach(this.dayItems, (item: TimelineItemEntity) => {
          this.buildTimelineCard(item);
        }, (item: TimelineItemEntity): string => item.id);
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 24 });
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off);
  }

  @Builder
  private buildTimelineCard(item: TimelineItemEntity) {
    Column({ space: 10 }) {
      Row() {
        Text(this.formatTypeLabel(item.type))
          .fontSize(12)
          .fontColor('#4A7DFF')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#EAF1FF')
          .borderRadius(12);

        Blank();

        Text(this.formatTime(item.timestamp))
          .fontSize(13)
          .fontColor('#9AA1AD');
      }
      .width('100%');

      Text(item.content && item.content.length > 0 ? item.content : '图片记录')
        .fontSize(17)
        .fontColor('#1F2430')
        .lineHeight(24)
        .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFFE8')
    .borderRadius(22);
  }

  @Builder
  private buildBottomBar() {
    Row() {
      if (this.isComposerVisible) {
        this.buildComposerBar();
      } else {
        Blank();
        // 悬浮球已移到全局，这里不再显示
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 20 })
    .zIndex(100);
  }

  @Builder
  private buildComposerBar() {
    Row({ space: 10 }) {
      this.buildComposerSideButton('想');
      this.buildComposerSideButton('图');

      TextInput({ placeholder: '记录此刻...', text: this.draftContent })
        .id(this.composerInputId)
        .type(InputType.Normal)
        .enterKeyType(EnterKeyType.Send)
        .focusable(true)
        .defaultFocus(this.composerFocused)
        .fontSize(16)
        .fontColor('#2A3040')
        .placeholderColor('#A0A6B4')
        .caretColor('#4A7DFF')
        .backgroundColor('#EEF1F7')
        .borderRadius(18)
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .layoutWeight(1)
        .onChange((value: string) => {
          this.draftContent = value;
        })
        .onSubmit((_enterKey: EnterKeyType) => {
          this.submitComposer();
        });

      this.buildComposerActionButton(this.canSubmitComposer() ? '发' : '收');
    }
    .width('100%')
    .padding({ left: 12, right: 10, top: 10, bottom: 10 })
    .backgroundColor('#FFFFFFF2')
    .borderRadius(24)
    .zIndex(100);
  }

  @Builder
  private buildComposerSideButton(label: string) {
    Stack() {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8C93A1');
    }
    .width(24)
    .height(24)
    .borderRadius(12)
    .backgroundColor('#F4F6FA');
  }

  @Builder
  private buildComposerActionButton(label: string) {
    Stack() {
      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.canSubmitComposer() ? '#4A7DFF' : '#8F97A6');
    }
    .width(28)
    .height(28)
    .borderRadius(14)
    .backgroundColor(this.canSubmitComposer() ? '#EAF1FF' : '#F3F5F8')
    .onClick(() => {
      if (this.canSubmitComposer()) {
        this.submitComposer();
        return;
      }
      this.closeComposer();
    });
  }

  private async loadTodayItems(): Promise<void> {
    this.isLoading = true;
    try {
      const currentContext = getContext(this);
      await initializeAppBootstrap(currentContext.filesDir);
      const range = getDayRange(Date.now());
      this.dayItems = await getTimelineRepository().listByDate(range.start, range.end);
    } catch (_) {
      this.dayItems = [];
    } finally {
      this.isLoading = false;
    }
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

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hour = `${date.getHours()}`.padStart(2, '0');
    const minute = `${date.getMinutes()}`.padStart(2, '0');
    return `${hour}:${minute}`;
  }

  public openComposer(): void {
    console.log('打开输入框，设置可见性为 true');
    this.isComposerVisible = true;
    this.composerFocused = true;
  }

  private closeComposer(): void {
    this.isComposerVisible = false;
    this.draftContent = '';
    this.composerFocused = false;
  }

  private canSubmitComposer(): boolean {
    return !this.isSaving && this.draftContent.trim().length > 0;
  }

  private async submitComposer(): Promise<void> {
    const content = this.draftContent.trim();
    if (this.isSaving || content.length === 0) {
      return;
    }

    this.isSaving = true;
    try {
      const createdItem = await getTimelineRepository().create({
        id: generateId(),
        timestamp: Date.now(),
        content,
        iconName: '',
        type: 'timeline',
        isLivePhoto: false
      });
      this.dayItems = [createdItem, ...this.dayItems];
      this.closeComposer();
    } finally {
      this.isSaving = false;
    }
  }
}