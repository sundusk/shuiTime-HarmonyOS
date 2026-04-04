@Component
export struct InspirationPlaceholderPage {
  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('瞬息')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')

        Text('这里会承接灵感卡片流、标签提取筛选、搜索、编辑删除和圈选颜色。')
          .fontSize(16)
          .fontColor('#555555')
          .lineHeight(24)

        this.renderCard('当前状态', '页面骨架已创建，等待接入 inspiration 类型查询和标签解析。')
        this.renderCard('下一步', '先把卡片列表和标签筛选状态接到仓储层。')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 24, right: 24, top: 24, bottom: 88 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  private renderCard(title: string, value: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(14)
        .fontColor('#666666')
      Text(value)
        .fontSize(16)
        .fontColor('#111111')
        .lineHeight(24)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
