import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('GameRow')
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get mode => text()();
  TextColumn get difficulty => text()();
  TextColumn get playerColor => text()();
  TextColumn get fen => text()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  TextColumn get outcome => text().nullable()();
}

@DataClassName('MoveRow')
class GameMoves extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get ply => integer()();
  TextColumn get san => text()();
  TextColumn get fromSquare => text()();
  TextColumn get toSquare => text()();
  DateTimeColumn get playedAt => dateTime()();
}

@DriftDatabase(tables: [Games, GameMoves])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'catur_mate'));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createCampaignTables();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await _createCampaignTables();
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createCampaignTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS campaign_progress (
        campaign_id TEXT PRIMARY KEY NOT NULL,
        unlocked_level INTEGER NOT NULL DEFAULT 1,
        completed_level INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS campaign_game_configs (
        game_id INTEGER PRIMARY KEY NOT NULL REFERENCES games(id) ON DELETE CASCADE,
        campaign_id TEXT NOT NULL,
        level INTEGER NOT NULL,
        temporary_power_one TEXT NOT NULL,
        temporary_power_two TEXT
      )
    ''');
  }
}
