import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_assistant/presentation/assistant_screen.dart';
import '../../features/analytics/presentation/insights_screen.dart';
import '../../features/authentication/data/auth_repositories.dart';
import '../../features/authentication/presentation/sign_in_screen.dart';
import '../../features/coupons/presentation/coupons_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/notifications_screen.dart';
import '../../features/maps/presentation/map_screen.dart';
import '../../features/meal_planner/presentation/meal_planner_screen.dart';
import '../../features/offers/presentation/offers_screen.dart';
import '../../features/pantry/presentation/pantry_screen.dart';
import '../../features/products/presentation/barcode_scan_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/receipts/presentation/receipt_scan_screen.dart';
import '../../features/receipts/presentation/receipts_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shopping_lists/presentation/list_detail_screen.dart';
import '../../features/shopping_lists/presentation/optimize_screen.dart';
import '../../features/shopping_lists/presentation/shopping_lists_screen.dart';
import '../../features/stores/presentation/store_detail_screen.dart';
import '../../features/stores/presentation/stores_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuild redirects when auth state changes.
  final authListenable = ValueNotifier(0);
  ref
    ..onDispose(authListenable.dispose)
    ..listen(authStateProvider, (_, _) => authListenable.value++);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null;
      final signedIn = auth.value != null;
      final onAuth = state.matchedLocation == '/auth';
      if (!signedIn && !onAuth) return '/auth';
      if (signedIn && onAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lists',
                builder: (_, _) => const ShoppingListsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/stores', builder: (_, _) => const StoresScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (_, _) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Detail routes cover the bottom bar (root navigator).
      GoRoute(
        path: '/lists/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            ListDetailScreen(listId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'optimize',
            parentNavigatorKey: _rootKey,
            builder: (_, state) =>
                OptimizeScreen(listId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/products',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/products/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BarcodeScanScreen(),
      ),
      GoRoute(
        path: '/stores/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            StoreDetailScreen(storeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/map',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const MapScreen(),
      ),
      GoRoute(
        path: '/offers',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const OffersScreen(),
      ),
      GoRoute(
        path: '/coupons',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const CouponsScreen(),
      ),
      GoRoute(
        path: '/pantry',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PantryScreen(),
      ),
      GoRoute(
        path: '/receipts',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ReceiptsScreen(),
      ),
      GoRoute(
        path: '/receipts/scan',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ReceiptScanScreen(),
      ),
      GoRoute(
        path: '/meal-planner',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const MealPlannerScreen(),
      ),
      GoRoute(
        path: '/assistant',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AssistantScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const NotificationsScreen(),
      ),
    ],
  );
});

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Stores',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
