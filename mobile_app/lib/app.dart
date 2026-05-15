import 'package:expense_tracker_app/core/routing/app_router.dart';
import 'package:expense_tracker_app/core/theme/app_theme.dart';
import 'package:expense_tracker_app/core/theme/theme_controller.dart';
import 'package:expense_tracker_app/shared/widgets/no_internet_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final router = ref.watch(appRouter);

    return MaterialApp.router(
      title: 'Expense Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // NoInternetWrapper lives INSIDE MaterialApp so it has
      // Theme + Directionality — placing it outside causes a crash.
      builder: (context, child) => NoInternetWrapper(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
