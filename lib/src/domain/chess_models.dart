import 'package:chess/chess.dart' as chess;

import 'power_campaign.dart';

enum GameMode { computer, local, campaign }

enum ChessDifficulty {
  easy,
  medium,
  hard;

  int get searchDepth => switch (this) {
    ChessDifficulty.easy => 2,
    ChessDifficulty.medium => 3,
    ChessDifficulty.hard => 4,
  };

  String get label => switch (this) {
    ChessDifficulty.easy => 'Mudah',
    ChessDifficulty.medium => 'Sedang',
    ChessDifficulty.hard => 'Sulit',
  };
}

class PlayedMove {
  const PlayedMove({
    required this.ply,
    required this.san,
    required this.from,
    required this.to,
  });

  final int ply;
  final String san;
  final String from;
  final String to;
}

class GameUiState {
  const GameUiState({
    required this.fen,
    this.gameId,
    this.mode = GameMode.computer,
    this.difficulty = ChessDifficulty.medium,
    this.playerColor = chess.Chess.WHITE,
    this.turn = chess.Chess.WHITE,
    this.moves = const [],
    this.selectedSquare,
    this.legalTargets = const {},
    this.checkedKingSquare,
    this.isThinking = false,
    this.isFinished = false,
    this.outcome,
    this.campaignConfig,
  });

  factory GameUiState.initial() =>
      const GameUiState(fen: chess.Chess.DEFAULT_POSITION);

  final int? gameId;
  final GameMode mode;
  final ChessDifficulty difficulty;
  final chess.Color playerColor;
  final chess.Color turn;
  final String fen;
  final List<PlayedMove> moves;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final String? checkedKingSquare;
  final bool isThinking;
  final bool isFinished;
  final String? outcome;
  final CampaignGameConfig? campaignConfig;

  bool get canUndo => moves.isNotEmpty && !isThinking;

  String get modeLabel => switch (mode) {
    GameMode.computer => 'Lawan komputer',
    GameMode.local => 'Teman lokal',
    GameMode.campaign => 'Power Gift Campaign',
  };

  GameUiState copyWith({
    int? gameId,
    GameMode? mode,
    ChessDifficulty? difficulty,
    chess.Color? playerColor,
    chess.Color? turn,
    String? fen,
    List<PlayedMove>? moves,
    String? selectedSquare,
    Set<String>? legalTargets,
    String? checkedKingSquare,
    bool? isThinking,
    bool? isFinished,
    String? outcome,
    CampaignGameConfig? campaignConfig,
    bool clearSelection = false,
    bool clearCheckedKing = false,
    bool clearOutcome = false,
  }) {
    return GameUiState(
      gameId: gameId ?? this.gameId,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      playerColor: playerColor ?? this.playerColor,
      turn: turn ?? this.turn,
      fen: fen ?? this.fen,
      moves: moves ?? this.moves,
      selectedSquare: clearSelection
          ? null
          : selectedSquare ?? this.selectedSquare,
      legalTargets: clearSelection
          ? const {}
          : legalTargets ?? this.legalTargets,
      checkedKingSquare: clearCheckedKing
          ? null
          : checkedKingSquare ?? this.checkedKingSquare,
      isThinking: isThinking ?? this.isThinking,
      isFinished: isFinished ?? this.isFinished,
      outcome: clearOutcome ? null : outcome ?? this.outcome,
      campaignConfig: campaignConfig ?? this.campaignConfig,
    );
  }
}
