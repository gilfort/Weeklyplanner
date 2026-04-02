import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'router.dart';
import 'theme.dart';

part 'main.g.dart';

@riverpod
Raw<GoRouter> appRouter(AppRouterRef ref) => createRouter(ref);

void main() {
  runApp(const ProviderScope(child: MealPlannerApp()));
}

class MealPlannerApp extends ConsumerWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Meal Planner',
      theme: PaperTheme.themeData,
      routerConfig: router,
    );
  }
}
