import 'package:go_router/go_router.dart';

import '../ui/game/game_screen.dart';
import '../ui/home/home_screen.dart';
import '../ui/campaign/campaign_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/campaign',
      builder: (context, state) => const CampaignScreen(),
    ),
    GoRoute(
      path: '/campaign/:campaignId',
      builder: (context, state) =>
          CampaignScreen(campaignId: state.pathParameters['campaignId']),
    ),
    GoRoute(
      path: '/game/:gameId',
      builder: (context, state) => const GameScreen(),
    ),
  ],
);
