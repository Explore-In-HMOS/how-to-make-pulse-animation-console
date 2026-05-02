import { AnimatorResult, AnimatorOptions } from '@ohos.animator';
import { FrameCallback } from '@kit.ArkUI';
import font from '@ohos.font';
import matrix4 from '@ohos.matrix4';
import uiAppearance from '@ohos.uiAppearance';
import { PulseDetailView } from '../views/PulseDetailView';
import { AppearanceView } from '../views/AppearanceView';

class PulseFrameCallback extends FrameCallback {
  onFrameHandler: ((time: number) => void) | undefined = undefined;
  onIdleHandler: ((deadline: number) => void) | undefined = undefined;

  onFrame(frameTimeNanos: number): void {
    if (this.onFrameHandler !== undefined) {
      this.onFrameHandler(frameTimeNanos);
    }
  }

  onIdle(deadline: number): void {
    if (this.onIdleHandler !== undefined) {
      this.onIdleHandler(deadline);
    }
  }
}

@Entry
@Component
struct Index {
  private navPathStack: NavPathStack = new NavPathStack();
  private pulseAnimator: AnimatorResult | null = null;
  private frameCallback: PulseFrameCallback = new PulseFrameCallback();
  private fpsIntervalId: number = -1;
  private frameCountPerSec: number = 0;
  @StorageLink('pulseRate') bpmValue: number = 72;
  @StorageLink('isAnimating') isAnimating: boolean = false;
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @StorageLink('fpsValue') fpsDisplay: number = 0;
  @StorageLink('totalFrames') totalFrames: number = 0;
  @StorageLink('idleTimeMs') idleTimeMs: number = 0;
  @StorageLink('themeAccentColor') themeAccentColor: string = '#00FF88';
  @State pulseScale: number = 1.0;
  @State pulseOpacity: number = 0.7;
  @State statusText: string = 'Ready';
  @State outerRingTransform: matrix4.Matrix4Transit = matrix4.identity();
  @State consoleLines: string[] = [];
  glowRadius: number = 15;

  private log(msg: string): void {
    let d: Date = new Date();
    let h: string = d.getHours().toString().padStart(2, '0');
    let m: string = d.getMinutes().toString().padStart(2, '0');
    let s: string = d.getSeconds().toString().padStart(2, '0');
    if (this.consoleLines.length > 5) {
      this.consoleLines = this.consoleLines.slice(-4);
    }
    this.consoleLines = [...this.consoleLines, `[${h}:${m}:${s}] ${msg}`];
  }

  aboutToAppear(): void {
    this.initAllModules();
  }

  aboutToDisappear(): void {
    if (this.pulseAnimator !== null) {
      this.pulseAnimator.cancel();
    }
    if (this.fpsIntervalId !== -1) {
      clearInterval(this.fpsIntervalId);
    }
  }

  private initAllModules(): void {
    try {
      let mode: uiAppearance.DarkMode = uiAppearance.getDarkMode();
      this.isDarkMode = (mode === uiAppearance.DarkMode.ALWAYS_DARK);
      this.log(`Dark: ${this.isDarkMode ? 'ON' : 'OFF'}`);
    } catch (e) {
      this.isDarkMode = true;
      this.log('Dark: default ON');
    }

    try {
      this.getUIContext().getFont().registerFont({
        familyName: 'PulseMono',
        familySrc: $rawfile('PulseMono.ttf')
      });
      this.log('Font: PulseMono OK');
    } catch (e) {
      this.log('Font: system fallback');
    }

    try {
      let cfg: object = font.getUIFontConfig();
      let info: string = cfg ? 'loaded' : 'N/A';
      this.log(`FontCfg: ${info}`);
      AppStorage.setOrCreate<string>('fontConfig', JSON.stringify(cfg));
    } catch (e) {
      this.log('FontCfg: unavailable');
      AppStorage.setOrCreate<string>('fontConfig', '{}');
    }

    this.initAnimator();
    this.initMatrixTransform();
    this.initFrameCallback();

    this.statusText = 'Ready';
    this.log('Console ready');
  }

  private initAnimator(): void {
    try {
      let options: AnimatorOptions = {
        duration: 1500,
        easing: 'ease-in-out',
        delay: 0,
        fill: 'forwards',
        direction: 'alternate',
        iterations: -1,
        begin: 0.82,
        end: 1.18
      };

      this.pulseAnimator = this.getUIContext().createAnimator(options)
      this.pulseAnimator.onFrame = (value: number) => {
        this.pulseScale = value;
        this.pulseOpacity = 0.4 + (value - 0.82) * 1.67;
        this.glowRadius = 10 + (value - 0.82) * 42;
      };
      this.pulseAnimator.onFinish = () => {
        this.isAnimating = false;
        this.statusText = 'Paused';
      };
      this.log('Animator: created');
    } catch (e) {
      this.log('Animator: init err');
    }
  }

  private initMatrixTransform(): void {
    try {
      this.outerRingTransform = matrix4.identity().setPolyToPoly({
        src: [{ x: 0, y: 0 }, { x: 130, y: 0 }, { x: 130, y: 130 }, { x: 0, y: 130 }],
        dst: [{ x: 3, y: 5 }, { x: 127, y: 0 }, { x: 130, y: 130 }, { x: 0, y: 125 }]
      });
      this.log('Matrix: polyToPoly OK');
    } catch (e) {
      this.outerRingTransform = matrix4.identity();
      this.log('Matrix: identity');
    }
  }

  private initFrameCallback(): void {
    try {
      this.frameCallback.onFrameHandler = (timeNanos: number): void => {
        this.totalFrames++;
        this.frameCountPerSec++;
      };
      this.frameCallback.onIdleHandler = (deadline: number): void => {
        this.idleTimeMs = Math.round(deadline * 100) / 100;
      };
      this.getUIContext().postFrameCallback(this.frameCallback);
      this.log('FrameCb: active');
    } catch (e) {
      this.log('FrameCb: unavailable');
    }

    this.fpsIntervalId = setInterval(() => {
      this.fpsDisplay = this.frameCountPerSec;
      this.frameCountPerSec = 0;
      try {
        this.getUIContext().postFrameCallback(this.frameCallback);
      } catch (e) {
      }
    }, 1000);
  }

  private togglePulse(): void {
    if (this.pulseAnimator === null) {
      return;
    }
    if (this.isAnimating) {
      this.pulseAnimator.pause();
      this.isAnimating = false;
      this.statusText = 'Paused';
      this.log('Pulse paused');
    } else {
      this.pulseAnimator.play();
      this.isAnimating = true;
      this.statusText = 'Active';
      this.log('Pulse started');
    }
  }

  @Builder
  navMap(name: string) {
    if (name === 'PulseDetail') {
      PulseDetailView()
    } else if (name === 'Appearance') {
      AppearanceView()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Scroll() {
        Column() {
          Text($r('app.string.title_main'))
            .fontSize($r('app.float.title_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.pulse_cyan'))
            .letterSpacing(2)
            .margin({ top: 13 })

          Stack() {
            Circle()
              .width(124)
              .height(124)
              .fill(Color.Transparent)
              .stroke($r('app.color.ring_outer'))
              .strokeWidth(3)
              .transform(this.outerRingTransform)

            Image($rawfile('console_ring.svg'))
              .width(130)
              .height(130)
              .objectFit(ImageFit.Contain)
              .opacity(0.4)

            Circle()
              .width(100)
              .height(100)
              .fill(Color.Transparent)
              .stroke(this.themeAccentColor)
              .strokeWidth(4)
              .scale({ x: this.pulseScale, y: this.pulseScale })
              .opacity(this.pulseOpacity)

            Circle()
              .width(72)
              .height(72)
              .fill(Color.Transparent)
              .stroke($r('app.color.pulse_cyan'))
              .strokeWidth(2)
              .opacity(this.pulseOpacity * 0.5)
              .scale({ x: this.pulseScale * 0.95, y: this.pulseScale * 0.95 })

            Column() {
              Text(`${this.bpmValue}`)
                .fontSize($r('app.float.bpm_font_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeAccentColor)
              Text($r('app.string.label_bpm'))
                .fontSize(9)
                .fontColor($r('app.color.text_secondary'))
            }
          }
          .width(134)
          .height(134)
          .margin({ top: 2 })
          .onClick(() => {
            this.togglePulse();
          })

          Text(this.isAnimating ? '' : $r('app.string.tap_to_start'))
            .fontSize(8)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 1 })
            .visibility(this.isAnimating ? Visibility.Hidden : Visibility.Visible)

          Row() {
            Blank().width('0.1%')

            Row() {
              Text(`${this.idleTimeMs.toFixed(1)}`)
                .fontSize($r('app.float.stat_value_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.pulse_purple'))

              Blank().width('7%')

              Text($r('app.string.label_idle'))
                .fontSize($r('app.float.stat_label_size'))
                .fontColor($r('app.color.text_secondary'))
            }
            .layoutWeight(1)
            .align(Alignment.Center)
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')

          Row() {
            Column() {
              Text(`${this.fpsDisplay}`)
                .fontSize($r('app.float.stat_value_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.pulse_amber'))
              Text($r('app.string.label_fps'))
                .fontSize($r('app.float.stat_label_size'))
                .fontColor($r('app.color.text_secondary'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(this.statusText)
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isAnimating ? $r('app.color.pulse_green') : $r('app.color.pulse_red'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('72%')
          .margin({ top: 2 })

          Column() {
            ForEach(this.consoleLines, (line: string, idx: number) => {
              Text(line)
                .fontSize($r('app.float.console_font_size'))
                .fontColor($r('app.color.log_text'))
                .fontFamily('monospace')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
            }, (item: string, index: number) => item)

          }
          .width('86%')
          .height(46)
          .backgroundColor($r('app.color.console_bg_secondary'))
          .borderRadius(6)
          .padding(4)
          .margin({ top: 3 })

          Image($rawfile('pulse_wave.svg'))
            .width('70%')
            .height(18)
            .objectFit(ImageFit.Contain)
            .opacity(0.6)
            .margin({ top: 1 })

          Row() {
            Button($r('app.string.btn_details'))
              .fontSize($r('app.float.btn_font_size'))
              .height(28)
              .backgroundColor($r('app.color.btn_detail'))
              .borderRadius(14)
              .fontColor(Color.White)
              .onClick(() => {
                this.navPathStack.pushPathByName('PulseDetail', null);
              })

            Button($r('app.string.btn_theme'))
              .fontSize($r('app.float.btn_font_size'))
              .height(28)
              .backgroundColor($r('app.color.btn_theme'))
              .borderRadius(14)
              .fontColor(Color.White)
              .margin({ left: 8 })
              .onClick(() => {
                this.navPathStack.pushPathByName('Appearance', null);
              })
          }
          .margin({ top: 3, bottom: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .scrollable(ScrollDirection.Vertical)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.console_bg'))
    }
    .hideTitleBar(true)
    .navDestination(this.navMap)
    .mode(NavigationMode.Stack)
  }
}
