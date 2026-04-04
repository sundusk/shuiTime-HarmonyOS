@Component
export struct LookbackPlaceholderPage {
  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('时光回顾')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')

        Text('这里会承接历史聚合、去年今日、按日回顾，以及后续的热力图能力。')
          .fontSize(16)
          .fontColor('#555555')
          .lineHeight(24)

        this.renderCard('当前状态', '页面骨架已创建，等待接入历史聚合和回顾计算逻辑。')
        this.renderCard('下一步', '先做回顾概览和去年今日，再考虑热力图。')
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
