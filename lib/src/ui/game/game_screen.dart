import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers.dart';
import '../../domain/chess_models.dart';
import '../../domain/power_campaign.dart';
import '../theme/app_theme.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _is2d = false;

  void _toggleBoardPerspective() => setState(() => _is2d = !_is2d);

  Future<void> _pauseGame() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Permainan dijeda'),
      content: const Text('Lanjutkan pertandingan atau kembali ke beranda.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Lanjut bermain'),
        ),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.go('/');
          },
          icon: const Icon(Icons.home_outlined),
          label: const Text('Beranda'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final viewport = MediaQuery.sizeOf(context);
    final viewportWidth = viewport.width;
    final wideLayout =
        viewportWidth >= 920 ||
        (viewportWidth >= 700 && viewportWidth > viewport.height * 1.3);

    return Scaffold(
      backgroundColor: const Color(0xFFB79872),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: wideLayout
                ? _wideLayout(game)
                : _compactLayout(game, viewportWidth),
          ),
        ),
      ),
    );
  }

  Widget _compactLayout(GameUiState game, double viewportWidth) {
    final boardWidth = (viewportWidth - 32).clamp(280.0, 560.0);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Center(
        child: SizedBox(
          width: boardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GameTopBar(game: game, onBack: () => context.go('/')),
              const SizedBox(height: 17),
              _GameBoardPanel(
                game: game,
                onSquareTap: _handleSquareTap,
                is2d: _is2d,
                onToggle2d: _toggleBoardPerspective,
                onPause: _pauseGame,
              ),
              const SizedBox(height: 13),
              _GameControls(game: game, onHome: () => context.go('/')),
              if (_isCampaignWin(game)) ...[
                const SizedBox(height: 9),
                _CampaignContinueButton(
                  config: game.campaignConfig!,
                  completedLevel: game.campaignConfig!.level,
                  onTap: () => context.go(
                    '/campaign/${game.campaignConfig!.campaignId}',
                  ),
                ),
              ],
              const SizedBox(height: 13),
              _MoveListPanel(game: game, height: 190),
              const SizedBox(height: 16),
              const _GameFootnote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wideLayout(GameUiState game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 24),
      child: Column(
        children: [
          _GameTopBar(game: game, onBack: () => context.go('/')),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _GameBoardPanel(
                        game: game,
                        onSquareTap: _handleSquareTap,
                        is2d: _is2d,
                        onToggle2d: _toggleBoardPerspective,
                        onPause: _pauseGame,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 26),
                Expanded(
                  flex: 4,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 350),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _GameControls(
                          game: game,
                          onHome: () => context.go('/'),
                        ),
                        if (_isCampaignWin(game)) ...[
                          const SizedBox(height: 9),
                          _CampaignContinueButton(
                            config: game.campaignConfig!,
                            completedLevel: game.campaignConfig!.level,
                            onTap: () => context.go(
                              '/campaign/${game.campaignConfig!.campaignId}',
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        _MoveListPanel(game: game, height: 320),
                        const SizedBox(height: 14),
                        const _GameFootnote(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSquareTap(String square, GameUiState game) async {
    final controller = ref.read(gameControllerProvider.notifier);
    final from = game.selectedSquare;
    if (from != null && game.legalTargets.contains(square)) {
      final choices = controller.promotionChoices(from, square);
      if (choices.isNotEmpty) {
        final choice = await _choosePromotion(game.turn, choices);
        if (choice == null || !mounted) return;
        await controller.playMove(from, square, promotion: choice);
        return;
      }
      await controller.playMove(from, square);
      return;
    }

    controller.tapSquare(square);
  }

  bool _isCampaignWin(GameUiState game) =>
      game.isFinished &&
      game.campaignConfig != null &&
      game.outcome ==
          (game.playerColor == chess.Chess.WHITE ? 'white_win' : 'black_win');

  Future<String?> _choosePromotion(chess.Color color, List<String> choices) {
    const glyphs = {
      'q': {'white': '♕', 'black': '♛'},
      'r': {'white': '♖', 'black': '♜'},
      'b': {'white': '♗', 'black': '♝'},
      'n': {'white': '♘', 'black': '♞'},
    };
    final side = color == chess.Chess.WHITE ? 'white' : 'black';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih buah promosi'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final choice in choices)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).pop(choice),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Column(
                      children: [
                        Text(
                          glyphs[choice]![side]!,
                          style: const TextStyle(fontSize: 37, height: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Text(switch (choice) {
                          'q' => 'Ratu',
                          'r' => 'Benteng',
                          'b' => 'Gajah',
                          _ => 'Kuda',
                        }, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GameTopBar extends StatelessWidget {
  const _GameTopBar({required this.game, required this.onBack});

  final GameUiState game;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          tooltip: 'Kembali ke beranda',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 11),
        const _KnightBadge(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.modeLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                game.mode == GameMode.campaign && game.campaignConfig != null
                    ? 'LEVEL ${game.campaignConfig!.level} · POWER GIFT'
                    : game.mode == GameMode.computer
                    ? 'TINGKAT ${game.difficulty.label.toUpperCase()}'
                    : 'CATUR KLASIK',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 13,
                color: AppColors.forest,
              ),
              const SizedBox(width: 5),
              Text(
                'OFFLINE',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KnightBadge extends StatelessWidget {
  const _KnightBadge();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.forest,
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      '♞',
      style: TextStyle(color: AppColors.lime, fontSize: 25, height: 1),
    ),
  );
}

class _GameBoardPanel extends StatelessWidget {
  const _GameBoardPanel({
    required this.game,
    required this.onSquareTap,
    required this.is2d,
    required this.onToggle2d,
    required this.onPause,
  });

  final GameUiState game;
  final Future<void> Function(String square, GameUiState game) onSquareTap;
  final bool is2d;
  final VoidCallback onToggle2d;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final orientation = game.playerColor;
    final opponentColor = orientation == chess.Chess.WHITE
        ? chess.Chess.BLACK
        : chess.Chess.WHITE;
    final isFlipped = orientation == chess.Chess.BLACK;
    final engine = chess.Chess.fromFEN(game.fen);
    final againstComputer =
        game.mode == GameMode.computer || game.mode == GameMode.campaign;
    final ownName = againstComputer ? 'Kamu' : _colorName(orientation);
    final opponentName = againstComputer
        ? 'Komputer'
        : _colorName(opponentColor);

    return Column(
      children: [
        _PlayerStrip(
          color: opponentColor,
          name: opponentName,
          subtitle:
              game.mode == GameMode.campaign && game.campaignConfig != null
              ? 'Level ${game.campaignConfig!.level} · ${game.difficulty.label}'
              : againstComputer
              ? game.difficulty.label
              : 'Pemain',
          isTurn:
              !game.isFinished &&
              !game.isThinking &&
              game.turn == opponentColor,
          thinking: game.isThinking,
        ),
        const SizedBox(height: 9),
        LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth.clamp(270.0, 600.0);
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(is2d ? 0 : 0.11),
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA77B50), Color(0xFF593A27)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF42291D), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x70311F16),
                      blurRadius: 18,
                      offset: Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Color(0x55FFF0D2),
                      blurRadius: 1,
                      offset: Offset(-2, -2),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38261B),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: 64,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                          ),
                      itemBuilder: (context, index) {
                        final row = index ~/ 8;
                        final column = index % 8;
                        final rank = isFlipped ? row + 1 : 8 - row;
                        final fileIndex = isFlipped ? 7 - column : column;
                        final file = String.fromCharCode(97 + fileIndex);
                        final square = '$file$rank';
                        final piece = engine.get(square);
                        final isLight = (fileIndex + rank).isEven;
                        final isLastMove =
                            game.moves.isNotEmpty &&
                            (game.moves.last.from == square ||
                                game.moves.last.to == square);
                        final isSelected = game.selectedSquare == square;
                        final checked = game.checkedKingSquare == square;
                        final canLand = game.legalTargets.contains(square);
                        final background = checked
                            ? const Color(0xFFE89777)
                            : isSelected
                            ? AppColors.selected
                            : isLastMove
                            ? AppColors.lastMove
                            : isLight
                            ? AppColors.lightSquare
                            : AppColors.darkSquare;

                        return Semantics(
                          button: true,
                          label:
                              '$square${piece == null ? '' : ', ${_pieceName(piece.type.name, piece.color)}'}',
                          child: GestureDetector(
                            onTap: () => onSquareTap(square, game),
                            child: ColoredBox(
                              color: background,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (canLand)
                                    Center(
                                      child: piece == null
                                          ? Container(
                                              width: size / 8 * 0.25,
                                              height: size / 8 * 0.25,
                                              decoration: BoxDecoration(
                                                color: AppColors.legalMove,
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.legalMove,
                                                  width: 4,
                                                ),
                                              ),
                                            ),
                                    ),
                                  if (piece != null)
                                    Center(
                                      child: Text(
                                        _pieceGlyph(
                                          piece.type.name,
                                          piece.color,
                                        ),
                                        style: TextStyle(
                                          fontFamily: 'Noto Sans Symbols 2',
                                          fontSize: size / 8 * 0.82,
                                          height: 1,
                                          color:
                                              piece.color == chess.Chess.WHITE
                                              ? const Color(0xFFFFF5DB)
                                              : const Color(0xFF2D3439),
                                          shadows:
                                              piece.color == chess.Chess.WHITE
                                              ? const [
                                                  Shadow(
                                                    color: Color(0xA02A1B10),
                                                    blurRadius: 3,
                                                    offset: Offset(1, 3),
                                                  ),
                                                  Shadow(
                                                    color: Color(0x44FFFFFF),
                                                    blurRadius: 1,
                                                    offset: Offset(-1, -1),
                                                  ),
                                                ]
                                              : const [
                                                  Shadow(
                                                    color: Color(0x66502012),
                                                    blurRadius: 2,
                                                    offset: Offset(1, 2),
                                                  ),
                                                ],
                                        ),
                                      ),
                                    ),
                                  if ((!isFlipped && column == 0) ||
                                      (isFlipped && column == 7))
                                    Positioned(
                                      left: 3,
                                      top: 2,
                                      child: Text(
                                        '$rank',
                                        style: TextStyle(
                                          fontSize: 9,
                                          height: 1,
                                          fontWeight: FontWeight.w800,
                                          color: isLight
                                              ? AppColors.darkSquare
                                              : AppColors.lightSquare,
                                        ),
                                      ),
                                    ),
                                  if (row == 7)
                                    Positioned(
                                      right: 3,
                                      bottom: 2,
                                      child: Text(
                                        file,
                                        style: TextStyle(
                                          fontSize: 9,
                                          height: 1,
                                          fontWeight: FontWeight.w800,
                                          color: isLight
                                              ? AppColors.darkSquare
                                              : AppColors.lightSquare,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 9),
        _PlayerStrip(
          color: orientation,
          name: ownName,
          subtitle: againstComputer ? 'Pemain' : 'Giliran bermain',
          isTurn:
              !game.isFinished && !game.isThinking && game.turn == orientation,
          thinking: false,
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onToggle2d,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF69472F),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFB59067)),
                minimumSize: const Size(72, 38),
                padding: const EdgeInsets.symmetric(horizontal: 11),
              ),
              icon: const Icon(Icons.view_in_ar_rounded, size: 17),
              label: Text(is2d ? '3D' : '2D'),
            ),
            const Spacer(),
            IconButton.filledTonal(
              onPressed: onPause,
              tooltip: 'Jeda',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF69472F),
                foregroundColor: Colors.white,
                minimumSize: const Size(40, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.pause_rounded, size: 20),
            ),
          ],
        ),
        if (game.campaignConfig != null) ...[
          const SizedBox(height: 8),
          _CampaignLoadoutBanner(config: game.campaignConfig!),
        ],
        const SizedBox(height: 9),
        _TurnBanner(game: game),
      ],
    );
  }

  String _colorName(chess.Color color) =>
      color == chess.Chess.WHITE ? 'Putih' : 'Hitam';

  String _pieceName(String type, chess.Color color) {
    final kind = switch (type) {
      'p' => 'Pion',
      'n' => 'Kuda',
      'b' => 'Gajah',
      'r' => 'Benteng',
      'q' => 'Ratu',
      _ => 'Raja',
    };
    return '${color == chess.Chess.WHITE ? 'putih' : 'hitam'} $kind';
  }

  String _pieceGlyph(String type, chess.Color color) {
    final pieces = color == chess.Chess.WHITE
        ? const {'p': '♙', 'n': '♘', 'b': '♗', 'r': '♖', 'q': '♕', 'k': '♔'}
        : const {'p': '♟', 'n': '♞', 'b': '♝', 'r': '♜', 'q': '♛', 'k': '♚'};
    return pieces[type] ?? '';
  }
}

class _PlayerStrip extends StatelessWidget {
  const _PlayerStrip({
    required this.color,
    required this.name,
    required this.subtitle,
    required this.isTurn,
    required this.thinking,
  });

  final chess.Color color;
  final String name;
  final String subtitle;
  final bool isTurn;
  final bool thinking;

  @override
  Widget build(BuildContext context) {
    final isWhite = color == chess.Chess.WHITE;
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isWhite ? AppColors.surface : AppColors.ink,
            borderRadius: BorderRadius.circular(11),
            border: isWhite ? Border.all(color: AppColors.line) : null,
          ),
          child: Text(
            isWhite ? '♔' : '♚',
            style: TextStyle(
              fontSize: 22,
              height: 1,
              color: isWhite ? AppColors.ink : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (thinking)
          Row(
            children: [
              const SizedBox.square(
                dimension: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 6),
              Text(
                'Berpikir',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
            ],
          )
        else if (isTurn)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'GILIRAN',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.forest,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.game});

  final GameUiState game;

  @override
  Widget build(BuildContext context) {
    final text = _statusText(game);
    final isFinished = game.isFinished;
    final inCheck = game.checkedKingSquare != null && !isFinished;
    final color = isFinished
        ? AppColors.forest
        : inCheck
        ? AppColors.danger
        : AppColors.forest;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: isFinished ? const Color(0xFFEAF1E7) : AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isFinished ? const Color(0xFFD8E4D2) : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          Icon(
            game.isThinking
                ? Icons.more_horiz_rounded
                : isFinished
                ? Icons.emoji_events_outlined
                : inCheck
                ? Icons.warning_amber_rounded
                : Icons.circle,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 12),
            ),
          ),
          Text(
            '${(game.moves.length + 1) ~/ 2}',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(width: 4),
          Text(
            'LANGKAH',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 8, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }

  String _statusText(GameUiState game) {
    if (game.isThinking) return 'Komputer sedang berpikir…';
    if (game.isFinished) {
      return switch (game.outcome) {
        'draw' => 'Remis — permainan berakhir seri.',
        'white_win' =>
          game.playerColor == chess.Chess.WHITE
              ? 'Skakmat — kamu menang!'
              : 'Skakmat — putih menang.',
        'black_win' =>
          game.playerColor == chess.Chess.BLACK
              ? 'Skakmat — kamu menang!'
              : 'Skakmat — hitam menang.',
        'white_resigned' =>
          game.mode == GameMode.computer &&
                  game.playerColor == chess.Chess.WHITE
              ? 'Kamu menyerah. Coba lagi kapan saja.'
              : 'Putih menyerah. Hitam menang.',
        'black_resigned' =>
          game.mode == GameMode.computer &&
                  game.playerColor == chess.Chess.BLACK
              ? 'Kamu menyerah. Coba lagi kapan saja.'
              : 'Hitam menyerah. Putih menang.',
        _ => 'Permainan selesai.',
      };
    }
    if (game.checkedKingSquare != null) return 'Skak! Lindungi raja kamu.';
    final turnColor = game.turn == chess.Chess.WHITE ? 'Putih' : 'Hitam';
    if (game.mode == GameMode.local) return 'Giliran $turnColor bergerak.';
    return game.turn == game.playerColor
        ? 'Giliranmu untuk bergerak.'
        : 'Komputer melangkah berikutnya.';
  }
}

class _CampaignLoadoutBanner extends StatelessWidget {
  const _CampaignLoadoutBanner({required this.config});

  final CampaignGameConfig config;

  @override
  Widget build(BuildContext context) {
    final campaign = config.campaign;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D8B7)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${campaign.power.symbol} ${campaign.power.label}',
            style: const TextStyle(
              color: Color(0xFF74502F),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text('·', style: TextStyle(color: AppColors.muted)),
          for (var i = 0; i < config.temporaryPowers.length; i++) ...[
            if (i > 0)
              const Text('·', style: TextStyle(color: AppColors.muted)),
            Text(
              config.temporaryPowers[i].label,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CampaignContinueButton extends StatelessWidget {
  const _CampaignContinueButton({
    required this.config,
    required this.completedLevel,
    required this.onTap,
  });

  final CampaignGameConfig config;
  final int completedLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF815B3D),
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.emoji_events_outlined, size: 18),
      label: Text(
        completedLevel < 8
            ? 'Menang · lanjut ke level berikutnya'
            : 'Campaign selesai · lihat progres',
      ),
    ),
  );
}

class _GameControls extends ConsumerWidget {
  const _GameControls({required this.game, required this.onHome});

  final GameUiState game;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: game.canUndo ? controller.undoTurn : null,
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Urungkan'),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: game.isFinished || game.isThinking
                ? null
                : () async {
                    final resign = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Menyerah sekarang?'),
                        content: const Text(
                          'Hasil permainan ini akan disimpan di riwayat.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Lanjut bermain'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger,
                            ),
                            child: const Text('Menyerah'),
                          ),
                        ],
                      ),
                    );
                    if (resign == true) await controller.resign();
                  },
            icon: const Icon(Icons.flag_outlined, size: 17),
            label: const Text('Menyerah'),
          ),
        ),
        const SizedBox(width: 9),
        IconButton.filledTonal(
          onPressed: onHome,
          tooltip: 'Beranda',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.forest,
          ),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
    );
  }
}

class _MoveListPanel extends StatelessWidget {
  const _MoveListPanel({required this.game, required this.height});

  final GameUiState game;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pairCount = (game.moves.length + 1) ~/ 2;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 11),
            child: Row(
              children: [
                const Icon(
                  Icons.notes_rounded,
                  color: AppColors.forest,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  'Catatan langkah',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '$pairCount',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: height,
            child: game.moves.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Langkah yang dimainkan akan muncul di sini.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: pairCount,
                    itemBuilder: (context, index) {
                      final whiteMove = game.moves[index * 2];
                      final blackIndex = index * 2 + 1;
                      final blackMove = blackIndex < game.moves.length
                          ? game.moves[blackIndex]
                          : null;
                      final isLastPair = index == pairCount - 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        color: isLastPair
                            ? const Color(0xFFF3F5EE)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 31,
                              child: Text(
                                '${index + 1}.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontFeatures: const []),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                whiteMove.san,
                                style: _moveStyle(
                                  context,
                                  whiteMove == game.moves.last,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                blackMove?.san ?? '…',
                                style: _moveStyle(
                                  context,
                                  blackMove != null &&
                                      blackMove == game.moves.last,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  TextStyle? _moveStyle(BuildContext context, bool recent) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 13,
        color: recent ? AppColors.forest : AppColors.ink,
        fontWeight: recent ? FontWeight.w800 : FontWeight.w600,
      );
}

class _GameFootnote extends StatelessWidget {
  const _GameFootnote();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.save_outlined, size: 14, color: AppColors.muted),
      const SizedBox(width: 6),
      Text(
        'Permainan tersimpan otomatis',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
