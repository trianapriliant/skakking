import 'package:chess/chess.dart' as chess;

/// A compact alpha-beta opponent. The rules package remains the authority for
/// legal moves; this class only orders moves and evaluates resulting positions.
String? chooseComputerMove(List<Object> arguments) {
  final fen = arguments[0] as String;
  final depth = arguments[1] as int;
  final game = chess.Chess.fromFEN(fen);
  final moves = _orderedMoves(game.moves({'verbose': true}));
  if (moves.isEmpty) return null;

  final maximizing = game.turn == chess.Chess.WHITE;
  var bestScore = maximizing ? -_mateScore : _mateScore;
  Map<String, dynamic>? bestMove;
  var alpha = -_mateScore;
  var beta = _mateScore;

  for (final move in moves) {
    if (!game.move(_moveArguments(move))) continue;
    final score = _search(game, depth - 1, alpha, beta, 1);
    game.undo();

    if ((maximizing && score > bestScore) ||
        (!maximizing && score < bestScore)) {
      bestScore = score;
      bestMove = move;
    }
    if (maximizing) {
      if (score > alpha) alpha = score;
    } else if (score < beta) {
      beta = score;
    }
  }

  if (bestMove == null) return null;
  return '${bestMove['from']}|${bestMove['to']}|${_pieceCode(bestMove['promotion']) ?? ''}';
}

const int _mateScore = 100000;
const Map<String, int> _pieceValues = {
  'p': 100,
  'n': 320,
  'b': 335,
  'r': 500,
  'q': 900,
  'k': 0,
};

int _search(chess.Chess game, int depth, int alpha, int beta, int ply) {
  if (game.in_checkmate) {
    return game.turn == chess.Chess.WHITE
        ? -_mateScore + ply
        : _mateScore - ply;
  }
  if (game.in_draw) return 0;
  if (depth <= 0) return _evaluate(game);

  final moves = _orderedMoves(game.moves({'verbose': true}));
  if (moves.isEmpty) return _evaluate(game);

  final maximizing = game.turn == chess.Chess.WHITE;
  if (maximizing) {
    var value = -_mateScore;
    for (final move in moves) {
      if (!game.move(_moveArguments(move))) continue;
      final score = _search(game, depth - 1, alpha, beta, ply + 1);
      game.undo();
      if (score > value) value = score;
      if (value > alpha) alpha = value;
      if (alpha >= beta) break;
    }
    return value;
  }

  var value = _mateScore;
  for (final move in moves) {
    if (!game.move(_moveArguments(move))) continue;
    final score = _search(game, depth - 1, alpha, beta, ply + 1);
    game.undo();
    if (score < value) value = score;
    if (value < beta) beta = value;
    if (alpha >= beta) break;
  }
  return value;
}

int _evaluate(chess.Chess game) {
  var score = 0;
  var nonPawnMaterial = 0;
  var whiteBishops = 0;
  var blackBishops = 0;

  for (var rank = 1; rank <= 8; rank++) {
    for (var file = 0; file < 8; file++) {
      final square = '${String.fromCharCode(97 + file)}$rank';
      final piece = game.get(square);
      if (piece == null || piece.type.name == 'p' || piece.type.name == 'k') {
        continue;
      }
      nonPawnMaterial += _pieceValues[piece.type.name] ?? 0;
    }
  }

  for (var rank = 1; rank <= 8; rank++) {
    for (var file = 0; file < 8; file++) {
      final square = '${String.fromCharCode(97 + file)}$rank';
      final piece = game.get(square);
      if (piece == null) continue;

      final white = piece.color == chess.Chess.WHITE;
      final sign = white ? 1 : -1;
      final kind = piece.type.name;
      final material = _pieceValues[kind] ?? 0;
      score += sign * material;
      if (kind == 'b') {
        if (white) {
          whiteBishops++;
        } else {
          blackBishops++;
        }
      }

      final centerDistance = (file - 3.5).abs() + (rank - 4.5).abs();
      final centerBonus = ((7 - centerDistance).clamp(0, 7) * 3).round();
      switch (kind) {
        case 'p':
          final advancement = white ? rank - 2 : 7 - rank;
          score += sign * (advancement * 8 + centerBonus ~/ 3);
        case 'n':
          score += sign * centerBonus * 2;
        case 'b':
          score += sign * centerBonus;
        case 'q':
          score += sign * (centerBonus ~/ 2);
        case 'k':
          // Keep the king tucked away in the opening and bring it forward in
          // simplified endgames.
          score += sign * (nonPawnMaterial < 1800 ? centerBonus : -centerBonus);
      }
    }
  }

  if (whiteBishops >= 2) score += 24;
  if (blackBishops >= 2) score -= 24;
  return score;
}

List<Map<String, dynamic>> _orderedMoves(List<dynamic> rawMoves) {
  final moves = rawMoves
      .map((move) => Map<String, dynamic>.from(move as Map))
      .toList();
  moves.sort(
    (left, right) => _moveOrderValue(right).compareTo(_moveOrderValue(left)),
  );
  return moves;
}

int _moveOrderValue(Map<String, dynamic> move) {
  final capture = _pieceCode(move['captured']);
  final promotion = _pieceCode(move['promotion']);
  final capturedValue = capture == null ? 0 : (_pieceValues[capture] ?? 0);
  final promotionValue = promotion == null ? 0 : (_pieceValues[promotion] ?? 0);
  return (capture == null
          ? 0
          : 10 * capturedValue -
                (_pieceValues[_pieceCode(move['piece'])] ?? 0)) +
      promotionValue;
}

String? _pieceCode(Object? value) => switch (value) {
  String code => code,
  chess.PieceType piece => piece.name,
  _ => null,
};

Map<String, Object?> _moveArguments(Map<String, dynamic> move) {
  final promotion = _pieceCode(move['promotion']);
  return {'from': move['from'], 'to': move['to'], 'promotion': ?promotion};
}
