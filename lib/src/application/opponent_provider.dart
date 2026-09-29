import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chess_opponent.dart';

final chessOpponentProvider = Provider<ChessOpponent>(
  (ref) => const AlphaBetaChessOpponent(),
);
