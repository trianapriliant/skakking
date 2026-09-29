import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/data_providers.dart';
import '../../application/providers.dart';
import '../../domain/chess_models.dart';
import '../../domain/power_campaign.dart';
import '../theme/app_theme.dart';

class CampaignScreen extends ConsumerStatefulWidget {
  const CampaignScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  ConsumerState<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends ConsumerState<CampaignScreen> {
  late Future<List<CampaignProgress>> _progress;

  @override
  void initState() {
    super.initState();
    _progress = _loadProgress();
  }

  Future<List<CampaignProgress>> _loadProgress() {
    return ref
        .read(chessGameRepositoryProvider)
        .getAllCampaignProgress(
          PowerCampaign.all.map((campaign) => campaign.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaignId == null
        ? null
        : PowerCampaign.byId(widget.campaignId!);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          campaign == null ? 'Power Gift Campaign' : campaign.power.label,
        ),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<CampaignProgress>>(
          future: _progress,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.muted,
                        size: 38,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Campaign belum dapat dimuat',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Coba muat ulang progres campaign dari penyimpanan lokal.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => setState(() {
                          _progress = _loadProgress();
                        }),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final progress = {
              for (final item in snapshot.data!) item.campaignId: item,
            };
            return campaign == null
                ? _campaignList(progress)
                : _campaignLevels(campaign, progress[campaign.id]!);
          },
        ),
      ),
    );
  }

  Widget _campaignList(Map<String, CampaignProgress> progress) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      children: [
        Text(
          'Pilih kekuatan permanen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Setiap campaign punya 8 level dengan satu power permanen yang ditetapkan. Kemenangan membuka level berikutnya.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 17),
        for (final campaign in PowerCampaign.all) ...[
          _CampaignCard(
            campaign: campaign,
            progress: progress[campaign.id]!,
            onTap: () => context.go('/campaign/${campaign.id}'),
          ),
          const SizedBox(height: 11),
        ],
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9D9B7)),
          ),
          child: const Text(
            'Slot sementara dibuka bertahap: level 1 membuka Pion Ekstra, lalu tiap level menambahkan power berikutnya. Pilih sampai dua power berbeda dari yang sudah terbuka.',
            style: TextStyle(color: AppColors.ink, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _campaignLevels(PowerCampaign campaign, CampaignProgress progress) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      children: [
        _PermanentPowerHeader(campaign: campaign),
        const SizedBox(height: 21),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pilih level',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              '${progress.completedLevel}/8 selesai',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.forest),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final level in campaign.levels) ...[
          _LevelCard(
            campaign: campaign,
            level: level,
            unlocked: progress.isUnlocked(level.number),
            completed: level.number <= progress.completedLevel,
            onTap: progress.isUnlocked(level.number)
                ? () => _prepareLevel(campaign, level)
                : null,
          ),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 7),
        const Text(
          'Permanen ditetapkan oleh campaign; dua slot sementara dipilih dari power yang sudah terbuka. Loadout tersimpan di SQLite. Efek power belum dijalankan oleh engine catur 8×8.',
          style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  Future<void> _prepareLevel(
    PowerCampaign campaign,
    CampaignLevelDefinition level,
  ) async {
    final loadout = await showModalBottomSheet<CampaignGameConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) =>
          CampaignLoadoutSheet(campaign: campaign, level: level),
    );
    if (loadout == null || !mounted) return;
    final difficulty = level.number <= 2
        ? ChessDifficulty.easy
        : level.number <= 5
        ? ChessDifficulty.medium
        : ChessDifficulty.hard;
    try {
      final gameId = await ref
          .read(gameControllerProvider.notifier)
          .startGame(
            mode: GameMode.campaign,
            difficulty: difficulty,
            playerColor: chess.Chess.WHITE,
            campaignConfig: loadout,
          );
      if (mounted) context.go('/game/$gameId');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign belum dapat dimulai. Coba lagi.'),
          ),
        );
      }
    }
  }
}

class CampaignLoadoutSheet extends StatefulWidget {
  const CampaignLoadoutSheet({
    super.key,
    required this.campaign,
    required this.level,
  });

  final PowerCampaign campaign;
  final CampaignLevelDefinition level;

  @override
  State<CampaignLoadoutSheet> createState() => _CampaignLoadoutSheetState();
}

class _CampaignLoadoutSheetState extends State<CampaignLoadoutSheet> {
  final List<TemporaryPower?> _slots = [null, null];

  @override
  Widget build(BuildContext context) {
    final available = widget.level.availablePowers;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          17,
          20,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Loadout · Level ${widget.level.number}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 7),
              Text(
                widget.level.objective,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 15),
              _PermanentPowerHeader(campaign: widget.campaign, compact: true),
              const SizedBox(height: 17),
              const _FieldLabel('SLOT POWER SEMENTARA'),
              const SizedBox(height: 8),
              for (var slot = 0; slot < 2; slot++) ...[
                _PowerSlot(
                  power: _slots[slot],
                  locked: available.length <= slot && _slots[slot] == null,
                  onTap: () => _choosePower(slot, available),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 5),
              Text(
                'Tersedia level ini: ${available.map((power) => power.label).join(' · ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _slots.every((power) => power == null)
                    ? null
                    : () => Navigator.of(context).pop(
                        CampaignGameConfig(
                          campaignId: widget.campaign.id,
                          level: widget.level.number,
                          temporaryPowers: _slots
                              .whereType<TemporaryPower>()
                              .toList(),
                        ),
                      ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Mulai level'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _choosePower(int slot, List<TemporaryPower> available) async {
    final choices = available
        .where((power) => power == _slots[slot] || !_slots.contains(power))
        .toList(growable: false);
    if (choices.isEmpty && _slots[slot] == null) return;
    final selected = await showModalBottomSheet<Object?>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Pilih power ${slot + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 9),
            if (_slots[slot] != null)
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: const Text('Kosongkan slot'),
                onTap: () => Navigator.pop(context, _ClearPower.instance),
              ),
            for (final power in choices)
              ListTile(
                leading: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.forest,
                ),
                title: Text(power.label),
                subtitle: Text(power.description),
                onTap: () => Navigator.pop(context, power),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      if (selected == _ClearPower.instance) {
        _slots[slot] = null;
      } else if (selected is TemporaryPower) {
        _slots[slot] = selected;
      }
    });
  }
}

class _ClearPower {
  const _ClearPower._();
  static const instance = _ClearPower._();
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.progress,
    required this.onTap,
  });

  final PowerCampaign campaign;
  final CampaignProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _PowerEmblem(power: campaign.power),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.power.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    campaign.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 9),
                  LinearProgressIndicator(
                    value: progress.completedLevel / 8,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xFF9A693E),
                    backgroundColor: const Color(0xFFEDE5DA),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.completedLevel}/8 level selesai',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}

class _PermanentPowerHeader extends StatelessWidget {
  const _PermanentPowerHeader({required this.campaign, this.compact = false});

  final PowerCampaign campaign;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(compact ? 12 : 17),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF815B3D), Color(0xFF563A2A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(compact ? 17 : 22),
    ),
    child: Row(
      children: [
        _PowerEmblem(power: campaign.power, large: !compact),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POWER PERMANEN',
                style: TextStyle(
                  color: AppColors.lime.withValues(alpha: 0.95),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                campaign.power.label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 16 : 20,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                campaign.power.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.campaign,
    required this.level,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final PowerCampaign campaign;
  final CampaignLevelDefinition level;
  final bool unlocked;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: unlocked ? AppColors.surface : const Color(0xFFECEBE5),
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: completed
                    ? const Color(0xFFE7F0E3)
                    : const Color(0xFFF2ECE4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: completed
                  ? const Icon(Icons.check_rounded, color: AppColors.forest)
                  : Text(
                      unlocked ? '${level.number}' : '🔒',
                      style: TextStyle(
                        color: unlocked ? AppColors.ink : AppColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Buka ${level.reward.label} · ${level.objective}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              completed
                  ? Icons.emoji_events_rounded
                  : Icons.chevron_right_rounded,
              color: completed ? const Color(0xFF9A693E) : AppColors.muted,
              size: 19,
            ),
          ],
        ),
      ),
    ),
  );
}

class _PowerSlot extends StatelessWidget {
  const _PowerSlot({
    required this.power,
    required this.locked,
    required this.onTap,
  });

  final TemporaryPower? power;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: locked ? const Color(0xFFF0EFE9) : const Color(0xFFFFFCF7),
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: locked ? null : onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Icon(
              locked ? Icons.lock_outline_rounded : Icons.auto_awesome_rounded,
              color: locked ? AppColors.muted : const Color(0xFFAA763E),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                power?.label ??
                    (locked ? 'Terbuka pada level berikutnya' : 'Pilih power'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 13),
              ),
            ),
            Icon(
              power == null
                  ? Icons.add_circle_outline_rounded
                  : Icons.edit_outlined,
              color: AppColors.muted,
              size: 19,
            ),
          ],
        ),
      ),
    ),
  );
}

class _PowerEmblem extends StatelessWidget {
  const _PowerEmblem({required this.power, this.large = false});

  final PermanentPower power;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
    width: large ? 54 : 47,
    height: large ? 54 : 47,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFE7D8C6).withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Text(
      power.symbol,
      style: TextStyle(
        color: AppColors.lime,
        fontSize: large ? 29 : 25,
        height: 1,
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.muted,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    ),
  );
}
