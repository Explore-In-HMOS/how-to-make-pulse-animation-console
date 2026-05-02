import uiAppearance from '@ohos.uiAppearance';
import { ThemeControl, CustomTheme } from '@ohos.arkui.theme';
import { Font } from '@kit.ArkUI';

interface ThemeOption {
  name: string;
  color: string;
}

@Component
export struct AppearanceView {
  @StorageProp('isDarkMode') isDarkMode: boolean = true;
  @StorageLink('themeAccentColor') themeAccentColor: string = '#00FF88';
  @State darkModeText: string = 'Checking...';
  @State themeStatus: string = 'Default';
  @State fontRegistered: boolean = false;
  @State selectedTheme: number = 0;
  private themeOptions: ThemeOption[] = [
    { name: 'Pulse', color: '#00FF88' },
    { name: 'Ocean', color: '#2196F3' },
    { name: 'Amber', color: '#FFB300' },
    { name: 'Violet', color: '#CE93D8' }
  ];

  aboutToAppear(): void {
    this.detectDarkMode();
    this.registerDisplayFont();
  }

  private detectDarkMode(): void {
    try {
      let mode: uiAppearance.DarkMode = uiAppearance.getDarkMode();
      if (mode === uiAppearance.DarkMode.ALWAYS_DARK) {
        this.darkModeText = 'Always Dark';
      } else if (mode === uiAppearance.DarkMode.ALWAYS_LIGHT) {
        this.darkModeText = 'Always Light';
      } else {
        this.darkModeText = 'System Auto';
      }
    } catch (e) {
      this.darkModeText = 'Detection unavailable';
    }
  }

  private registerDisplayFont(): void {
    try {

      this.getUIContext().getFont().registerFont({
        familyName: 'PulseDisplay',
        familySrc: $rawfile('PulseMono.ttf')
      });
      this.fontRegistered = true;
    } catch (e) {
      this.fontRegistered = false;
    }
  }

  private applyTheme(index: number): void {
    this.selectedTheme = index;
    let chosen: ThemeOption = this.themeOptions[index];
    try {
      let customTheme: CustomTheme = {
        colors: {
          brand: chosen.color
        }
      };
      ThemeControl.setDefaultTheme(customTheme);
      this.themeAccentColor = chosen.color;
      this.themeStatus = `${chosen.name} applied`;
    } catch (e) {
      this.themeStatus = `${chosen.name} (API unavailable)`;
    }
  }

  @Builder
  private navTitleBuilder() {
    Row() {
      Text('Appearance')
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
          Text('DARK MODE')
            .fontSize($r('app.float.section_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.pulse_cyan'))
            .margin({ top: 8 })

          Column() {
            Stack() {
              Circle()
                .width(40)
                .height(40)
                .fill(this.isDarkMode ? '#263238' : '#FFF9C4')
                .stroke(this.isDarkMode ? '#546E7A' : '#F9A825')
                .strokeWidth(2)
              if (this.isDarkMode) {
                Circle()
                  .width(28)
                  .height(28)
                  .fill('#263238')
                  .position({ x: 18, y: 2 })
              }
            }
            .width(44)
            .height(44)

            Text(this.darkModeText)
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .margin({ top: 6 })

            Text('uiAppearance.getDarkMode()')
              .fontSize(7)
              .fontColor($r('app.color.text_secondary'))
              .fontFamily('monospace')
              .margin({ top: 2 })
          }
          .width('88%')
          .backgroundColor($r('app.color.console_bg_secondary'))
          .borderRadius(10)
          .padding(10)
          .margin({ top: 6 })
          .alignItems(HorizontalAlign.Center)

          Text('THEME')
            .fontSize($r('app.float.section_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.pulse_cyan'))
            .margin({ top: 12 })

          Text(this.themeStatus)
            .fontSize(9)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 2 })

          Row() {
            ForEach(this.themeOptions, (opt: ThemeOption, idx: number) => {
              Column() {
                Stack() {
                  Circle()
                    .width(30)
                    .height(30)
                    .fill(opt.color)
                  if (this.selectedTheme === idx) {
                    Circle()
                      .width(36)
                      .height(36)
                      .fill(Color.Transparent)
                      .stroke(Color.White)
                      .strokeWidth(2)
                  }
                }
                .width(38)
                .height(38)

                Text(opt.name)
                  .fontSize(7)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.applyTheme(idx);
              })
            }, (opt: ThemeOption, idx: number) => opt.color)
          }
          .width('92%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 8 })

          Column() {
            Row()
              .width('80%')
              .height(4)
              .borderRadius(2)
              .backgroundColor(this.themeAccentColor)

            Text(`Accent: ${this.themeAccentColor}`)
              .fontSize(8)
              .fontColor(this.themeAccentColor)
              .fontFamily('monospace')
              .margin({ top: 4 })

            Row() {
              Circle()
                .width(14)
                .height(14)
                .fill(this.themeAccentColor)
              Text('Sample Label')
                .fontSize(9)
                .fontColor(this.themeAccentColor)
                .margin({ left: 6 })
              Blank()
              Text('Active')
                .fontSize(8)
                .fontColor($r('app.color.console_bg'))
                .backgroundColor(this.themeAccentColor)
                .borderRadius(6)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            }
            .width('90%')
            .margin({ top: 6 })
          }
          .width('88%')
          .backgroundColor($r('app.color.console_bg_secondary'))
          .borderRadius(8)
          .padding(8)
          .margin({ top: 8 })
          .alignItems(HorizontalAlign.Center)

          Image($rawfile('theme_preview.svg'))
            .width(140)
            .height(44)
            .objectFit(ImageFit.Contain)
            .margin({ top: 8 })

          Text('FONT')
            .fontSize($r('app.float.section_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.pulse_cyan'))
            .margin({ top: 12 })

          Column() {
            Row() {
              Text('PulseMono / PulseDisplay')
                .fontSize(10)
                .fontColor($r('app.color.pulse_green'))
              Circle()
                .width(8)
                .height(8)
                .fill(this.fontRegistered ? $r('app.color.pulse_green') : $r('app.color.pulse_amber'))
                .margin({ left: 6 })
            }

            Text(`Registered: ${this.fontRegistered ? 'Yes' : 'No (system fallback)'}`)
              .fontSize(8)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })

            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 6, bottom: 6 })

            Text('Font Preview:')
              .fontSize(8)
              .fontColor($r('app.color.text_secondary'))

            Text('ABCDEFGHIJ 0123456789')
              .fontSize(11)
              .fontFamily('PulseDisplay')
              .fontColor($r('app.color.text_primary'))
              .margin({ top: 4, left: 15 })

            Text('Pulse Console v1.0')
              .fontSize(10)
              .fontFamily('PulseMono')
              .fontColor($r('app.color.pulse_cyan'))
              .margin({ top: 2, left: 15 })
          }
          .width('88%')
          .backgroundColor($r('app.color.console_bg_secondary'))
          .borderRadius(10)
          .padding(10)
          .margin({ top: 6, bottom: 20, left: 9 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .scrollable(ScrollDirection.Vertical)
      .width('100%')
      .height('120%')
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
