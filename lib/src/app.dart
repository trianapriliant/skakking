import 'package:flutter/material.dart';
import 'routing/app_router.dart';
import 'ui/theme/app_theme.dart';

class CaturMateApp extends StatelessWidget {
  const CaturMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Catur Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
