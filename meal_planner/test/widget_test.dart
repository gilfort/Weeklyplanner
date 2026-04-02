import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:meal_planner/models/models.dart';
import 'package:meal_planner/providers/recipe_provider.dart';
import 'package:meal_planner/screens/recipe_edit_screen.dart';
import 'package:meal_planner/screens/recipe_list_screen.dart';

/// Wrap a screen in a MaterialApp + ProviderScope for testing.
Widget buildTestScreen({
  required Widget screen,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: screen),
  );
}

/// Wrap RecipeListScreen with a GoRouter so context.go() works in tests.
Widget buildRoutedRecipeList({
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/recipes',
    routes: [
      GoRoute(
        path: '/recipes',
        builder: (context, state) => const RecipeListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const RecipeEditScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) {
              // Pass a dummy recipe so _isEditing is true.
              final recipeId = state.pathParameters['id'] ?? '';
              return RecipeEditScreen(
                recipe: Recipe(id: recipeId, name: '', servings: 1),
              );
            },
          ),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('RecipeListScreen', () {
    testWidgets('Empty list shows hint text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestScreen(
        screen: const RecipeListScreen(),
        overrides: [
          recipesProvider.overrideWith(() => _FakeRecipes([])),
        ],
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Rezeptbuch'), findsOneWidget);
      expect(find.text('Dein Rezeptbuch ist noch leer'), findsOneWidget);
      expect(find.text('Erstes Rezept anlegen'), findsOneWidget);
    });

    testWidgets('FAB navigates to new recipe screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildRoutedRecipeList(
        overrides: [
          recipesProvider.overrideWith(() => _FakeRecipes([])),
        ],
      ));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Neues Rezept'), findsOneWidget);
      expect(find.text('Name *'), findsOneWidget);
      expect(find.text('Portionen *'), findsOneWidget);
    });

    testWidgets('Recipes appear in list', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestScreen(
        screen: const RecipeListScreen(),
        overrides: [
          recipesProvider.overrideWith(() => _FakeRecipes([
                Recipe(
                  id: 'r1',
                  name: 'Pasta Bolognese',
                  description: 'Klassiker',
                  servings: 4,
                  tags: ['italienisch'],
                ),
              ])),
        ],
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Pasta Bolognese'), findsOneWidget);
      expect(find.text('Klassiker'), findsOneWidget);
      expect(find.text('italienisch'), findsOneWidget);
      expect(find.text('4 Port.'), findsOneWidget);
    });

    testWidgets('Tap recipe opens edit screen', (WidgetTester tester) async {
      await tester.pumpWidget(buildRoutedRecipeList(
        overrides: [
          recipesProvider.overrideWith(() => _FakeRecipes([
                Recipe(id: 'r1', name: 'Salat', servings: 2),
              ])),
        ],
      ));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Salat'));
      await tester.pumpAndSettle();

      expect(find.text('Rezept bearbeiten'), findsOneWidget);
    });

    testWidgets('Long-press shows delete dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestScreen(
        screen: const RecipeListScreen(),
        overrides: [
          recipesProvider.overrideWith(() => _FakeRecipes([
                Recipe(id: 'r1', name: 'Suppe', servings: 3),
              ])),
        ],
      ));
      await tester.pump();
      await tester.pump();

      await tester.longPress(find.text('Suppe'));
      await tester.pumpAndSettle();

      expect(find.text('Rezept löschen?'), findsOneWidget);

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.text('Rezept löschen?'), findsNothing);
      expect(find.text('Suppe'), findsOneWidget);
    });
  });
}

/// A fake Recipes notifier that returns data synchronously (no file I/O).
class _FakeRecipes extends Recipes {
  final List<Recipe> _data;
  _FakeRecipes(this._data);

  @override
  Future<List<Recipe>> build() async => _data;

  @override
  Future<void> upsert(Recipe recipe) async {
    final index = _data.indexWhere((r) => r.id == recipe.id);
    if (index >= 0) {
      _data[index] = recipe;
    } else {
      _data.add(recipe);
    }
    state = AsyncData(List.of(_data));
  }

  @override
  Future<void> delete(String id) async {
    _data.removeWhere((r) => r.id == id);
    state = AsyncData(List.of(_data));
  }
}
