import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/core/errors/exceptions.dart';
import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:lorofy/core/constants/app_constants.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../providers/onboard_controller.dart';
import 'package:lorofy/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lorofy/features/profile/presentation/widgets/onboard/onboard_avatar_step.dart';
import 'package:lorofy/features/profile/presentation/widgets/onboard/onboard_country_step.dart';
import 'package:lorofy/features/profile/presentation/widgets/onboard/onboard_name_step.dart';

class OnboardPage extends ConsumerStatefulWidget {
  const OnboardPage({super.key});

  @override
  ConsumerState<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends ConsumerState<OnboardPage> {
  int _currentStep = 0;
  final int _totalSteps = 3;
  bool _isSuccess = false;

  // Selected avatar state (supports default seeds and custom uploads)
  String? _selectedAvatarId;
  String? _selectedAvatarUrl;
  String? _uploadedImagePath;
  bool _isUploading = false;

  String _selectedCountryCode = 'VN';
  late FormGroup _form;

  int _selectedAvatarIndex = 2;
  late final PageController _pageController;
  bool _preCached = false;

  @override
  void initState() {
    super.initState();

    _form = FormGroup({
      'displayName': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(3)],
      ),
    });

    // Default to the 3rd avatar from the list, matching the mockup selected item
    _selectedAvatarId = AppConstants.defaultAvatars[2]['id'];
    _selectedAvatarUrl = AppConstants.defaultAvatars[2]['url'];
    final int initialPage =
        1000 * AppConstants.defaultAvatars.length + _selectedAvatarIndex;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.22,
    );
    _prefillUsername();
  }

  Future<void> _prefillUsername() async {
    try {
      final profile = await ref.read(authRepositoryProvider).getMe();
      if (mounted) {
        _form.control('displayName').value = profile.username;
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_preCached) {
      for (final avatar in AppConstants.defaultAvatars) {
        precacheImage(NetworkImage(avatar['url']!), context);
      }
      _preCached = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submitOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _uploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Optimistic UI: immediately show local image preview & set uploading status
      setState(() {
        _uploadedImagePath = image.path;
        _selectedAvatarUrl = null;
        _isUploading = true;
      });

      final bytes = await image.readAsBytes();
      final uploadResult = await ref.read(profileRepositoryProvider).uploadAvatar(bytes, image.name);
      final assetId = uploadResult.id;
      setState(() {
        _selectedAvatarId = assetId;
      });
    } catch (e) {
      // Revert optimistic UI on upload failure
      setState(() {
        _uploadedImagePath = null;
        _selectedAvatarId = AppConstants.defaultAvatars[_selectedAvatarIndex]['id'];
        _selectedAvatarUrl = AppConstants.defaultAvatars[_selectedAvatarIndex]['url'];
      });
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Failed to upload avatar: ${e.toString()}',
        type: ToastType.error,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String _getTimezoneForCountry(String countryCode) {
    switch (countryCode) {
      case 'VN':
        return 'Asia/Ho_Chi_Minh';
      case 'US':
        return 'America/New_York';
      case 'JP':
        return 'Asia/Tokyo';
      case 'TH':
        return 'Asia/Bangkok';
      case 'ES':
        return 'Europe/Madrid';
      case 'KR':
        return 'Asia/Seoul';
      default:
        return 'UTC';
    }
  }

  Future<void> _submitOnboarding() async {
    final displayName = (_form.value['displayName'] as String?)?.trim() ?? '';
    if (displayName.length < 3) return;

    await ref
        .read(onboardControllerProvider.notifier)
        .onboard(
          displayName: displayName,
          countryCode: _selectedCountryCode,
          timezone: _getTimezoneForCountry(_selectedCountryCode),
          avatarAssetId: _selectedAvatarId,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(onboardControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          AppToast.show(
            context,
            message: _parseError(error),
            type: ToastType.error,
          );
        },
        data: (_) {
          setState(() {
            _isSuccess = true;
          });
          AppToast.show(
            context,
            message: 'Your profile has been created successfully!',
            type: ToastType.success,
          );
          // Auto-redirect to home page after a 3-second delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _isSuccess) {
              final displayName = (_form.value['displayName'] as String?)?.trim() ?? '';
              ref
                  .read(authProvider.notifier)
                  .updateOnboardedState(
                    onboarded: true,
                    displayName: displayName,
                  );
            }
          });
        },
      );
    });

    final onboardState = ref.watch(onboardControllerProvider);
    final isLoading = onboardState.isLoading;
    final errorMessage = onboardState.hasError
        ? _parseError(onboardState.error!)
        : null;

    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width > 500;

    Widget content;

    if (_isSuccess) {
      content = CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: Stack(
            children: [
              // Rive Confetti falling behind content
              const Positioned.fill(
                child: RiveAnimation.asset(
                  'assets/river/confetti.riv',
                  fit: BoxFit.cover,
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    // Success animated checkmark blob
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: const SVG(
                          'assets/illustrations/success_checkmark.svg',
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Congrats title
                    Text(
                      'Ready to Grow!',
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF232321),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Text(
                      'Congratulations! Your profile has been set up successfully. Let\'s start your focus journey with Lorofy.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 2),
                    // Action button: calls updateOnboardedState which triggers redirect
                    Button.primary(
                      text: 'Get Started',
                      onPressed: () {
                        final displayName = (_form.value['displayName'] as String?)?.trim() ?? '';
                        ref
                            .read(authProvider.notifier)
                            .updateOnboardedState(
                              onboarded: true,
                              displayName: displayName,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        child: SafeArea(
          child: ReactiveForm(
            formGroup: _form,
            child: Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildStepContent(isLoading),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (errorMessage != null) ...[
                        Text(
                          errorMessage,
                          style: AppTextStyles.body.copyWith(
                            color: CupertinoColors.systemRed,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildActionButtons(isLoading),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isDesktop) {
      return Container(
        color: const Color(0xFFF2F4F7),
        alignment: Alignment.center,
        child: Container(
          width: 420,
          height: 800,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: content,
          ),
        ),
      );
    }

    return content;
  }

  Widget _buildProgressBar() {
    final double percent = (_currentStep + 1) / _totalSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          width: 240,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE4E4E6),
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 240 * percent,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF232321).withValues(alpha: .8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDisabled) {
    switch (_currentStep) {
      case 0:
        return OnboardAvatarStep(
          key: const ValueKey(0),
          isDisabled: isDisabled,
          uploadedImagePath: _uploadedImagePath,
          selectedAvatarUrl: _selectedAvatarUrl,
          isUploading: _isUploading,
          selectedAvatarIndex: _selectedAvatarIndex,
          pageController: _pageController,
          onUploadPressed: _uploadAvatar,
          onAvatarIndexChanged: (index) {
            setState(() {
              _selectedAvatarIndex = index;
              _selectedAvatarId = AppConstants.defaultAvatars[index]['id'];
              _selectedAvatarUrl = AppConstants.defaultAvatars[index]['url'];
              _uploadedImagePath = null;
            });
          },
        );
      case 1:
        return OnboardCountryStep(
          key: const ValueKey(1),
          isDisabled: isDisabled,
          selectedCountryCode: _selectedCountryCode,
          onCountryChanged: (code) {
            setState(() => _selectedCountryCode = code);
          },
        );
      case 2:
        return OnboardNameStep(
          key: const ValueKey(2),
          isDisabled: isDisabled,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionButtons(bool isLoading) {
    if (_currentStep == 0) {
      return Button.primary(
        text: 'Next',
        isLoading: isLoading,
        onPressed: isLoading ? null : _nextStep,
      );
    } else if (_currentStep == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Button.primary(
            text: 'Next',
            isLoading: isLoading,
            onPressed: isLoading ? null : _nextStep,
          ),
          const SizedBox(height: 12),
          Button.secondary(
            text: 'Back',
            disabled: isLoading,
            onPressed: isLoading ? null : _prevStep,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReactiveFormConsumer(
            builder: (context, form, child) {
              return Button.primary(
                text: 'Complete',
                isLoading: isLoading,
                onPressed: (form.valid && !isLoading)
                    ? _nextStep
                    : null,
              );
            },
          ),
          const SizedBox(height: 12),
          Button.secondary(
            text: 'Back',
            disabled: isLoading,
            onPressed: isLoading ? null : _prevStep,
          ),
        ],
      );
    }
  }

  String _parseError(Object error) {
    final msg = error.errorMessage;
    if (msg.contains('Country code')) {
      return 'Invalid country selected.';
    }
    if (msg.contains('Display name')) {
      return 'Display name must be between 3 and 100 characters.';
    }
    return msg;
  }
}
