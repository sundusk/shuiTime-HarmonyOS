import router from '@ohos.router';
import { window } from '@kit.ArkUI';
// AppStorage是全局可用的，无需导入
import { getTimelineRepository, initializeAppBootstrap } from '../app/AppBootstrap';
import { generateId } from '../common/utils/IdUtils';
import { TimelineItemEntity } from '../data/model/TimelineItemEntity';

interface KeyboardAvoidAreaChangeInfo {
  type: window.AvoidAreaType;
  area: window.AvoidArea;
}

@Entry
@Component
struct TimelineComposePage {
  @State private content: string = '';
  @State private keyboardInset: number = 0;
  @State private isSubmitting: boolean = false;
  private readonly editorInputKey: string = 'timeline-compose-editor';
  private readonly toolbarHeightEstimate: number = 58;
  private readonly keyboardToolbarGapCompensation: number = 30;
  private readonly keyboardHeightCallback: (keyboardHeight: number) => void = (keyboardHeight: number): void => {
    this.keyboardInset = keyboardHeight > 0 ? px2vp(keyboardHeight) : 0;
  };
  private readonly avoidAreaCallback: (info: KeyboardAvoidAreaChangeInfo) => void =
    (info: KeyboardAvoidAreaChangeInfo): void => {
      if (info.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
        return;
      }
      this.keyboardInset = this.extractKeyboardInset(info.area);
    };
  private currentWindow?: window.Window;

  onPageShow(): void {
    this.bindWindowAndKeyboard();
    this.requestEditorFocus();
  }

  onPageHide(): void {
    this.cleanupKeyboardListener();
  }

  aboutToDisappear(): void {
    this.cleanupKeyboardListener();
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        this.buildHeader();
        this.buildEditor();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF');

      if (this.shouldShowToolbar()) {
        this.buildBottomToolbar();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  private buildHeader() {
    Row() {
      this.buildBackButton();
      Blank();
    }
    .width('100%')
    .padding({ left: 12, right: 20, top: 12, bottom: 8 })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildBackButton() {
    Row() {
      Column({ space: 0 }) {
        Row() {}
          .width(10)
          .height(2)
          .backgroundColor('#9CA3AF')
          .rotate({ angle: -45 })
          .margin({ bottom: 2 });

        Row() {}
          .width(10)
          .height(2)
          .backgroundColor('#9CA3AF')
          .rotate({ angle: 45 })
          .margin({ top: 2 });
      }
      .margin({ left: -3 });
    }
    .width(36)
    .height(36)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      router.back();
    });
  }

  @Builder
  private buildEditor() {
    TextArea({ placeholder: '', text: this.content })
      .key(this.editorInputKey)
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 24, right: 24, top: 18, bottom: this.getEditorBottomPadding() })
      .fontSize(18)
      .fontColor('#1F2430')
      .caretColor('#7CD6A8')
      .focusable(true)
      .defaultFocus(true)
      .focusOnTouch(true)
      .backgroundColor('#00FFFFFF')
      .placeholderColor('#00FFFFFF')
      .onAppear(() => {
        this.requestEditorFocus();
      })
      .onChange((value: string) => {
        this.content = value;
      });
  }

  @Builder
  private buildBottomToolbar() {
    Column() {
      Row() {}
        .width('100%')
        .height(1)
        .backgroundColor('#F1F2F6');

      Row() {
        this.buildToolbarButton('#');
        this.buildToolbarImageButton();
        this.buildToolbarButton('B', true);
        this.buildToolbarButton('三');
        this.buildToolbarDivider();
        this.buildToolbarButton('...');

        Blank();

        this.buildSendButton();
      }
      .width('100%')
      .padding({ left: 18, right: 12, top: 12, bottom: 6 })
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .margin({ bottom: this.getToolbarBottomOffset() })
    .zIndex(10)
    .backgroundColor('#FFFFFF')
    .shadow({
      radius: 12,
      color: '#08000000',
      offsetX: 0,
      offsetY: -4
    });
  }

  @Builder
  private buildToolbarButton(label: string, isStrong: boolean = false) {
    Text(label)
      .fontSize(label === '...' ? 20 : 24)
      .fontWeight(isStrong ? FontWeight.Bold : FontWeight.Medium)
      .fontColor('#2E3440')
      .margin({ right: 18 });
  }

  @Builder
  private buildToolbarImageButton() {
    Stack() {
      Row() {}
        .width(16)
        .height(12)
        .border({
          width: 1.6,
          color: '#2E3440',
          radius: 2
        });

      Circle()
        .width(3)
        .height(3)
        .fill('#2E3440')
        .position({ x: 11, y: 5 });

      Row() {}
        .width(7)
        .height(1.6)
        .backgroundColor('#2E3440')
        .rotate({ angle: -25 })
        .position({ x: 7, y: 10 });
    }
    .width(18)
    .height(18)
    .margin({ right: 18 });
  }

  @Builder
  private buildToolbarDivider() {
    Row() {}
      .width(1)
      .height(18)
      .backgroundColor('#E5E7EB')
      .margin({ right: 18 });
  }

  @Builder
  private buildSendButton() {
    Text(this.isSubmitting ? '发送中' : '发送')
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.canSend() ? '#FFFFFF' : '#8FA0B3')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor(this.canSend() ? '#4A7DFF' : '#E7EDF5')
      .borderRadius(22)
      .opacity(this.isSubmitting ? 0.82 : 1)
      .onClick(() => {
        this.submitTimelineItem();
      });
  }

  private requestEditorFocus(): void {
    const focus = (): void => {
      try {
        // 使用正确的焦点控制器API，从API version 12开始生效
        const focusController = this.getUIContext().getFocusController();
        focusController.requestFocus(this.editorInputKey);
      } catch (error) {
        console.error('编辑页请求焦点失败:', error);
      }
    };

    // 使用更合理的延迟策略
    setTimeout(focus, 100);
    setTimeout(focus, 300);
  }

  private getEditorBottomPadding(): number {
    if (!this.shouldShowToolbar()) {
      return 24;
    }
    return this.toolbarHeightEstimate + 24;
  }

  private getToolbarBottomOffset(): number {
    const adjustedInset = this.keyboardInset - this.keyboardToolbarGapCompensation;
    return adjustedInset > 0 ? adjustedInset : 0;
  }

  private shouldShowToolbar(): boolean {
    return this.keyboardInset > 0;
  }

  private canSend(): boolean {
    return !this.isSubmitting && this.content.trim().length > 0;
  }

  private async submitTimelineItem(): Promise<void> {
    const trimmedContent = this.content.trim();
    if (!this.canSend() || trimmedContent.length === 0) {
      return;
    }

    this.isSubmitting = true;

    try {
      const context = this.getUIContext().getHostContext();
      if (!context) {
        throw new Error('编辑页无法获取应用上下文');
      }

      console.log('开始初始化AppBootstrap...');
      await initializeAppBootstrap(context.filesDir);
      console.log('AppBootstrap初始化完成');
      
      const createdItem: TimelineItemEntity = {
        id: generateId(),
        timestamp: Date.now(),
        content: trimmedContent,
        iconName: '',
        type: 'timeline',
        isLivePhoto: false
      };

      console.log('开始保存时间线项:', createdItem);
      await getTimelineRepository().create(createdItem);
      AppStorage.SetOrCreate<number>('timeline_refresh_token', Date.now());

      console.log('强制重建Index页面以刷新时间线');
      await router.replaceUrl({
        url: 'pages/Index'
      } as router.RouterOptions);
    } catch (error) {
      console.error('发送时间线内容失败:', error);
    } finally {
      this.isSubmitting = false;
    }
  }

  private bindWindowAndKeyboard(): void {
    const context = this.getUIContext().getHostContext();
    if (!context) {
      console.error('编辑页无法获取应用上下文');
      return;
    }

    window.getLastWindow(context).then((currentWindow) => {
      this.currentWindow = currentWindow;
      currentWindow.off('keyboardHeightChange', this.keyboardHeightCallback);
      currentWindow.off('avoidAreaChange', this.avoidAreaCallback);
      currentWindow.on('keyboardHeightChange', this.keyboardHeightCallback);
      currentWindow.on('avoidAreaChange', this.avoidAreaCallback);
      this.syncKeyboardInset(currentWindow);
    }).catch((error: Error) => {
      console.error('编辑页设置键盘监听失败:', error);
    });
  }

  private syncKeyboardInset(currentWindow: window.Window): void {
    try {
      const keyboardArea = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
      this.keyboardInset = this.extractKeyboardInset(keyboardArea);
    } catch (error) {
      console.error('读取键盘避让区失败:', error);
    }
  }

  private extractKeyboardInset(avoidArea: window.AvoidArea): number {
    if (!avoidArea.visible) {
      return 0;
    }
    return avoidArea.bottomRect.height > 0 ? px2vp(avoidArea.bottomRect.height) : 0;
  }

  private cleanupKeyboardListener(): void {
    if (!this.currentWindow) {
      return;
    }
    this.currentWindow.off('keyboardHeightChange', this.keyboardHeightCallback);
    this.currentWindow.off('avoidAreaChange', this.avoidAreaCallback);
    this.currentWindow = undefined;
    this.keyboardInset = 0;
  }
}
