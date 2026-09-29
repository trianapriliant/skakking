import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../data/repositories/chess_game_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final chessGameRepositoryProvider = Provider<ChessGameRepository>(
  (ref) => ChessGameRepository(ref.watch(appDatabaseProvider)),
);

final recentGamesProvider = StreamProvider((ref) {
  return ref.watch(chessGameRepositoryProvider).watchRecentGames();
});
