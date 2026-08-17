import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/core/errors/exceptions.dart';
import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:lorofy/core/constants/app_constants.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../providers/country_provider.dart';
import '../providers/onboard_controller.dart';

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

      final dio = ref.read(dioProvider);
      final bytes = await image.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: image.name),
      });

      final response = await dio.post(
        '/media/upload',
        data: formData,
        options: Options(
          extra: {'requiresAuth': true},
          contentType: 'multipart/form-data',
        ),
      );

      final responseData = response.data;
      if (responseData != null) {
        final dataField = responseData['data'];
        if (dataField != null) {
          final assetId = dataField['id'] as String;
          setState(() {
            _selectedAvatarId = assetId;
          });
        }
      }
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
        return _buildAvatarStep(isDisabled);
      case 1:
        return _buildCountryStep(isDisabled);
      case 2:
        return _buildNameStep(isDisabled);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEP 1: AVATAR SELECT ---
  Widget _buildAvatarStep(bool isDisabled) {
    const double avatarSize = 130;

    return Column(
      key: const ValueKey(0),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            children: [
              AppAvatar(
                path: _uploadedImagePath ?? _selectedAvatarUrl,
                size: avatarSize,
                isLoading: _isUploading,
                borderColor: const Color(0xFF232321).withValues(alpha: 0.1),
                borderWidth: 2,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isDisabled || _isUploading ? null : _uploadAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE4E4E6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 18,
                      color: Color(0xFF232321),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Choose your avatar', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Upload your avatar or using avatar list below',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _pageController,
            // Infinite scroll uses a very large virtual item count
            itemCount: 100000,
            onPageChanged: (page) {
              final index = page % AppConstants.defaultAvatars.length;
              setState(() {
                _selectedAvatarIndex = index;
                _selectedAvatarId = AppConstants.defaultAvatars[index]['id'];
                _selectedAvatarUrl = AppConstants.defaultAvatars[index]['url'];
                _uploadedImagePath = null;
              });
            },
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final mappedIndex = index % AppConstants.defaultAvatars.length;
              final avatar = AppConstants.defaultAvatars[mappedIndex];
              final int initialPage =
                  1000 * AppConstants.defaultAvatars.length + _selectedAvatarIndex;

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double distance = 0.0;
                  if (_pageController.position.haveDimensions) {
                    distance = (_pageController.page! - index).abs();
                  } else {
                    distance = (index - initialPage).abs().toDouble();
                  }

                  double scale = 1.0;
                  double opacity = 1.0;

                  if (distance <= 1.0) {
                    scale = 1.35 - (distance * 0.40);
                    opacity = 1.0 - (distance * 0.30);
                  } else if (distance <= 2.0) {
                    scale = 0.95 - ((distance - 1.0) * 0.25);
                    opacity = 0.70 - ((distance - 1.0) * 0.30);
                  } else {
                    scale = 0.70 - ((distance - 2.0) * 0.20);
                    opacity = 0.40 - ((distance - 2.0) * 0.20);
                    if (scale < 0.5) scale = 0.5;
                    if (opacity < 0.2) opacity = 0.2;
                  }

                  final isSelected = mappedIndex == _selectedAvatarIndex;

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                    child: Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF232321),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            padding: isSelected
                                ? const EdgeInsets.all(2)
                                : EdgeInsets.zero,
                            child: AppAvatar(path: avatar['url'], size: 52),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountryStep(bool isDisabled) {
    final countriesAsync = ref.watch(countriesProvider);

    return Column(
      key: const ValueKey(1),
      children: [
        const SizedBox(height: 20),
        Text('Where are you from?', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose the country you are currently living in',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        countriesAsync.when(
          loading: () => const CupertinoActivityIndicator(),
          error: (e, _) => Text(
            'Could not load countries',
            style: AppTextStyles.body.copyWith(color: AppColors.secondary),
          ),
          data: (countries) {
            // Auto-select first country if current selection not in list
            if (countries.isNotEmpty &&
                !countries.any((c) => c.code == _selectedCountryCode)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _selectedCountryCode = countries.first.code);
                }
              });
            }
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: countries.map((country) {
                final isSelected = country.code == _selectedCountryCode;

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () =>
                            setState(() => _selectedCountryCode = country.code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF232321)
                            : CupertinoColors.transparent,
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (country.flagUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    country.flagUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE4E4E6),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                  ),
                                )
                              else
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE4E4E6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                country.name,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF232321),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF071B12),
                                shape: BoxShape.circle,
                              ),
                              child: const SVG(
                                'assets/icons/check.svg',
                                width: 10,
                                height: 10,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // --- STEP 3: USERNAME SELECT ---
  Widget _buildNameStep(bool isDisabled) {
    return Column(
      key: const ValueKey(2),
      children: [
        const SizedBox(height: 20),
        Text('Create your username', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose a unique display name for your profile',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Input(
          placeholder: 'user.example',
          formControlName: 'displayName',
          disabled: isDisabled,
          prefix: Container(
            padding: const EdgeInsets.all(4),
            child: const SVG(
              'assets/icons/at-symbol.svg',
              height: 24,
              width: 24,
            ),
          ),
        ),
      ],
    );
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
