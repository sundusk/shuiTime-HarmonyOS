import { getTimelineRepository, initializeAppBootstrap } from '../app/AppBootstrap';
import { generateId } from '../common/utils/IdUtils';
import { TimelineItemEntity } from '../data/model/TimelineItemEntity';
import { InspirationPlaceholderPage } from '../features/inspiration/InspirationPlaceholderPage';
import { LookbackPlaceholderPage } from '../features/lookback/LookbackPlaceholderPage';
import { TimelinePlaceholderPage } from '../features/timeline/TimelinePlaceholderPage';
import { window } from '@kit.ArkUI'; // 导入 window 模块
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State private currentIndex: number = 0;
  @State private showComposer: boolean = false;
  @State private draftContent: string = '';
  @State private isKeyboardVisible: boolean = false; // 键盘可见状态
  @State private isSubmittingComposer: boolean = false;
  @State private timelineItems: TimelineItemEntity[] = [];
  @State private isTimelineLoading: boolean = true;
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
          Column() {
            TimelinePlaceholderPage({
              items: $timelineItems,
              isLoading: this.isTimelineLoading
            })
          }
          .width('100%')
          .height('100%')
          .onAppear(() => {
            console.log('时间线页面显示，当前索引:', this.currentIndex, '数据长度:', this.timelineItems.length);
            // 每次显示时间线页面时刷新数据
            if (this.currentIndex === 0) {
              this.loadTimelineItems();
            }
          })
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
        if (index === 0) {
          this.loadTimelineItems();
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
      if (!(this.showComposer && this.currentIndex === 0)) {
        this.buildGlobalFloatingActionButton();
      }

      // 全局输入框（当在时间线页面时显示）
      if (this.showComposer && this.currentIndex === 0) {
        this.buildComposerBackdrop();
        this.buildGlobalComposer();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFD')
  }

  @Builder
  private buildComposerBackdrop() {
    Column() {}
      .width('100%')
      .height('100%')
      .backgroundColor('#140C1B2A')
      .zIndex(170)
      .onClick(() => {
        this.closeGlobalComposer();
      });
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
            router.pushUrl({
              url: 'pages/TimelineComposePage'
            });
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

      Column() {
        Row({ space: 10 }) {
          Row({ space: 8 }) {
            this.buildComposerSideButton('想');
            this.buildComposerSideButton('图');
          }
          .padding({ left: 6, right: 6, top: 4, bottom: 4 })
          .backgroundColor('#F6F8FC')
          .borderRadius(0);

          Row({ space: 8 }) {
            Stack() {
              Circle()
                .width(8)
                .height(8)
                .fill('#6FA6FF');
            }
            .width(22)
            .height(22)
            .borderRadius(11)
            .backgroundColor('#E8F1FF');

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
              .backgroundColor('#00FFFFFF')
              .padding({ left: 0, right: 0, top: 8, bottom: 8 })
              .layoutWeight(1)
              .onChange((value: string) => {
                this.draftContent = value;
              })
              .onSubmit((_enterKey: EnterKeyType) => {
                this.submitGlobalComposer();
              })
              .onAppear(() => {
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
                console.log('输入框失去焦点');
              });
          }
          .layoutWeight(1)
          .padding({ left: 12, right: 6, top: 4, bottom: 4 })
          .backgroundColor('#F4F7FC')
          .borderRadius(0);

          this.buildComposerActionButton(this.canSubmitComposer() ? '发' : '收');
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);
      }
      .width('100%')
      .margin({ left: 14, right: 14, bottom: 20 })
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFFFA')
      .border({
        width: 1,
        color: '#E8EEF7',
        radius: 0
      })
      .borderRadius(0)
      .shadow({
        radius: 24,
        color: '#1F102030',
        offsetX: 0,
        offsetY: 12
      });
    }
    .width('100%')
    .height('100%')
    .zIndex(180)
  }

  @Builder
  private buildComposerSideButton(label: string) {
    Stack() {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(label === '想' ? '#4A7DFF' : '#8C93A1');
    }
    .width(34)
    .height(30)
    .borderRadius(0)
    .backgroundColor(label === '想' ? '#EAF2FF' : '#FFFFFF')
    .border({
      width: 1,
      color: label === '想' ? '#D6E6FF' : '#ECEFF4',
      radius: 0
    });
  }

  @Builder
  private buildComposerActionButton(label: string) {
    Stack() {
      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.canSubmitComposer() ? '#FFFFFF' : '#7E8795');
    }
    .width(44)
    .height(36)
    .borderRadius(0)
    .backgroundColor(this.canSubmitComposer() ? '#4A7DFF' : '#EEF2F7')
    .shadow({
      radius: this.canSubmitComposer() ? 16 : 8,
      color: this.canSubmitComposer() ? '#294A7DFF' : '#11000000',
      offsetX: 0,
      offsetY: this.canSubmitComposer() ? 8 : 4
    })
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
    const context = this.getUIContext().getHostContext();
    if (!context) {
      console.error('无法获取应用上下文');
      return;
    }
    window.getLastWindow(context).then((currentWindow) => {
      currentWindow.on('keyboardHeightChange', (keyboardHeight: number) => {
        if (keyboardHeight === 0) {
          this.isKeyboardVisible = false;
          if (!this.isSubmittingComposer && this.draftContent.trim().length === 0) {
            this.closeGlobalComposer();
          }
        } else {
          this.isKeyboardVisible = true;
        }
      });
    }).catch((error: Error) => {
      console.error('设置键盘监听器失败:', error);
    });
  }

  private cleanupKeyboardListener(): void {
    console.log('清理键盘监听器');
    const context = this.getUIContext().getHostContext();
    if (!context) {
      return;
    }
    window.getLastWindow(context).then((currentWindow) => {
      currentWindow.off('keyboardHeightChange');
    }).catch((error: Error) => {
      console.error('清理键盘监听器失败:', error);
    });
  }

  private openGlobalComposer(): void {
    this.showComposer = true;
  }

  private closeGlobalComposer(): void {
    this.showComposer = false;
    this.draftContent = '';
  }

  private canSubmitComposer(): boolean {
    return !this.isSubmittingComposer && this.draftContent.trim().length > 0;
  }

  private async submitGlobalComposer(): Promise<void> {
    const content = this.draftContent.trim();
    if (this.isSubmittingComposer || content.length === 0) {
      return;
    }

    this.isSubmittingComposer = true;
    this.draftContent = '';

    try {
      console.log('开始提交内容:', content);
      const context = this.getUIContext().getHostContext();
      if (!context) {
        throw new Error('无法获取应用上下文');
      }
      console.log('应用上下文获取成功');
      await initializeAppBootstrap(context.filesDir);
      console.log('AppBootstrap初始化完成');
      
      const createdItem: TimelineItemEntity = {
        id: generateId(),
        timestamp: Date.now(),
        content,
        iconName: '',
        type: 'timeline',
        isLivePhoto: false
      };
      console.log('创建时间线项:', createdItem);
      
      const savedItem = await getTimelineRepository().create(createdItem);
      console.log('数据保存成功，保存的项:', savedItem);
      
      // 重新加载所有数据确保一致性
      console.log('重新加载数据...');
      await this.loadTimelineItems(false);
      console.log('数据重新加载完成');
      
      this.closeGlobalComposer();
      console.log('输入框已关闭');
    } catch (error) {
      this.draftContent = content;
      console.error('提交内容失败:', error);
      return;
    } finally {
      this.isSubmittingComposer = false;
    }
  }

  private async loadTimelineItems(showLoading: boolean = true): Promise<void> {
    console.log('开始加载时间线数据，showLoading:', showLoading);
    if (showLoading) {
      this.isTimelineLoading = true;
    }
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) {
        throw new Error('无法获取应用上下文');
      }
      console.log('应用上下文获取成功，filesDir:', context.filesDir);
      await initializeAppBootstrap(context.filesDir);
      console.log('AppBootstrap初始化完成');
      const loadedItems = await getTimelineRepository().listAll();
      console.log('从数据库加载到', loadedItems.length, '条记录');
      
      if (loadedItems.length > 0) {
        console.log('第一条记录详情:', {
          id: loadedItems[0].id,
          content: loadedItems[0].content,
          timestamp: loadedItems[0].timestamp,
          type: loadedItems[0].type
        });
      }
      
      // 强制创建新数组引用，确保触发UI更新
      this.timelineItems = [...loadedItems];
      console.log('时间线数据已更新，记录数:', this.timelineItems.length);
    } catch (error) {
      console.error('加载时间线失败:', error);
      if (showLoading) {
        this.timelineItems = [];
      }
    } finally {
      if (showLoading) {
        this.isTimelineLoading = false;
      }
      console.log('时间线数据加载完成');
    }
  }



  private async initializeDataFoundation(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) {
        throw new Error('无法获取应用上下文');
      }
      await initializeAppBootstrap(context.filesDir);
      await this.loadTimelineItems();
    } catch (_) {
    }
  }
}
