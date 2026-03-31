import router from '@ohos.router';
import { window } from '@kit.ArkUI';

interface KeyboardAvoidAreaChangeInfo {
  type: window.AvoidAreaType;
  area: window.AvoidArea;
}

@Entry
@Component
struct TimelineComposePage {
  @State private content: string = '';
  @State private keyboardInset: number = 0;
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

        this.buildVoiceButton();
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
  private buildVoiceButton() {
    Row({ space: 4 }) {
      this.buildVoiceWave(10);
      this.buildVoiceWave(14);
      this.buildVoiceWave(10);
    }
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor('#DDF8E9')
    .borderRadius(22);
  }

  @Builder
  private buildVoiceWave(height: number) {
    Row() {}
      .width(2)
      .height(height)
      .borderRadius(2)
      .backgroundColor('#42C983');
  }

  private requestEditorFocus(): void {
    const focus = (): void => {
      try {
        const focused = focusControl.requestFocus(this.editorInputKey);
        if (!focused) {
          this.getUIContext().getFocusController().requestFocus(this.editorInputKey);
        }
      } catch (error) {
        console.error('编辑页请求焦点失败:', error);
      }
    };

    setTimeout(focus, 80);
    setTimeout(focus, 240);
    setTimeout(focus, 420);
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
