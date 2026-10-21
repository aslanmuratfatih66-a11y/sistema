// Системные окна последствий: «Квест провален», «Штраф», «Уровень повышен», итог босса,
// режим дисциплины. Собираются из GameOutcome; показывает их OutcomeWindowsHost очередью.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../domain/quests/quest_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/models/home_view_data.dart' show PlayerRankX;
import '../../home/widgets/level_hexagon.dart';

/// Несколько провалов подряд (например, после долгого отсутствия) — одним окном.
/// (GameOutcome — sealed в контракте, поэтому отдельный класс.)
class QuestsFailedBatch {
  const QuestsFailedBatch(this.items);
  final List<QuestFailed> items;

  int get penalty => items.fold(0, (s, f) => s + f.penaltyDiamonds);
}

Widget _okButton(AppLocalizations l) =>
    Builder(builder: (c) => SysButton.primary(label: l.homeOk, onPressed: () => Navigator.of(c).pop()));

/// Окно для последствия ([GameOutcome] или [QuestsFailedBatch]); null — не окном
/// (выполнение показывается короткой плашкой).
Widget? buildOutcomeWindow(BuildContext context, Object o) {
  final l = AppLocalizations.of(context);
  final nf = NumberFormat.decimalPattern(l.localeName);
  String title(QuestItem q) => questTitleText(l, q.title);

  return switch (o) {
    QuestCompleted() => null,
    QuestFailed(:final quest, :final penaltyDiamonds) => SystemWindow(
        key: const Key('window-failed'),
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.homeWarningLabel,
        title: l.homeQuestFailedTitle,
        message: l.qstWindowFailedMessage(title(quest), nf.format(penaltyDiamonds)),
        actions: [_okButton(l)],
      ),
    QuestsFailedBatch(:final items) => SystemWindow(
        key: const Key('window-failed'),
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.homeWarningLabel,
        title: l.homeQuestFailedTitle,
        message: '${l.qstWindowFailedMany(items.length, nf.format(o.penalty))}\n'
            '${items.map((f) => '— ${title(f.quest)}').join('\n')}',
        actions: [_okButton(l)],
      ),
    QuestRefused(:final quest, :final penaltyDiamonds) => SystemWindow(
        key: const Key('window-refused'),
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.homeWarningLabel,
        title: l.qstWindowRefusedTitle,
        message: l.homeQuestRefusedMessage(title(quest), nf.format(penaltyDiamonds)),
        actions: [_okButton(l)],
      ),
    PenaltyApplied(:final reasonKey, :final diamonds, :final penaltyQuest) => SystemWindow(
        key: const Key('window-penalty'),
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.homeWarningLabel,
        title: l.qstWindowPenaltyTitle,
        message: [
          l.qstWindowPenaltyMessage(penaltyReasonLabel(l, reasonKey), nf.format(diamonds)),
          if (penaltyQuest != null) l.qstWindowPenaltyQuest(title(penaltyQuest)),
        ].join('\n'),
        actions: [_okButton(l)],
      ),
    LevelUp() => LevelUpWindow(outcome: o),
    BossResult() => BossResultWindow(outcome: o),
    DisciplineChanged(:final active) => SystemWindow(
        key: const Key('window-discipline'),
        kind: active ? SystemWindowKind.warning : SystemWindowKind.notice,
        warningTone: PanelTone.gold,
        label: active ? l.homeWarningLabel : l.homeNoticeLabel,
        title: active ? l.qstDisciplineOnTitle : l.qstDisciplineOffTitle,
        message: active ? l.qstDisciplineOnMessage : l.qstDisciplineOffMessage,
        actions: [
          if (active)
            Builder(
              builder: (c) => SysButton.secondary(
                label: l.qstDisciplineMore,
                onPressed: () {
                  final router = GoRouter.maybeOf(c);
                  Navigator.of(c).pop();
                  router?.push(Routes.discipline);
                },
              ),
            ),
          _okButton(l),
        ],
      ),
    _ => null,
  };
}

/// Показать окно модально (как showSystemWindow, но для любого содержимого).
Future<void> showOutcomeDialog(BuildContext context, Widget window) {
  final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: SysColors.barrier,
    transitionDuration: reduce ? Duration.zero : SysDims.windowAppear,
    pageBuilder: (context, animation, secondaryAnimation) => SafeArea(
      child: Center(
        child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), child: window),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

/// Заголовок окна «[ УВЕДОМЛЕНИЕ ]» + крупная надпись.
class _WindowHead extends StatelessWidget {
  const _WindowHead({required this.label, required this.title, required this.tone, required this.glyph});

  final String label;
  final String title;
  final PanelTone tone;
  final SysGlyph glyph;

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SysIcon(glyph, size: 18, color: p.light),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '[ ${label.toUpperCase()} ]',
                textAlign: TextAlign.center,
                style: SysText.title.copyWith(color: p.light),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: SysText.heading.copyWith(
              fontSize: 22,
              letterSpacing: SysDims.headingSpacing(22),
              color: p.light,
              shadows: [Shadow(color: p.main.withValues(alpha: .8), blurRadius: 12)],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [p.main.withValues(alpha: 0), p.main, p.main.withValues(alpha: 0)]),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

Widget _windowFrame({required Key key, required PanelTone tone, required Widget child}) => Semantics(
      key: key,
      scopesRoute: true,
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Material(
          type: MaterialType.transparency,
          child: SysPanel(tone: tone, padding: const EdgeInsets.all(18), child: child),
        ),
      ),
    );

/// «Уровень повышен»: шестиугольник LV, новый ранг/титул, свободные очки, частицы.
class LevelUpWindow extends StatelessWidget {
  const LevelUpWindow({super.key, required this.outcome});

  final LevelUp outcome;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final o = outcome;
    final rank = o.rank;
    final title = titleLabel(l, o.titleKey);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final panel = _windowFrame(
      key: const Key('window-levelup'),
      tone: PanelTone.gold,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WindowHead(label: l.homeNoticeLabel, title: l.qstLevelUpTitle, tone: PanelTone.gold, glyph: SysGlyph.sparkle),
          Center(child: LevelHexagon(level: o.level, size: 76)),
          const SizedBox(height: 10),
          Text(
            l.qstLevelUpLevel(o.level),
            textAlign: TextAlign.center,
            style: SysText.monoLarge.copyWith(color: SysColors.gold),
          ),
          if (rank != null) ...[
            const SizedBox(height: 8),
            Center(child: SysPill(label: l.qstLevelUpRank(rank.letter), icon: SysGlyph.shield)),
          ],
          if (title != null && title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l.qstTitleGot(title),
              textAlign: TextAlign.center,
              style: SysText.body.copyWith(color: SysColors.gold),
            ),
          ],
          if (o.freeStatPoints > 0) ...[
            const SizedBox(height: 8),
            Text(
              l.qstLevelUpPoints(o.freeStatPoints),
              textAlign: TextAlign.center,
              style: SysText.mono.copyWith(color: SysColors.accentLighter),
            ),
          ],
          const SizedBox(height: 18),
          _okButton(l),
        ],
      ),
    );

    // Частицы — декоративные: при «Уменьшении движения» не рисуются.
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        WindowAppear(scanColor: SysColors.gold, child: panel),
        if (!reduce) const Positioned.fill(child: IgnorePointer(child: LevelUpParticles())),
      ],
    );
  }
}

/// Итог босса недели (фиолетовая тема).
class BossResultWindow extends StatelessWidget {
  const BossResultWindow({super.key, required this.outcome});

  final BossResult outcome;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final o = outcome;
    final title = titleLabel(l, o.titleKey);
    return WindowAppear(
      scanColor: SysColors.bossLight,
      child: _windowFrame(
        key: const Key('window-boss'),
        tone: PanelTone.boss,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WindowHead(
              label: l.homeBossTitle,
              title: o.won ? l.qstBossWonTitle : l.qstBossLostTitle,
              tone: PanelTone.boss,
              glyph: o.won ? SysGlyph.crown : SysGlyph.sword,
            ),
            Text(
              questTitleText(l, o.quest.title),
              textAlign: TextAlign.center,
              style: SysText.body.copyWith(color: SysColors.textSecondary),
            ),
            const SizedBox(height: 10),
            if (o.won)
              Text(
                l.qstBossReward(nf.format(o.reward.diamonds), nf.format(o.reward.xp)),
                textAlign: TextAlign.center,
                style: SysText.mono.copyWith(color: SysColors.gold),
              )
            else
              Text(l.qstBossLostMessage, textAlign: TextAlign.center, style: SysText.secondary),
            if (o.won && title != null && title.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l.qstTitleGot(title), textAlign: TextAlign.center, style: SysText.body.copyWith(color: SysColors.gold)),
            ],
            const SizedBox(height: 18),
            _okButton(l),
          ],
        ),
      ),
    );
  }
}

/// Разлёт золотых частиц один раз (~1.6 с).
class LevelUpParticles extends StatefulWidget {
  const LevelUpParticles({super.key});

  @override
  State<LevelUpParticles> createState() => _LevelUpParticlesState();
}

class _LevelUpParticlesState extends State<LevelUpParticles> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..forward();

  // Фиксированное зерно — одинаковая картинка, без мерцания при перестройке.
  static final List<_Particle> _particles = () {
    final r = math.Random(7);
    return [
      for (var i = 0; i < 36; i++)
        _Particle(
          angle: r.nextDouble() * math.pi * 2,
          speed: .35 + r.nextDouble() * .65,
          size: 1.5 + r.nextDouble() * 2.5,
          delay: r.nextDouble() * .25,
          gold: r.nextBool(),
        ),
    ];
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _ParticlesPainter(_particles, _c.value)),
      );
}

class _Particle {
  const _Particle({required this.angle, required this.speed, required this.size, required this.delay, required this.gold});
  final double angle;
  final double speed;
  final double size;
  final double delay;
  final bool gold;
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1 || size.isEmpty) return;
    final center = Offset(size.width / 2, size.height * .32);
    final reach = size.shortestSide * .75;
    for (final p in particles) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final eased = Curves.easeOutCubic.transform(local);
      final pos = center +
          Offset(math.cos(p.angle), math.sin(p.angle)) * (reach * p.speed * eased) +
          Offset(0, -20 * eased);
      final color = (p.gold ? SysColors.gold : SysColors.accentLighter).withValues(alpha: (1 - local) * .9);
      canvas.drawCircle(pos, p.size * 2.2, Paint()..color = color.withValues(alpha: color.a * .35));
      canvas.drawCircle(pos, p.size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.t != t;
}
