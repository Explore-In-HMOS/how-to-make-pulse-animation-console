import font from '@ohos.font';
import matrix4 from '@ohos.matrix4';

@Component
export struct PulseDetailView {
  @StorageProp('fpsValue') fpsValue: number = 0;
  @StorageProp('totalFrames') totalFrames: number = 0;
  @StorageProp('idleTimeMs') idleTimeMs: number = 0;
  @StorageProp('pulseRate') pulseRate: number = 72;
  @StorageProp('isAnimating') isAnimating: boolean = false;
  @StorageProp('themeAccentColor') themeAccentColor: string = '#00FF88';

  @State warpAmount: number = 5;
  @State matrixPreview: matrix4.Matrix4Transit = matrix4.identity();
  @State fontInfo: string = 'Loading...';

  aboutToAppear(): void {
    this.updateMatrixTransform();
    this.loadFontConfig();
  }

  private updateMatrixTransform(): void {
    try {
      let w: number = 140;
      let h: number = 60;
      let d: number = this.warpAmount;
      this.matrixPreview = matrix4.identity().setPolyToPoly({
        src: [{ x: 0, y: 0 }, { x: w, y: 0 }, { x: w, y: h }, { x: 0, y: h }],
        dst: [{ x: d, y: d * 2 }, { x: w - d, y: 0 }, { x: w, y: h }, { x: 0, y: h - d * 2 }]
      });
    } catch (e) {
      this.matrixPreview = matrix4.identity();
    }
  }

  private loadFontConfig(): void {
    try {
      let cfg: object = font.getUIFontConfig();
      if (cfg !== null && cfg !== undefined) {
        let raw: string = JSON.stringify(cfg);
        this.fontInfo = raw.length > 100 ? raw.substring(0, 100) + '...' : raw;
      } else {
        this.fontInfo = 'No config available';
      }
    } catch (e) {
      this.fontInfo = 'API not available on this device';
    }
  }

  @Builder
  private navTitleBuilder() {
    Row() {
      Text('Pulse Details')
        .fontSize($r('app.float.nav_header_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text('FRAME STATISTICS')
            .fontSize($r('app.float.section_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeAccentColor)
            .margin({ top: 15 })

          Column() {
            Row() {
              Column() {
                Text(`${this.fpsValue}`)
                  .fontSize($r('app.float.detail_value_size'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.pulse_amber'))
                Text('FPS')
                  .fontSize($r('app.float.detail_label_size'))
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text(`${this.totalFrames}`)
                  .fontSize($r('app.float.detail_value_size'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.pulse_green'))
                Text('FRAMES')
                  .fontSize($r('app.float.detail_label_size'))
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')

            Row() {
              Column() {
                Text(`${this.idleTimeMs.toFixed(1)}`)
                  .fontSize($r('app.float.detail_value_size'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.pulse_purple'))
                Text('IDLE ms')
                  .fontSize($r('app.float.detail_label_size'))
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text(`${this.pulseRate}`)
                  .fontSize($r('app.float.detail_value_size'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.pulse_cyan'))
                Text('BPM')
                  .fontSize($r('app.float.detail_label_size'))
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .margin({ top: 8 })

            Row() {
              Circle()
                .width(8)
                .height(8)
                .fill(this.isAnimating ? $r('app.color.pulse_green') : $r('app.color.pulse_red'))
              Text(this.isAnimating ? 'Animation Active' : 'Animation Paused')
                .fontSize(9)
                .fontColor($r('app.color.text_secondary'))
                .margin({ left: 6 })
            }
            .margin({ top: 8 })
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('90%')
          .backgroundColor($r('app.color.console_bg_secondary'))
          .borderRadius(10)
          .padding(10)
          .margin({ top: 6 })

          Text('MATRIX TRANSFORM')
            .fontSize($r('app.float.section_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeAccentColor)
            .margin({ top: 12 })

          Text('setPolyToPoly warp demo')
            .fontSize(8)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 2 })

          Row() {
            Column() {
              Text('Source')
                .fontSize(8)
                .fontColor($r('app.color.text_secondary'))
                .margin({ bottom: 2 })
              Image($rawfile('frame_grid.svg'))
                .width(65)
                .height(34)
                .objectFit(ImageFit.Contain)
            }
            .alignItems(HorizontalAlign.Center)

            Text('>>>')
              .fontSize(12)
              .fontColor($r('app.color.pulse_cyan'))
              .margin({ left: 6, right: 6 })

            Column() {
              Text('Warped')
                .fontSize(8)
                .fontColor($r('app.color.text_secondary'))
                .margin({ bottom: 2 })
              Image($rawfile('frame_grid.svg'))
                .width(65)
                .height(34)
                .objectFit(ImageFit.Contain)
                .transform(this.matrixPreview)
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('90%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 6 })

          Row() {
            Text('Warp:')
              .fontSize(9)
              .fontColor($r('app.color.text_secondary'))
              .margin({ right: 4 })
            Slider({
              value: this.warpAmount,
              min: 0,
              max: 25,
              step: 1,
              style: SliderStyle.OutSet
            })
              .width('55%')
              .blockColor($r('app.color.pulse_cyan'))
              .trackColor($r('app.color.ring_outer'))
              .selectedColor($r('app.color.pulse_green'))
              .onChange((value: number) => {
                this.warpAmount = value;
                this.updateMatrixTransform();
              })
            Text(`${this.warpAmount}`)
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.pulse_green'))
              .margin({ left: 4 })
              .width(24)
          }
          .width('88%')
          .margin({ top: 4 })

          Text('FONT CONFIG')
            .fontSize($r('app.float.section_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeAccentColor)
            .margin({ top: 12 })

          Column() {
            Text('getUIFontConfig() result:')
              .fontSize(8)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 4 })
            Text(this.fontInfo)
              .fontSize(7)
              .fontColor($r('app.color.log_text'))
              .fontFamily('monospace')
              .maxLines(4)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          .width('68%')
          .backgroundColor($r('app.color.console_bg_secondary'))
          .borderRadius(8)
          .padding(8)
          .margin({ top: 6, bottom: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .scrollable(ScrollDirection.Vertical)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.console_bg'))
    }
    .hideBackButton(true)
    .hideTitleBar(true)

    .title({
      builder: this.navTitleBuilder,
      height: 35
    }, {
      backgroundColor: $r('app.color.console_bg_secondary')
    })
  }
}
