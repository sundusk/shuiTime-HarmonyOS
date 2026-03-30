import { initializeAppBootstrap } from '../app/AppBootstrap';
import { InspirationPlaceholderPage } from '../features/inspiration/InspirationPlaceholderPage';
import { LookbackPlaceholderPage } from '../features/lookback/LookbackPlaceholderPage';
import { TimelinePlaceholderPage } from '../features/timeline/TimelinePlaceholderPage';

@Entry
@Component
struct Index {
  @State private currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    this.initializeDataFoundation();
  }

  build() {
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
    .barHeight(86)
    .backgroundColor('#F8FAFD')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
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
  private buildTabIcon(index: number) {
    Stack() {
      if (index === 0) {
        // 时间线图标 - 列表样式
        Column({ space: 3 }) {
          Row() {}
            .width(16)
            .height(2.5)
            .borderRadius(1.5)
            .backgroundColor(this.currentIndex === index ? '#4A90E2' : '#1F2430');
          Row() {}
            .width(16)
            .height(2.5)
            .borderRadius(1.5)
            .backgroundColor(this.currentIndex === index ? '#4A90E2' : '#1F2430');
          Row() {}
            .width(16)
            .height(2.5)
            .borderRadius(1.5)
            .backgroundColor(this.currentIndex === index ? '#4A90E2' : '#1F2430');
        }
      } else if (index === 1) {
        // 瞬息图标 - 灯泡样式
        Stack() {
          Circle()
            .width(12)
            .height(12)
            .stroke(this.currentIndex === index ? '#4A90E2' : '#1F2430')
            .strokeWidth(2);
          Row() {}
            .width(4)
            .height(2)
            .backgroundColor(this.currentIndex === index ? '#4A90E2' : '#1F2430')
            .margin({ top: 10 });
        }
        .width(16)
        .height(16)
      } else {
        // 回顾图标 - 时钟样式
        Stack() {
          Circle()
            .width(14)
            .height(14)
            .stroke(this.currentIndex === index ? '#4A90E2' : '#1F2430')
            .strokeWidth(2);
          Row() {}
            .width(1.5)
            .height(5)
            .backgroundColor(this.currentIndex === index ? '#4A90E2' : '#1F2430')
            .margin({ top: 2 });
          Row() {}
            .width(4)
            .height(1.5)
            .backgroundColor(this.currentIndex === index ? '#4A90E2' : '#1F2430')
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
