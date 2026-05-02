import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { ThemeControl, CustomTheme } from '@ohos.arkui.theme';
import { AppStorageV2 } from '@ohos.arkui.StateManagement';

const DOMAIN = 0x0000;
const TAG = 'PulseConsole';

@ObservedV2
class ConsoleState {
  @Trace pulseRate: number = 72;
  @Trace isAnimating: boolean = false;
  @Trace isDarkMode: boolean = true;
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');

    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'setColorMode failed: %{public}s', JSON.stringify(err));
    }

    AppStorage.setOrCreate<number>('pulseRate', 72);
    AppStorage.setOrCreate<boolean>('isAnimating', false);
    AppStorage.setOrCreate<boolean>('isDarkMode', true);
    AppStorage.setOrCreate<number>('fpsValue', 0);
    AppStorage.setOrCreate<number>('totalFrames', 0);
    AppStorage.setOrCreate<number>('idleTimeMs', 0);
    AppStorage.setOrCreate<string>('fontConfig', '{}');
    AppStorage.setOrCreate<string>('themeAccentColor', '#00FF88');

    try {
      let pulseTheme: CustomTheme = {
        colors: {
          brand: '#00FF88',
          warning: '#FFB300',
          fontPrimary: '#E0E0E0'
        }
      };
      ThemeControl.setDefaultTheme(pulseTheme);
      hilog.info(DOMAIN, TAG, 'Default theme applied via ThemeControl.setDefaultTheme');
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'ThemeControl.setDefaultTheme: %{public}s', JSON.stringify(err));
    }

    try {
      let state: ConsoleState | undefined =
        AppStorageV2.connect(ConsoleState, 'consoleState', (): ConsoleState => new ConsoleState());
      if (state !== undefined) {
        hilog.info(DOMAIN, TAG, 'AppStorageV2.connect succeeded, pulseRate=%{public}d', state.pulseRate);
      }
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'AppStorageV2.connect: %{public}s', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Content loaded');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'onBackground');
  }
}
