import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/presentation/screens/onboarding_screen.dart';
import 'package:card_radar/presentation/screens/home_screen.dart';
import 'package:card_radar/presentation/screens/ranking_screen.dart';
import 'package:card_radar/presentation/screens/my_cards_screen.dart';
import 'package:card_radar/presentation/screens/search_screen.dart';

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
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/ranking',
      builder: (_, state) {
        final category = state.extra as CardCategory;
        return RankingScreen(category: category);
      },
    ),
    GoRoute(path: '/my-cards', builder: (_, __) => const MyCardsScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
  ],
);
