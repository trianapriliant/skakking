import 'dart:async';

import 'package:chess/chess.dart' as chess;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/chess_game_repository.dart';
import '../domain/chess_models.dart';
import '../domain/power_campaign.dart';
import 'chess_opponent.dart';
import 'data_providers.dart';
import 'opponent_provider.dart';

class GameController extends Notifier<GameUiState> {
  late ChessGameRepository _repository;
  late ChessOpponent _opponent;
  chess.Chess _game = chess.Chess();
  final List<PlayedMove> _moves = [];
  int? _gameId;
  GameMode _mode = GameMode.computer;
  ChessDifficulty _difficulty = ChessDifficulty.medium;
  chess.Color _playerColor = chess.Chess.WHITE;
  CampaignGameConfig? _campaignConfig;
  bool _campaignRewardStored = false;
  String? _resignedOutcome;
  int _generation = 0;

  @override
  GameUiState build() {
    _repository = ref.watch(chessGameRepositoryProvider);
    _opponent = ref.watch(chessOpponentProvider);
    return GameUiState.initial();
  }

  Future<int> startGame({
    required GameMode mode,
    required ChessDifficulty difficulty,
    required chess.Color playerColor,
    CampaignGameConfig? campaignConfig,
  }) async {
    _generation++;
    _game = chess.Chess();
    _moves.clear();
    _mode = mode;
    _difficulty = difficulty;
    _playerColor = playerColor;
    _campaignConfig = campaignConfig;
    _campaignRewardStored = false;
    _resignedOutcome = null;
    _gameId = await _repository.createGame(
      mode: mode.name,
      difficulty: difficulty.name,
      playerColor: _colorName(playerColor),
      fen: _game.fen,
      campaignConfig: campaignConfig,
    );
    state = _snapshot();

    if (_isComputerTurn) await _playComputerMove();
    return _gameId!;
  }

  Future<bool> loadGame(int gameId) async {
    final saved = await _repository.loadGame(gameId);
    if (saved == null) return false;

    _generation++;
    _game = chess.Chess();
    _moves
      ..clear()
      ..addAll(
        saved.moves.map(
          (move) => PlayedMove(
            ply: move.ply,
            san: move.san,
            from: move.fromSquare,
            to: move.toSquare,
          ),
        ),
      );
    for (final move in saved.moves) {
      if (!_game.move(move.san)) {
        _game = chess.Chess.fromFEN(saved.game.fen);
        break;
      }
    }

    _gameId = saved.game.id;
    _mode = GameMode.values.firstWhere(
      (mode) => mode.name == saved.game.mode,
      orElse: () => GameMode.computer,
    );
    _difficulty = ChessDifficulty.values.firstWhere(
      (difficulty) => difficulty.name == saved.game.difficulty,
      orElse: () => ChessDifficulty.medium,
    );
    _playerColor = saved.game.playerColor == 'black'
        ? chess.Chess.BLACK
        : chess.Chess.WHITE;
    _campaignConfig = saved.campaignConfig;
    _campaignRewardStored = false;
    _resignedOutcome = saved.game.outcome?.endsWith('_resigned') == true
        ? saved.game.outcome
        : null;
    state = _snapshot();

    if (!state.isFinished && _isComputerTurn) await _playComputerMove();
    return true;
  }

  void tapSquare(String square) {
    if (!_canPlayTurn) return;

    final selected = state.selectedSquare;
    if (selected != null && state.legalTargets.contains(square)) {
      // The screen asks the player to choose a promotion piece before calling
      // playMove when the destination promotes a pawn.
      unawaited(playMove(selected, square));
      return;
    }

    if (selected == square) {
      state = state.copyWith(clearSelection: true);
      return;
    }

    final piece = _game.get(square);
    if (piece == null || piece.color != _game.turn) {
      state = state.copyWith(clearSelection: true);
      return;
    }

    final rawMoves = _game.moves({'square': square, 'verbose': true});
    final targets = rawMoves
        .map((move) => (move as Map)['to'] as String)
        .toSet();
    state = state.copyWith(selectedSquare: square, legalTargets: targets);
  }

  List<String> promotionChoices(String from, String to) {
    final moves = _game.moves({'square': from, 'verbose': true});
    return moves
        .where((move) => (move as Map)['to'] == to && move['promotion'] != null)
        .map((move) => (move as Map)['promotion'] as String)
        .toList();
  }

  Future<void> playMove(
    String from,
    String to, {
    String promotion = 'q',
  }) async {
    if (!_canPlayTurn) return;
    final generation = _generation;
    await _applyMove(from, to, promotion: promotion);
    if (generation != _generation) return;
    if (_isComputerTurn) await _playComputerMove();
  }

  Future<void> undoTurn() async {
    if (!state.canUndo) return;
    _resignedOutcome = null;

    final pliesToUndo =
        (_mode == GameMode.computer || _mode == GameMode.campaign) &&
            _moves.length >= 2
        ? 2
        : 1;
    for (var i = 0; i < pliesToUndo; i++) {
      if (_game.undo() == null) break;
      _moves.removeLast();
    }
    state = _snapshot();
    final id = _gameId;
    if (id != null) {
      await _repository.truncateMoves(
        gameId: id,
        keepThroughPly: _moves.isEmpty ? 0 : _moves.last.ply,
        fen: _game.fen,
      );
    }
  }

  Future<void> resign() async {
    if (state.isFinished || state.isThinking) return;
    _resignedOutcome = '${_colorName(_game.turn)}_resigned';
    state = _snapshot();
    final id = _gameId;
    if (id != null) {
      await _repository.finishGame(gameId: id, outcome: _resignedOutcome!);
    }
  }

  Future<void> _applyMove(
    String from,
    String to, {
    required String promotion,
  }) async {
    final accepted = _game.move({
      'from': from,
      'to': to,
      'promotion': promotion,
    });
    if (accepted != true) return;

    final history = _game.getHistory();
    final san = history.isEmpty ? '$from$to' : history.last as String;
    final record = PlayedMove(
      ply: _moves.length + 1,
      san: san,
      from: from,
      to: to,
    );
    _moves.add(record);
    state = _snapshot();

    final id = _gameId;
    if (id != null) {
      await _repository.recordMove(
        gameId: id,
        ply: record.ply,
        san: record.san,
        from: record.from,
        to: record.to,
        fen: _game.fen,
        isFinished: state.isFinished,
        outcome: state.outcome,
      );
    }
    if (state.isFinished &&
        !_campaignRewardStored &&
        _campaignConfig != null &&
        state.outcome == '${_colorName(_playerColor)}_win') {
      _campaignRewardStored = true;
      await _repository.completeCampaignLevel(
        _campaignConfig!.campaignId,
        _campaignConfig!.level,
      );
    }
  }

  Future<void> _playComputerMove() async {
    if (!_isComputerTurn || state.isFinished) return;
    final generation = _generation;
    final fen = _game.fen;
    state = _snapshot(isThinking: true);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    String? encoded;
    try {
      encoded = await _opponent.chooseMove(fen: fen, difficulty: _difficulty);
    } catch (_) {
      if (generation == _generation) state = _snapshot();
      return;
    }
    if (generation != _generation) return;
    if (encoded == null || state.isFinished) {
      state = _snapshot();
      return;
    }

    final parts = encoded.split('|');
    if (parts.length != 3) {
      state = _snapshot();
      return;
    }
    await _applyMove(
      parts[0],
      parts[1],
      promotion: parts[2].isEmpty ? 'q' : parts[2],
    );
    state = _snapshot();
  }

  bool get _isComputerTurn =>
      (_mode == GameMode.computer || _mode == GameMode.campaign) &&
      _game.turn != _playerColor &&
      !_game.game_over;

  bool get _canPlayTurn =>
      _gameId != null &&
      !state.isFinished &&
      !state.isThinking &&
      (_mode == GameMode.local || _game.turn == _playerColor);

  GameUiState _snapshot({bool isThinking = false}) {
    final checkedKing = _game.in_check
        ? chess.Chess.algebraic(_game.kings[_game.turn])
        : null;
    final outcome = _resignedOutcome ?? _engineOutcome();
    return GameUiState(
      gameId: _gameId,
      mode: _mode,
      difficulty: _difficulty,
      playerColor: _playerColor,
      turn: _game.turn,
      fen: _game.fen,
      moves: List.unmodifiable(_moves),
      checkedKingSquare: checkedKing,
      isThinking: isThinking,
      isFinished: _resignedOutcome != null || _game.game_over,
      outcome: outcome,
      campaignConfig: _campaignConfig,
    );
  }

  String? _engineOutcome() {
    if (_game.in_checkmate) {
      final winner = _game.turn == chess.Chess.WHITE
          ? chess.Chess.BLACK
          : chess.Chess.WHITE;
      return '${_colorName(winner)}_win';
    }
    if (_game.in_draw) return 'draw';
    return null;
  }

  String _colorName(chess.Color color) =>
      color == chess.Chess.WHITE ? 'white' : 'black';
}
