import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/components/ui/loader.dart';

const String kDefaultLoadingLottieUrl = 'assets/animations/cat_loading.json';

enum LoadingStatus { loading, success, error }

/// State model for Global Loading.
class GlobalLoadingState {
  final bool isLoading;
  final LoadingStatus status;
  final String message;
  final String? lottieAsset;
  final String? lottieUrl;
  final String? riveAsset;
  final String? riveStateMachine;

  const GlobalLoadingState({
    this.isLoading = false,
    this.status = LoadingStatus.loading,
    this.message = 'Just a moment...',
    this.lottieAsset,
    this.lottieUrl = kDefaultLoadingLottieUrl,
    this.riveAsset,
    this.riveStateMachine,
  });

  GlobalLoadingState copyWith({
    bool? isLoading,
    LoadingStatus? status,
    String? message,
    String? lottieAsset,
    String? lottieUrl,
    String? riveAsset,
    String? riveStateMachine,
  }) {
    return GlobalLoadingState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      message: message ?? this.message,
      lottieAsset: lottieAsset ?? this.lottieAsset,
      lottieUrl: lottieUrl ?? this.lottieUrl,
      riveAsset: riveAsset ?? this.riveAsset,
      riveStateMachine: riveStateMachine ?? this.riveStateMachine,
    );
  }
}

/// Notifier to control global loading screen state.
class GlobalLoadingNotifier extends Notifier<GlobalLoadingState> {
  Timer? _autoHideTimer;

  @override
  GlobalLoadingState build() {
    ref.onDispose(() {
      _autoHideTimer?.cancel();
    });
    return const GlobalLoadingState();
  }

  void show({
    String message = 'Just a moment...',
    String? lottieAsset,
    String? lottieUrl,
    String? riveAsset,
    String? riveStateMachine,
  }) {
    _autoHideTimer?.cancel();
    state = GlobalLoadingState(
      isLoading: true,
      status: LoadingStatus.loading,
      message: message,
      lottieAsset: lottieAsset,
      lottieUrl:
          lottieUrl ?? (riveAsset == null ? kDefaultLoadingLottieUrl : null),
      riveAsset: riveAsset,
      riveStateMachine: riveStateMachine,
    );
  }

  void showSuccess({
    String message = 'Success!',
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    _autoHideTimer?.cancel();
    state = state.copyWith(
      isLoading: true,
      status: LoadingStatus.success,
      message: message,
    );
    _autoHideTimer = Timer(duration, () {
      hide();
    });
  }

  void showError({
    String message = 'Something went wrong',
    Duration duration = const Duration(milliseconds: 1600),
  }) {
    _autoHideTimer?.cancel();
    state = state.copyWith(
      isLoading: true,
      status: LoadingStatus.error,
      message: message,
    );
    _autoHideTimer = Timer(duration, () {
      hide();
    });
  }

  void hide() {
    _autoHideTimer?.cancel();
    state = state.copyWith(isLoading: false);
  }
}

/// Global provider for controlling app loading screen.
final globalLoadingProvider =
    NotifierProvider<GlobalLoadingNotifier, GlobalLoadingState>(
      GlobalLoadingNotifier.new,
    );

/// Convenience helper to trigger loading from anywhere with WidgetRef.
class AppLoading {
  static void show(
    WidgetRef ref, [
    String message = 'Just a moment...',
    String? lottieAsset,
    String? lottieUrl,
    String? riveAsset,
    String? riveStateMachine,
  ]) {
    ref
        .read(globalLoadingProvider.notifier)
        .show(
          message: message,
          lottieAsset: lottieAsset,
          lottieUrl: lottieUrl,
          riveAsset: riveAsset,
          riveStateMachine: riveStateMachine,
        );
  }

  static void showSuccess(
    WidgetRef ref, [
    String message = 'Success!',
    Duration duration = const Duration(milliseconds: 1200),
  ]) {
    ref
        .read(globalLoadingProvider.notifier)
        .showSuccess(message: message, duration: duration);
  }

  static void showError(
    WidgetRef ref, [
    String message = 'Something went wrong',
    Duration duration = const Duration(milliseconds: 1600),
  ]) {
    ref
        .read(globalLoadingProvider.notifier)
        .showError(message: message, duration: duration);
  }

  static void hide(WidgetRef ref) {
    ref.read(globalLoadingProvider.notifier).hide();
  }
}

/// Clean Fullscreen Overlay wrapper that displays loading animation (Lottie or Rive)
/// with a pure white glassmorphism background whenever global loading is active.
class GlobalLoadingOverlay extends ConsumerWidget {
  final Widget child;

  const GlobalLoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      globalLoadingProvider.select((state) => state.isLoading),
    );

    return Stack(
      children: [
        child,
        _GlobalLoadingOverlayLayer(isLoading: isLoading),
      ],
    );
  }
}

class _GlobalLoadingOverlayLayer extends ConsumerStatefulWidget {
  final bool isLoading;

  const _GlobalLoadingOverlayLayer({required this.isLoading});

  @override
  ConsumerState<_GlobalLoadingOverlayLayer> createState() =>
      __GlobalLoadingOverlayLayerState();
}

class __GlobalLoadingOverlayLayerState
    extends ConsumerState<_GlobalLoadingOverlayLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.isLoading) {
      _visible = true;
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _GlobalLoadingOverlayLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      setState(() {
        _visible = true;
      });
      _controller.forward(from: 0.0);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.reverse().then((_) {
        if (mounted && !widget.isLoading) {
          setState(() {
            _visible = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible && !widget.isLoading && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !widget.isLoading,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: const _GlobalLoadingContent(),
          ),
        ),
      ),
    );
  }
}

class _GlobalLoadingContent extends ConsumerWidget {
  const _GlobalLoadingContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(globalLoadingProvider);

    // Calculate dynamic animation size based on viewport width
    final double screenWidth = MediaQuery.of(context).size.width;
    final double animationSize = (screenWidth * 0.45).clamp(160.0, 280.0);

    final isSuccess = loadingState.status == LoadingStatus.success;
    final isError = loadingState.status == LoadingStatus.error;

    return Stack(
      children: [
        // 1. Soft backdrop blur first to blur the page underneath
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: const SizedBox.expand(),
        ),

        // 2. Translucent white modal barrier (50% white) so blurred background is visible while blocking clicks
        ModalBarrier(
          dismissible: false,
          color: Colors.white.withValues(alpha: 0.80),
        ),

        // Centered Animation + Message
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Pure Animation Widget (Rive or Lottie)
                _buildLoadingAnimationWidget(loadingState, animationSize),

                const SizedBox(height: 24),

                // Loading / Status Message with Pure Fade Transition
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    loadingState.message,
                    key: ValueKey<String>(
                      '${loadingState.message}_${loadingState.status}',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: isSuccess
                          ? const Color.fromARGB(255, 8, 106, 91)
                          : (isError
                                ? CupertinoColors.systemRed
                                : AppColors.primary),
                      decoration: TextDecoration.none,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Standard App Loader rotating circle component (only active while loading)
                if (loadingState.status == LoadingStatus.loading)
                  const Loader(size: 26.0, color: AppColors.primary)
                else
                  const SizedBox(height: 26.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingAnimationWidget(
    GlobalLoadingState loadingState,
    double animationSize,
  ) {
    // 1. Support Rive animation if riveAsset is provided
    if (loadingState.riveAsset != null && loadingState.riveAsset!.isNotEmpty) {
      return _StandaloneRiveLoadingWidget(
        riveAsset: loadingState.riveAsset!,
        stateMachineName: loadingState.riveStateMachine,
        status: loadingState.status,
        size: animationSize,
      );
    }

    // 2. Support Lottie animation (asset or network)
    final lottiePath =
        loadingState.lottieAsset ??
        loadingState.lottieUrl ??
        kDefaultLoadingLottieUrl;

    if (lottiePath.startsWith('http://') || lottiePath.startsWith('https://')) {
      return Lottie.network(
        lottiePath,
        width: animationSize,
        height: animationSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } else {
      return Lottie.asset(
        lottiePath,
        width: animationSize,
        height: animationSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }
  }
}

/// Standalone Rive Loading Animation Widget for API overlays.
class _StandaloneRiveLoadingWidget extends StatefulWidget {
  final String riveAsset;
  final String? stateMachineName;
  final LoadingStatus status;
  final double size;

  const _StandaloneRiveLoadingWidget({
    required this.riveAsset,
    this.stateMachineName,
    required this.status,
    required this.size,
  });

  @override
  State<_StandaloneRiveLoadingWidget> createState() =>
      _StandaloneRiveLoadingWidgetState();
}

class _StandaloneRiveLoadingWidgetState
    extends State<_StandaloneRiveLoadingWidget> {
  SMITrigger? _successTrigger;
  SMITrigger? _failTrigger;
  SMIBool? _loadingBool;

  void _onRiveInit(Artboard artboard) {
    final stateMachineName = widget.stateMachineName ?? 'State Machine 1';
    final controller = StateMachineController.fromArtboard(
      artboard,
      stateMachineName,
    );
    if (controller != null) {
      artboard.addController(controller);
      for (final input in controller.inputs) {
        if (input is SMITrigger) {
          if (input.name == 'success' || input.name == 'isSuccess') {
            _successTrigger = input;
          } else if (input.name == 'fail' ||
              input.name == 'failed' ||
              input.name == 'isFailed') {
            _failTrigger = input;
          }
        } else if (input is SMIBool) {
          if (input.name == 'isLoading' ||
              input.name == 'isFocusing' ||
              input.name == 'loading') {
            _loadingBool = input;
          }
        }
      }
      _applyStatus();
    }
  }

  void _applyStatus() {
    if (widget.status == LoadingStatus.success) {
      _successTrigger?.fire();
    } else if (widget.status == LoadingStatus.error) {
      _failTrigger?.fire();
    } else if (widget.status == LoadingStatus.loading) {
      if (_loadingBool != null) {
        _loadingBool!.value = true;
      }
    }
  }

  @override
  void didUpdateWidget(covariant _StandaloneRiveLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _applyStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        widget.riveAsset,
        stateMachines: [widget.stateMachineName ?? 'State Machine 1'],
        onInit: _onRiveInit,
        fit: BoxFit.contain,
      ),
    );
  }
}
