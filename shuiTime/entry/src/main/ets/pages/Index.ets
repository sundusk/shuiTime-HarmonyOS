import { initializeAppBootstrap } from '../app/AppBootstrap';
import { InspirationPlaceholderPage } from '../features/inspiration/InspirationPlaceholderPage';
import { LookbackPlaceholderPage } from '../features/lookback/LookbackPlaceholderPage';
import { TimelinePlaceholderPage } from '../features/timeline/TimelinePlaceholderPage';
import { window } from '@kit.ArkUI'; // 导入 window 模块

@Entry
@Component
struct Index {
  @State private currentIndex: number = 0;
  @State private showComposer: boolean = false;
  @State private draftContent: string = '';
  @State private isKeyboardVisible: boolean = false; // 键盘可见状态
  private tabsController: TabsController = new TabsController();
  private readonly tabTitles: string[] = ['时间线', '瞬息', '回顾'];
  private readonly composerInputKey: string = 'global-composer-input';

  aboutToAppear(): void {
    this.initializeDataFoundation();
    this.setupKeyboardListener(); // 设置键盘监听
  }

  aboutToDisappear(): void {
    this.cleanupKeyboardListener(); // 清理监听
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
      .onChange((index: number) => {
        this.currentIndex = index;
        // 切换标签页时关闭输入框
        if (this.showComposer && index !== 0) {
          this.closeGlobalComposer();
        }
      })

      Column() {
        Blank()
          .layoutWeight(1);

        this.buildFloatingTabBar();
      }
      .width('100%')
      .height('100%')

      // 全局悬浮球
      this.buildGlobalFloatingActionButton();

      // 全局输入框（当在时间线页面时显示）
      if (this.showComposer && this.currentIndex === 0) {
        this.buildGlobalComposer();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFD')
  }

  @Builder
  private buildGlobalFloatingActionButton() {
    Column() {
      Blank()
        .layoutWeight(1);

      Row() {
        Blank();
        
        Stack() {
          Image($r('app.media.xiaoshui_core'))
            .width(68)
            .height(68)
            .objectFit(ImageFit.Cover)
            .clip(true);
        }
        .width(68)
        .height(68)
        .clip(true)
        .backgroundColor('#00FFFFFF')
        .zIndex(200)
        .hitTestBehavior(HitTestMode.Block)
        .enabled(true)
        .onClick(() => {
          console.log('全局悬浮球被点击了');
          if (this.currentIndex === 0) {
            this.openGlobalComposer();
          }
        });
      }
      .width('100%')
      .padding({ right: 20, bottom: 100 });
    }
    .width('100%')
    .height('100%')
    .zIndex(150)
  }

  @Builder
  private buildGlobalComposer() {
    Column() {
      Blank()
        .layoutWeight(1);

      Row({ space: 0 }) {
        this.buildComposerSideButton('想');
        this.buildComposerSideButton('图');

        TextInput({ placeholder: '记录此刻...', text: this.draftContent })
          .key(this.composerInputKey)
          .type(InputType.Normal)
          .enterKeyType(EnterKeyType.Send)
          .focusable(true)
          .defaultFocus(true)
          .fontSize(16)
          .fontColor('#2A3040')
          .placeholderColor('#A0A6B4')
          .caretColor('#4A7DFF')
          .backgroundColor('#EEF1F7')
          .borderRadius(0)
          .padding({ left: 14, right: 14, top: 16, bottom: 16 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.draftContent = value;
          })
          .onSubmit((_enterKey: EnterKeyType) => {
            this.submitGlobalComposer();
          })
          .onAppear(() => {
            // 输入框出现后立即请求焦点
            setTimeout(() => {
              console.log('输入框出现，请求焦点');
              try {
                this.getUIContext().getFocusController().requestFocus(this.composerInputKey);
              } catch (error) {
                console.error('请求焦点失败:', error);
              }
            }, 100);
          })
          .onBlur(() => {
            // 输入框失去焦点时触发
            console.log('输入框失去焦点');
            // 这里可以添加额外的逻辑，但主要依赖键盘高度监听
          });

        this.buildComposerActionButton(this.canSubmitComposer() ? '发' : '收');
      }
      .width('100%')
      .padding({ left: 0, right: 0, top: 0, bottom: 0 })
      .backgroundColor('#FFFFFF')
      .borderRadius(0)
      .margin({ bottom: 0 });
    }
    .width('100%')
    .height('100%')
    .zIndex(180)
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
        this.submitGlobalComposer();
        return;
      }
      this.closeGlobalComposer();
    });
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

  private setupKeyboardListener(): void {
    console.log('设置键盘监听器');
    window.getLastWindow(this.getUIContext().getHostContext()).then((currentWindow) => {
      currentWindow.on('keyboardHeightChange', (keyboardHeight: number) => {
        console.log('键盘高度变化:', keyboardHeight);
        
        if (keyboardHeight === 0) {
          // 键盘收起
          console.log('键盘收起，关闭输入框');
          this.isKeyboardVisible = false;
          this.closeGlobalComposer();
        } else {
          // 键盘弹出
          console.log('键盘弹出');
          this.isKeyboardVisible = true;
        }
      });
    }).catch((error: Error) => {
      console.error('设置键盘监听器失败:', error);
    });
  }

  private cleanupKeyboardListener(): void {
    console.log('清理键盘监听器');
    window.getLastWindow(this.getUIContext().getHostContext()).then((currentWindow) => {
      currentWindow.off('keyboardHeightChange');
    }).catch((error: Error) => {
      console.error('清理键盘监听器失败:', error);
    });
  }

  private openGlobalComposer(): void {
    console.log('打开全局输入框');
    this.showComposer = true;
  }

  private closeGlobalComposer(): void {
    console.log('关闭全局输入框');
    this.showComposer = false;
    this.draftContent = '';
  }

  private canSubmitComposer(): boolean {
    return this.draftContent.trim().length > 0;
  }

  private async submitGlobalComposer(): Promise<void> {
    const content = this.draftContent.trim();
    if (content.length === 0) {
      return;
    }

    console.log('提交内容:', content);
    // 这里可以添加保存内容的逻辑
    this.closeGlobalComposer();
  }

  private async initializeDataFoundation(): Promise<void> {
    try {
      const currentContext = getContext(this);
      await initializeAppBootstrap(currentContext.filesDir);
    } catch (_) {
    }
  }
}