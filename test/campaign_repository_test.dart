import 'package:catur_mate/src/data/local/app_database.dart';
import 'package:catur_mate/src/data/repositories/chess_game_repository.dart';
import 'package:catur_mate/src/domain/power_campaign.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late ChessGameRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ChessGameRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('initializes progress for each campaign', () async {
    final progress = await repository.getAllCampaignProgress([
      'kanibal',
      'memperpanjang',
    ]);

    expect(progress, hasLength(2));
    expect(progress[0].campaignId, 'kanibal');
    expect(progress[0].unlockedLevel, 1);
    expect(progress[0].completedLevel, 0);
    expect(progress[1].campaignId, 'memperpanjang');
  });

  test('stores campaign loadout and unlocks the next level', () async {
    const config = CampaignGameConfig(
      campaignId: 'kanibal',
      level: 1,
      temporaryPowers: [TemporaryPower.extraPawn, TemporaryPower.kamikaze],
    );
    final gameId = await repository.createGame(
      mode: 'campaign',
      difficulty: 'easy',
      playerColor: 'white',
      fen: 'initial-position',
      campaignConfig: config,
    );

    final saved = await repository.loadGame(gameId);
    expect(saved?.campaignConfig?.campaignId, 'kanibal');
    expect(saved?.campaignConfig?.level, 1);
    expect(saved?.campaignConfig?.temporaryPowers, config.temporaryPowers);

    await repository.completeCampaignLevel('kanibal', 1);
    final progress = await repository.getCampaignProgress('kanibal');
    expect(progress.completedLevel, 1);
    expect(progress.unlockedLevel, 2);
  });
}
