import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/n_p_n.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/tools/navigation_obs.dart';
import 'package:fast_ai/values/theme_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 只允许竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  try {
    /// 控制图片缓存大小
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;

    FService().init(env: kReleaseMode ? Environment.prod : Environment.dev);

    await FService().start();

    final isFirstLaunch = FCache().isRestart == false;
    if (isFirstLaunch) {
      FLogEvent().logInstallEvent();
    } else {
      FLogEvent().logSessionEvent();
    }
  } catch (e, s) {
    log.e('===> init error: $e\n$s');
  }
  runApp(const MyApp());
}

Iterable<Locale> supportedLocales = const [
  Locale('en'), // 英语
  // Locale('ar'), // 阿拉伯语
  // Locale('fr'), // 法语
  // Locale('de'), // 德语
  // Locale('es'), // 西班牙语
  // Locale('pt'), // 葡萄牙语
  // Locale('ja'), // 日语
  // Locale('ko'), // 韩语
];

// 缓存语言判断结果避免重复调用
final isArabic = Get.locale?.languageCode == 'ar';

Locale get locale {
  final locale = Get.deviceLocale;

  for (var s in supportedLocales) {
    if (s.languageCode == locale?.languageCode) {
      return s;
    }
  }
  return supportedLocales.first;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fast AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ThemeColors.primary),
        scaffoldBackgroundColor: const Color(0xFF111111), // 背景色
      ),
      getPages: NPN.pages,
      initialRoute: NPN.splash,
      navigatorObservers: [
        FlutterSmartDialog.observer,
        NavigationObs().observer,
        GetXRouterObserver(),
      ],
      // 国际化
      supportedLocales: supportedLocales,
      locale: locale,
      translationsKeys: AppTranslation.translations,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (locales, supportedLocales) {
        return locales?.firstWhere(
          (l) => supportedLocales.any((s) => s.languageCode == l.languageCode),
          orElse: () => supportedLocales.first,
        );
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: FlutterSmartDialog.init(
              loadingBuilder: (msg) => FLoading.custom())(
            context,
            child,
          ),
        );
      },
    );
  }
}
