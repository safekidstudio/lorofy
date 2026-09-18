import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lorofy/components/ui/safe_rive_animation.dart';
import 'package:rive/rive.dart' hide Animation;

class StreakCelebrationPage extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final bool streakIncreased;
  final int streakFreezeCount;
  final VoidCallback? onDismiss;

  const StreakCelebrationPage({
    super.key,
    required this.currentStreak,
    this.longestStreak = 251,
    this.streakIncreased = true,
    this.streakFreezeCount = 0,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentStreak,
    int longestStreak = 251,
    bool streakIncreased = true,
    int streakFreezeCount = 0,
    VoidCallback? onDismiss,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: StreakCelebrationPage(
              currentStreak: currentStreak,
              longestStreak: longestStreak,
              streakIncreased: streakIncreased,
              streakFreezeCount: streakFreezeCount,
              onDismiss: onDismiss,
            ),
          );
        },
      ),
    );
  }

  @override
  State<StreakCelebrationPage> createState() => _StreakCelebrationPageState();
}

class _StreakCelebrationPageState extends State<StreakCelebrationPage> {
  RiveWidgetController? _riveController;
  StateMachine? _riveStateMachine;
  final Map<String, ViewModelInstance> _vmInstances = {};

  @override
  void dispose() {
    if (_riveStateMachine != null) {
      _riveStateMachine!.removeEventListener(_onRiveEvent);
    }
    for (final vmi in _vmInstances.values) {
      vmi.dispose();
    }
    _vmInstances.clear();
    super.dispose();
  }

  void _onRiveControllerInit(RiveWidgetController controller) {
    _riveController = controller;
    _riveStateMachine = controller.stateMachine;

    final ab = controller.artboard;
    final animCount = ab.animationCount();
    final smCount = ab.stateMachineCount();

    debugPrint('========================================================');
    debugPrint('🔥 [RIVE ARTBOARD LOADED]: "${ab.name}"');
    debugPrint('🔥 [RIVE STATEMACHINE LOADED]: "${controller.stateMachine.name}"');
    debugPrint('🔥 [RIVE STATEMACHINE COUNT]: $smCount');
    for (int i = 0; i < smCount; i++) {
      debugPrint('   - StateMachine [$i]: "${ab.stateMachineAt(i)?.name}"');
    }
    debugPrint('🔥 [RIVE ANIMATION COUNT]: $animCount');
    for (int i = 0; i < animCount; i++) {
      debugPrint('   - Animation [$i]: "${ab.animationAt(i).name}"');
    }
    debugPrint('========================================================');

    _riveStateMachine?.addEventListener(_onRiveEvent);
  }

  void _setupRiveDataBinding(File file) {
    final ab = _riveController?.artboard;
    if (ab == null) return;

    _vmInstances.clear();

    // Bind all ViewModels in file (VMStreak, VMSphere)
    for (int i = 0; i < file.viewModelCount; i++) {
      final vm = file.viewModelByIndex(i);
      if (vm != null) {
        final vmi = vm.createDefaultInstance() ?? vm.createInstance();
        if (vmi != null) {
          ab.bindViewModelInstance(vmi);
          _vmInstances[vm.name] = vmi;
          debugPrint('🔥 BOUND VIEWMODEL [$i]: "${vm.name}" (${vmi.name})');
        }
      }
    }

    _updateStreakValues();
    _triggerRiveClick();
  }

  void _updateStreakValues() {
    final streakVM = _vmInstances['VMStreak'];
    final sphereVM = _vmInstances['VMSphere'];

    streakVM?.number('counter')?.value = widget.currentStreak.toDouble();
    sphereVM?.number('numStates')?.value = widget.currentStreak.toDouble();
  }

  void _triggerRiveClick() {
    debugPrint('🔥 [RIVE TAP DETECTED] Firing triggers on VMStreak & VMSphere...');

    _updateStreakValues();

    final streakVM = _vmInstances['VMStreak'];
    final sphereVM = _vmInstances['VMSphere'];

    // 1. VMStreak triggers & booleans
    streakVM?.boolean('booStreak')?.value = true;
    streakVM?.trigger('trigStreak')?.trigger();

    // 2. VMSphere triggers & booleans
    sphereVM?.boolean('boolSphere')?.value = true;
    sphereVM?.trigger('trigSphere')?.trigger();

    // 3. State Machine input triggers
    // ignore: deprecated_member_use
    _riveStateMachine?.trigger('trigStreak')?.fire();
    // ignore: deprecated_member_use
    _riveStateMachine?.trigger('trigSphere')?.fire();
    // ignore: deprecated_member_use
    _riveStateMachine?.boolean('booStreak')?.value = true;
    // ignore: deprecated_member_use
    _riveStateMachine?.boolean('boolSphere')?.value = true;

    // Advance frame & repaint
    _riveStateMachine?.advanceAndApply(0.1);
    _riveController?.scheduleRepaint();
  }

  void _onRiveEvent(Event event) {
    debugPrint('🔥 [RIVE NATIVE EVENT FIRED!]: name="${event.name}" type=${event.type}');
  }

  void _handleDismiss() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: isDark
                ? const [
                    Color(0xFF1E1B4B),
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                  ]
                : const [
                    Color(0xFFFFF7ED),
                    Color(0xFFFFEDD5),
                    Color(0xFFFED7AA),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 24),

                  // Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF97316).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(CupertinoIcons.flame_fill, color: Color(0xFFF97316), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CHUỖI STREAK HẰNG NGÀY',
                          style: TextStyle(
                            color: Color(0xFFF97316),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Streak number title
                  Text(
                    '${widget.currentStreak} Ngày',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.streakIncreased
                        ? '🔥 Tuyệt vời! Ngọn lửa thói quen của bạn đang cháy bùng!'
                        : 'Giữ vững phong độ để tiếp tục chuỗi thói quen!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Interactive Rive Mascot Display
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _triggerRiveClick,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 340,
                            maxHeight: 340,
                          ),
                          child: SafeRiveAnimation.asset(
                            'assets/river/fire-streak.riv',
                            onInitController: _onRiveControllerInit,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Stats card container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              title: 'Kỷ lục cao nhất',
                              value: '${widget.longestStreak} ngày',
                              icon: Icons.emoji_events,
                              iconColor: const Color(0xFFEAB308),
                              isDark: isDark,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              title: 'Bùa bảo vệ',
                              value: '${widget.streakFreezeCount} lượt',
                              icon: CupertinoIcons.snow,
                              iconColor: const Color(0xFF3B82F6),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CTA Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _handleDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: const Color(0xFFF97316).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Tiếp tục',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              // Top right close button
              Positioned(
                top: 12,
                right: 16,
                child: IconButton(
                  onPressed: _handleDismiss,
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 32,
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
