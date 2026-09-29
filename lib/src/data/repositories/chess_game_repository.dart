import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../../domain/power_campaign.dart';

class SavedGame {
  const SavedGame({
    required this.game,
    required this.moves,
    this.campaignConfig,
  });

  final GameRow game;
  final List<MoveRow> moves;
  final CampaignGameConfig? campaignConfig;
}

class ChessGameRepository {
  const ChessGameRepository(this._database);

  final AppDatabase _database;

  Stream<List<GameRow>> watchRecentGames({int limit = 12}) {
    return (_database.select(_database.games)
          ..orderBy([(game) => OrderingTerm.desc(game.updatedAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> createGame({
    required String mode,
    required String difficulty,
    required String playerColor,
    required String fen,
    CampaignGameConfig? campaignConfig,
  }) async {
    final now = DateTime.now();
    final gameId = await _database
        .into(_database.games)
        .insert(
          GamesCompanion.insert(
            startedAt: now,
            updatedAt: now,
            mode: mode,
            difficulty: difficulty,
            playerColor: playerColor,
            fen: fen,
          ),
        );
    if (campaignConfig != null && campaignConfig.temporaryPowers.isNotEmpty) {
      await _database.customStatement(
        '''
        INSERT INTO campaign_game_configs
          (game_id, campaign_id, level, temporary_power_one, temporary_power_two)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [
          gameId,
          campaignConfig.campaignId,
          campaignConfig.level,
          campaignConfig.temporaryPowers.first.name,
          campaignConfig.temporaryPowers.length > 1
              ? campaignConfig.temporaryPowers[1].name
              : null,
        ],
      );
    }
    return gameId;
  }

  Future<CampaignProgress> getCampaignProgress(String campaignId) async {
    await _database.customStatement(
      'INSERT OR IGNORE INTO campaign_progress (campaign_id) VALUES (?)',
      [campaignId],
    );
    final row = await _database
        .customSelect(
          'SELECT campaign_id, unlocked_level, completed_level FROM campaign_progress WHERE campaign_id = ?',
          variables: [Variable.withString(campaignId)],
        )
        .getSingle();
    return CampaignProgress(
      campaignId: row.read<String>('campaign_id'),
      unlockedLevel: row.read<int>('unlocked_level'),
      completedLevel: row.read<int>('completed_level'),
    );
  }

  Future<List<CampaignProgress>> getAllCampaignProgress(
    Iterable<String> campaignIds,
  ) async {
    final values = <CampaignProgress>[];
    for (final id in campaignIds) {
      values.add(await getCampaignProgress(id));
    }
    return values;
  }

  Future<void> completeCampaignLevel(String campaignId, int level) async {
    await _database.customStatement(
      '''
      INSERT INTO campaign_progress (campaign_id, unlocked_level, completed_level)
      VALUES (?, MIN(8, ?), ?)
      ON CONFLICT(campaign_id) DO UPDATE SET
        completed_level = MAX(campaign_progress.completed_level, excluded.completed_level),
        unlocked_level = MIN(8, MAX(campaign_progress.unlocked_level, excluded.unlocked_level))
      ''',
      [campaignId, level + 1, level],
    );
  }

  Future<SavedGame?> loadGame(int gameId) async {
    final game = await (_database.select(
      _database.games,
    )..where((row) => row.id.equals(gameId))).getSingleOrNull();
    if (game == null) return null;

    final moves =
        await (_database.select(_database.gameMoves)
              ..where((move) => move.gameId.equals(gameId))
              ..orderBy([(move) => OrderingTerm.asc(move.ply)]))
            .get();
    final campaignRows = await _database
        .customSelect(
          'SELECT campaign_id, level, temporary_power_one, temporary_power_two FROM campaign_game_configs WHERE game_id = ?',
          variables: [Variable.withInt(gameId)],
        )
        .get();
    CampaignGameConfig? campaignConfig;
    if (campaignRows.isNotEmpty) {
      final row = campaignRows.single;
      final powerNames = [
        row.read<String>('temporary_power_one'),
        row.read<String?>('temporary_power_two'),
      ].whereType<String>();
      campaignConfig = CampaignGameConfig(
        campaignId: row.read<String>('campaign_id'),
        level: row.read<int>('level'),
        temporaryPowers: powerNames
            .map((name) => TemporaryPower.values.byName(name))
            .toList(growable: false),
      );
    }
    return SavedGame(game: game, moves: moves, campaignConfig: campaignConfig);
  }

  Future<void> recordMove({
    required int gameId,
    required int ply,
    required String san,
    required String from,
    required String to,
    required String fen,
    required bool isFinished,
    String? outcome,
  }) async {
    final now = DateTime.now();
    await _database.transaction(() async {
      await _database
          .into(_database.gameMoves)
          .insert(
            GameMovesCompanion.insert(
              gameId: gameId,
              ply: ply,
              san: san,
              fromSquare: from,
              toSquare: to,
              playedAt: now,
            ),
          );
      await (_database.update(
        _database.games,
      )..where((game) => game.id.equals(gameId))).write(
        GamesCompanion(
          updatedAt: Value(now),
          fen: Value(fen),
          status: Value(isFinished ? 'finished' : 'in_progress'),
          outcome: Value(outcome),
        ),
      );
    });
  }

  Future<void> truncateMoves({
    required int gameId,
    required int keepThroughPly,
    required String fen,
  }) async {
    final now = DateTime.now();
    await _database.transaction(() async {
      await (_database.delete(_database.gameMoves)..where(
            (move) =>
                move.gameId.equals(gameId) &
                move.ply.isBiggerThanValue(keepThroughPly),
          ))
          .go();
      await (_database.update(
        _database.games,
      )..where((game) => game.id.equals(gameId))).write(
        GamesCompanion(
          updatedAt: Value(now),
          fen: Value(fen),
          status: const Value('in_progress'),
          outcome: const Value(null),
        ),
      );
    });
  }

  Future<void> finishGame({
    required int gameId,
    required String outcome,
  }) async {
    await (_database.update(
      _database.games,
    )..where((game) => game.id.equals(gameId))).write(
      GamesCompanion(
        updatedAt: Value(DateTime.now()),
        status: const Value('finished'),
        outcome: Value(outcome),
      ),
    );
  }
}
