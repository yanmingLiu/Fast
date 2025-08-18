import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/tools/navigation_obs.dart';
import 'package:fast_ai/tools/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // 初始化 AppFlow
    AppService().init(env: kReleaseMode ? Environment.prod : Environment.dev);

    await AppService().start();
  } catch (e, s) {
    log.e('===> init error: $e\n$s');
  }
  runApp(const MyApp());
}

Iterable<Locale> supportedLocales = const [
  Locale('en'), // 英语
  Locale('ar'), // 阿拉伯语
  Locale('fr'), // 法语
  Locale('de'), // 德语
  Locale('es'), // 西班牙语
  Locale('pt'), // 葡萄牙语
  Locale('ja'), // 日语
  Locale('ko'), // 韩语
];

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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3F8DFD)),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      getPages: Routers.pages,
      initialRoute: Routers.splash,
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
      builder: FlutterSmartDialog.init(loadingBuilder: (msg) => FLoading.custom()),
    );
  }
}
