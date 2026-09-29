import 'package:flutter/foundation.dart';

import '../domain/chess_models.dart';
import '../domain/medium_chess_ai.dart';

/// Replaceable boundary for local, remote, or platform-backed chess engines.
abstract interface class ChessOpponent {
  Future<String?> chooseMove({
    required String fen,
    required ChessDifficulty difficulty,
  });
}

class AlphaBetaChessOpponent implements ChessOpponent {
  const AlphaBetaChessOpponent();

  @override
  Future<String?> chooseMove({
    required String fen,
    required ChessDifficulty difficulty,
  }) {
    return compute(chooseComputerMove, <Object>[
      fen,
      difficulty.searchDepth,
    ], debugLabel: 'catur-${difficulty.name}-ai');
  }
}
