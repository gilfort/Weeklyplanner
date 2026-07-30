import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/sync_provider.dart';
import 'router.dart';
import 'theme.dart';

part 'main.g.dart';

@riverpod
Raw<GoRouter> appRouter(AppRouterRef ref) => createRouter(ref);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final setupDone = prefs.getBool('setup_done') ?? false;
  runApp(ProviderScope(child: MealPlannerApp(setupDone: setupDone)));
}

class MealPlannerApp extends ConsumerStatefulWidget {
  final bool setupDone;
  const MealPlannerApp({super.key, required this.setupDone});

  @override
  ConsumerState<MealPlannerApp> createState() => _MealPlannerAppState();
}

class _MealPlannerAppState extends ConsumerState<MealPlannerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // syncServiceProvider is async; only act if it has resolved.
    final service = ref.read(syncServiceProvider).valueOrNull;
    if (service == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground: sync immediately + restart timer.
        service.syncAll();
        service.startPeriodicSync();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        service.stopPeriodicSync();
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    // Redirect to setup on first launch.
    if (!widget.setupDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (router.routeInformationProvider.value.uri.path != '/setup') {
          router.go('/setup');
        }
      });
    }

    return MaterialApp.router(
      title: 'Meal Planner',
      theme: PaperTheme.themeData,
      routerConfig: router,
    );
  }
}
