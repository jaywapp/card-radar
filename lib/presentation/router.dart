import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/data/models/ranking_args.dart';
import 'package:card_radar/presentation/screens/onboarding_screen.dart';
import 'package:card_radar/presentation/screens/home_screen.dart';
import 'package:card_radar/presentation/screens/ranking_screen.dart';
import 'package:card_radar/presentation/screens/my_cards_screen.dart';
import 'package:card_radar/presentation/screens/search_screen.dart';
import 'package:card_radar/presentation/screens/map_screen.dart';
import 'package:card_radar/presentation/widgets/feedback_fab.dart';

final appRouter = GoRouter(
  redirect: (context, state) {
    final box = Hive.box<String>('user_cards');
    final stored = box.get('card_ids');
    final hasCards = stored != null && stored.isNotEmpty;
    if (!hasCards && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/ranking',
          builder: (_, state) {
            final extra = state.extra;
            if (extra is RankingArgs) {
              return RankingScreen(
                category: extra.category,
                merchantKey: extra.merchantKey,
                merchantName: extra.merchantName,
              );
            }
            return RankingScreen(category: extra as CardCategory);
          },
        ),
        GoRoute(path: '/my-cards', builder: (_, __) => const MyCardsScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: const FeedbackFab(),
        ),
      ],
    );
  }
}
