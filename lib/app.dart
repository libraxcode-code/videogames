import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/gaming_splash_screen.dart';
import 'injection_container.dart';

class VideogamesApp extends StatelessWidget {
  const VideogamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return InjectionContainer(
      child: MaterialApp(
        title: 'Videogames',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const GamingSplashScreen(),
      ),
    );
  }
}
