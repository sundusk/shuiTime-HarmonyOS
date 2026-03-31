import { initializeAppBootstrap } from '../app/AppBootstrap';
import { InspirationPlaceholderPage } from '../features/inspiration/InspirationPlaceholderPage';
import { LookbackPlaceholderPage } from '../features/lookback/LookbackPlaceholderPage';
import { TimelinePlaceholderPage } from '../features/timeline/TimelinePlaceholderPage';

@Entry
@Component
struct Index {
  @State private currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  private readonly tabTitles: string[] = ['时间线', '瞬息', '回顾'];

  aboutToAppear(): void {
    this.initializeDataFoundation();
  }

  build() {
    Stack() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          TimelinePlaceholderPage()
        }
        .tabBar(this.renderTabBar('时间线', 0))

        TabContent() {
          InspirationPlaceholderPage()
        }
        .tabBar(this.renderTabBar('瞬息', 1))

        TabContent() {
          LookbackPlaceholderPage()
        }
        .tabBar(this.renderTabBar('回顾', 2))
      }
      .vertical(false)
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .barHeight(0)
      .backgroundColor('#F8FAFD')
      .padding({ bottom: 108 })
      .onChange((index: number) => {
        this.currentIndex = index;
      })

      Column() {
        Blank()
          .layoutWeight(1);

        this.buildFloatingTabBar();
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFD')
  }

  @Builder
  private renderTabBar(title: string, index: number) {
    Column({ space: 4 }) {
      this.buildTabIcon(index);

      Text(title)
        .fontSize(13)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? '#4A90E2' : '#1F2430')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('76%')
    .height(52)
    .backgroundColor(this.currentIndex === index ? '#EEF4FF' : '#F8FAFD')
    .borderRadius(26)
    .padding({ top: 6, bottom: 6 })
  }

  @Builder
  private buildFloatingTabBar() {
    Row() {
      ForEach(this.tabTitles, (title: string, index: number) => {
        this.buildFloatingTabItem(title, index);
      }, (title: string) => title)
    }
    .width('68%')
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .margin({ bottom: 16 })
    .backgroundColor('#FFFFFFF7')
    .borderRadius(24)
    .shadow({
      radius: 20,
      color: '#14000000',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder
  private buildFloatingTabItem(title: string, index: number) {
    Column({ space: 6 }) {
      this.buildTabIcon(index);

      Text(title)
        .fontSize(10)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? '#3F7DFF' : '#1F2430');
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('31%')
    .height(36)
    .backgroundColor(this.currentIndex === index ? '#ECEDEF' : '#00FFFFFF')
    .borderRadius(18)
    .onClick(() => {
      if (this.currentIndex === index) {
        return;
      }
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  @Builder
  private buildTabIcon(index: number) {
    Stack() {
      if (index === 0) {
        // 时间线图标 - 列表样式
        Column({ space: 3 }) {
          Row() {}
            .width(16)
            .height(2.5)
            .borderRadius(1.5)
            .backgroundColor(this.currentIndex === index ? '#3F7DFF' : '#1F2430');
          Row() {}
            .width(16)
            .height(2.5)
            .borderRadius(1.5)
            .backgroundColor(this.currentIndex === index ? '#3F7DFF' : '#1F2430');
          Row() {}
            .width(16)
            .height(2.5)
            .borderRadius(1.5)
            .backgroundColor(this.currentIndex === index ? '#3F7DFF' : '#1F2430');
        }
      } else if (index === 1) {
        // 瞬息图标 - 应用/卡片样式
        Column({ space: 2 }) {
          Circle()
            .width(4)
            .height(4)
            .fill(this.currentIndex === index ? '#3F7DFF' : '#1F2430')
            .margin({ left: 7 });

          Row() {}
            .width(16)
            .height(12)
            .border({
              width: 2,
              color: this.currentIndex === index ? '#3F7DFF' : '#1F2430',
              radius: 3
            })
            .backgroundColor('#00FFFFFF')
        }
      } else {
        // 回顾图标 - 时钟样式
        Stack() {
          Circle()
            .width(14)
            .height(14)
            .stroke(this.currentIndex === index ? '#3F7DFF' : '#1F2430')
            .strokeWidth(2);
          Row() {}
            .width(1.5)
            .height(5)
            .backgroundColor(this.currentIndex === index ? '#3F7DFF' : '#1F2430')
            .margin({ top: 2 });
          Row() {}
            .width(4)
            .height(1.5)
            .backgroundColor(this.currentIndex === index ? '#3F7DFF' : '#1F2430')
            .margin({ left: 2 });
        }
        .width(16)
        .height(16)
      }
    }
    .width(20)
    .height(20)
  }

  private async initializeDataFoundation(): Promise<void> {
    try {
      const currentContext = getContext(this);
      await initializeAppBootstrap(currentContext.filesDir);
    } catch (_) {
    }
  }
}
