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
    .barHeight(68)
    .backgroundColor('#FFFFFF')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  @Builder
  private renderTabBar(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(14)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentIndex === index ? '#111111' : '#8A8F99')
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  private async initializeDataFoundation(): Promise<void> {
    try {
      const currentContext = getContext(this);
      await initializeAppBootstrap(currentContext.filesDir);
    } catch (_) {
    }
  }
}
