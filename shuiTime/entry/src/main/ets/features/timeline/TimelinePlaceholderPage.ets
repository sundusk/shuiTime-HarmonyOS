@Component
export struct TimelinePlaceholderPage {
  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('时间线')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')

        Text('这里会承接按日期浏览、新增文字记录、瞬影图片记录、日历切换和搜索跳转。')
          .fontSize(16)
          .fontColor('#555555')
          .lineHeight(24)

        this.renderCard('当前状态', '页面骨架已创建，等待接入时间线列表、输入栏和日期切换逻辑。')
        this.renderCard('下一步', '先接 repository 的按日查询，再补新增/编辑/删除。')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(24)
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
