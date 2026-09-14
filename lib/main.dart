import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'constants/api_constants.dart';
import 'constants/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Keep screen awake (상시 화면 켜짐 유지)
  try {
    await WakelockPlus.enable();
  } catch (_) {}

  if (!kIsWeb) {
    try {
      await HomeWidget.setAppGroupId(ApiConstants.appGroupId);
    } catch (_) {}
  }

  runApp(const PetWeatherApp());
}

class PetWeatherApp extends StatelessWidget {
  const PetWeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: '날씨 & 일출·일몰 스마트 시계',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ko', 'KR'),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(provider.fontScale),
                ),
                child: child ?? const SizedBox(),
              );
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
