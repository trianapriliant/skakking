import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/data_providers.dart';
import '../../application/providers.dart';
import '../../data/local/app_database.dart';
import '../../domain/chess_models.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _startGame(
    BuildContext context,
    WidgetRef ref, {
    GameMode initialMode = GameMode.computer,
  }) async {
    final setup = await showModalBottomSheet<GameSetup>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => GameSetupSheet(initialMode: initialMode),
    );
    if (setup == null || !context.mounted) return;

    try {
      final gameId = await ref
          .read(gameControllerProvider.notifier)
          .startGame(
            mode: setup.mode,
            difficulty: setup.difficulty,
            playerColor: setup.playerColor,
          );
      if (context.mounted) context.go('/game/$gameId');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permainan baru belum bisa disimpan. Coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _openSavedGame(
    BuildContext context,
    WidgetRef ref,
    int gameId,
  ) async {
    try {
      final loaded = await ref
          .read(gameControllerProvider.notifier)
          .loadGame(gameId);
      if (loaded && context.mounted) context.go('/game/$gameId');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat permainan ini tidak dapat dibuka.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(recentGamesProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 36),
                  sliver: SliverList.list(
                    children: [
                      _BrandBar(
                        onAbout: () => showAboutDialog(
                          context: context,
                          applicationName: 'Catur Mate',
                          applicationVersion: '1.0.0',
                          applicationIcon: const _KnightMark(size: 44),
                          children: const [
                            Text(
                              'Catur klasik untuk bermain offline. Riwayat tersimpan di perangkat.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _WelcomeCard(onPressed: () => _startGame(context, ref)),
                      const SizedBox(height: 12),
                      _CampaignEntry(onTap: () => context.go('/campaign')),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: _SectionHeading(
                              title: 'Pilih lawan',
                              subtitle: 'Mulai dalam satu sentuhan',
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _startGame(context, ref),
                            icon: const Icon(Icons.tune_rounded, size: 17),
                            label: const Text('Atur'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final gap = constraints.maxWidth > 540 ? 14.0 : 10.0;
                          return Row(
                            children: [
                              Expanded(
                                child: _ModeCard(
                                  icon: Icons.psychology_alt_rounded,
                                  title: 'Komputer',
                                  subtitle: 'Latihan · sedang',
                                  accent: AppColors.forest,
                                  onTap: () => _startGame(context, ref),
                                ),
                              ),
                              SizedBox(width: gap),
                              Expanded(
                                child: _ModeCard(
                                  icon: Icons.people_alt_rounded,
                                  title: 'Teman lokal',
                                  subtitle: 'Dua pemain · satu layar',
                                  accent: const Color(0xFF9A693E),
                                  onTap: () => _startGame(
                                    context,
                                    ref,
                                    initialMode: GameMode.local,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Expanded(
                            child: _SectionHeading(
                              title: 'Permainan terakhir',
                              subtitle: 'Tersimpan otomatis di perangkat',
                            ),
                          ),
                          games.maybeWhen(
                            data: (items) => items.isNotEmpty
                                ? Text(
                                    '${items.length} permainan',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  )
                                : const SizedBox.shrink(),
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      games.when(
                        data: (items) {
                          if (items.isEmpty) return const _EmptyHistory();
                          return Column(
                            children: [
                              for (final game in items.take(5)) ...[
                                _HistoryCard(
                                  game: game,
                                  onTap: () =>
                                      _openSavedGame(context, ref, game.id),
                                ),
                                const SizedBox(height: 9),
                              ],
                            ],
                          );
                        },
                        loading: () => const _HistoryLoading(),
                        error: (_, _) => const _EmptyHistory(
                          title: 'Riwayat belum tersedia',
                          message:
                              'Penyimpanan lokal akan dicoba kembali saat aplikasi dibuka.',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(child: _OfflineLabel()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameSetup {
  const GameSetup({
    required this.mode,
    required this.difficulty,
    required this.playerColor,
  });

  final GameMode mode;
  final ChessDifficulty difficulty;
  final chess.Color playerColor;
}

class GameSetupSheet extends StatefulWidget {
  const GameSetupSheet({super.key, required this.initialMode});

  final GameMode initialMode;

  @override
  State<GameSetupSheet> createState() => _GameSetupSheetState();
}

class _GameSetupSheetState extends State<GameSetupSheet> {
  late GameMode _mode = widget.initialMode;
  ChessDifficulty _difficulty = ChessDifficulty.medium;
  chess.Color _playerColor = chess.Chess.WHITE;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          14,
          22,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Atur permainan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Pilih lawan, lalu duduk di sisi papan favoritmu.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            const _FieldLabel('MODE PERMAINAN'),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _SetupChoice(
                    icon: Icons.psychology_alt_rounded,
                    label: 'Komputer',
                    selected: _mode == GameMode.computer,
                    onTap: () => setState(() => _mode = GameMode.computer),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _SetupChoice(
                    icon: Icons.people_alt_rounded,
                    label: 'Teman lokal',
                    selected: _mode == GameMode.local,
                    onTap: () => setState(() => _mode = GameMode.local),
                  ),
                ),
              ],
            ),
            if (_mode == GameMode.computer) ...[
              const SizedBox(height: 19),
              const _FieldLabel('TINGKAT KESULITAN'),
              const SizedBox(height: 9),
              Row(
                children: [
                  for (final difficulty in ChessDifficulty.values) ...[
                    Expanded(
                      child: _SetupChoice(
                        icon: difficulty == ChessDifficulty.medium
                            ? Icons.bolt_rounded
                            : Icons.circle_outlined,
                        label: difficulty.label,
                        selected: _difficulty == difficulty,
                        onTap: () => setState(() => _difficulty = difficulty),
                      ),
                    ),
                    if (difficulty != ChessDifficulty.hard)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 19),
            _FieldLabel(
              _mode == GameMode.computer
                  ? 'WARNA BUAH KAMU'
                  : 'SISI PAPAN BAWAH',
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _SetupChoice(
                    icon: Icons.circle,
                    label: 'Putih',
                    selected: _playerColor == chess.Chess.WHITE,
                    onTap: () =>
                        setState(() => _playerColor = chess.Chess.WHITE),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _SetupChoice(
                    icon: Icons.circle_outlined,
                    label: 'Hitam',
                    selected: _playerColor == chess.Chess.BLACK,
                    onTap: () =>
                        setState(() => _playerColor = chess.Chess.BLACK),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 23),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  GameSetup(
                    mode: _mode,
                    difficulty: _difficulty,
                    playerColor: _playerColor,
                  ),
                ),
                icon: const Icon(Icons.sports_esports_rounded),
                label: const Text('Mulai bermain'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.onAbout});

  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _KnightMark(size: 42),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATUR MATE',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(letterSpacing: 1.1),
            ),
            Text(
              'RUANG LATIHAN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton.filledTonal(
          onPressed: onAbout,
          tooltip: 'Tentang Catur Mate',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            fixedSize: const Size(44, 44),
          ),
          icon: const Icon(Icons.info_outline_rounded, size: 20),
        ),
      ],
    );
  }
}

class _KnightMark extends StatelessWidget {
  const _KnightMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        '♞',
        style: TextStyle(
          color: AppColors.lime,
          fontSize: size * 0.64,
          height: 1,
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      constraints: const BoxConstraints(minHeight: 224),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.forest, AppColors.forestDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -width * 0.04,
            top: -62,
            child: Text(
              '♞',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.07),
                fontSize: width > 700 ? 290 : 250,
                height: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.13),
                    ),
                  ),
                  child: const Text(
                    '♟  SATU PAPAN, BANYAK KEMUNGKINAN',
                    style: TextStyle(
                      color: AppColors.lime,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Setiap langkah\npunya cerita.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: width < 390 ? 32 : 37,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Mainkan catur klasik, kapan pun kamu siap.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 17),
                FilledButton.icon(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    minimumSize: const Size(174, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Mulai bermain'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignEntry extends StatelessWidget {
  const _CampaignEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF765137),
    borderRadius: BorderRadius.circular(21),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.lime),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHESS: POWER GIFT',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '4 campaign · 32 level · susun loadout-mu',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 17,
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 21),
              ),
              const SizedBox(height: 13),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Main sekarang',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: accent),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, size: 17, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.game, required this.onTap});

  final GameRow game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unfinished = game.status == 'in_progress';
    final mode = game.mode == GameMode.computer.name
        ? 'Komputer'
        : game.mode == GameMode.campaign.name
        ? 'Power Gift Campaign'
        : 'Teman lokal';
    final difficulty = ChessDifficulty.values
        .firstWhere(
          (value) => value.name == game.difficulty,
          orElse: () => ChessDifficulty.medium,
        )
        .label;
    final date = game.updatedAt.toLocal();
    final time =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    final result = switch (game.outcome) {
      'white_win' => 'Putih menang',
      'black_win' => 'Hitam menang',
      'white_resigned' => 'Putih menyerah',
      'black_resigned' => 'Hitam menyerah',
      'draw' => 'Remis',
      _ => null,
    };

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: unfinished
                      ? const Color(0xFFEFF5E8)
                      : const Color(0xFFF2F1EB),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  unfinished
                      ? Icons.play_arrow_rounded
                      : Icons.sports_score_rounded,
                  color: unfinished ? AppColors.forest : AppColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$mode${game.mode == GameMode.computer.name || game.mode == GameMode.campaign.name ? ' · $difficulty' : ''}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      unfinished
                          ? 'Belum selesai · $time'
                          : '${result ?? 'Selesai'} · $time',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (unfinished)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LANJUT',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({
    this.title = 'Belum ada permainan',
    this.message = 'Mulai pertandingan pertamamu di atas.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.muted, size: 22),
          const SizedBox(height: 7),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(28),
    child: Center(
      child: SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

class _OfflineLabel extends StatelessWidget {
  const _OfflineLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, size: 13, color: AppColors.muted),
        const SizedBox(width: 6),
        Text(
          'Bisa dimainkan tanpa internet',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SetupChoice extends StatelessWidget {
  const _SetupChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF1E7) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.forest : AppColors.muted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.forest : AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.muted,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
    ),
  );
}
