import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/games/presentation/pages/game_list_page.dart';
import 'injection_container.dart';

class VideogamesApp extends StatelessWidget {
  const VideogamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return InjectionContainer(
      child: MaterialApp(
        title: 'Videogames Clean Arch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const GameListPage(),
      ),
    );
  }
}
