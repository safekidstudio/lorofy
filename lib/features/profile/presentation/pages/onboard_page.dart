import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import '../providers/onboard_controller.dart'; // import controller mới

class OnboardPage extends ConsumerStatefulWidget {
  const OnboardPage({super.key});

  @override
  ConsumerState<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends ConsumerState<OnboardPage> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Chỉ giữ lại các State phục vụ cho Form input của UI
  String? _selectedAvatarId;
  String _selectedCountryCode = 'VN';
  final _nameController = TextEditingController();

  final List<Map<String, String>> _countries = [
    {'code': 'VN', 'name': 'Vietnam', 'flag': '🇻🇳'},
    {'code': 'US', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'JP', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': 'SG', 'name': 'Singapore', 'flag': '🇸🇬'},
    {'code': 'KR', 'name': 'South Korea', 'flag': '🇰🇷'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _submitOnboarding() async {
    final displayName = _nameController.text.trim();
    if (displayName.length < 3) return;

    // Gọi trực tiếp notifier để trigger API
    await ref
        .read(onboardControllerProvider.notifier)
        .onboard(
          displayName: displayName,
          countryCode: _selectedCountryCode,
          timezone: 'Asia/Ho_Chi_Minh',
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
          AppToast.show(
            context,
            message: 'Your profile has been created successfully!',
            type: ToastType.success,
          );
        },
      );
    });
    // 🌟 Watch Server State tại đây
    final onboardState = ref.watch(onboardControllerProvider);
    final isLoading = onboardState.isLoading;
    final errorMessage = onboardState.hasError
        ? _parseError(onboardState.error!)
        : null;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      child: Stack(
        children: [
          // Background tràn màn hình
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/auth_bg_1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: CupertinoColors.black),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: CupertinoColors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          // Nội dung Card Bottom Sheet
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header của Steps
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _currentStep > 0
                            ? CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: isLoading ? null : _prevStep,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.inputBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.left_chevron,
                                    size: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : const SizedBox(width: 40),
                        Text(
                          'Step ${_currentStep + 1} of $_totalSteps',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress indicators
                    _buildProgressBar(),
                    const SizedBox(height: 24),

                    // Step Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildStepContent(isLoading),
                    ),

                    // Hiển thị Error tự động từ Server State
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage,
                        style: AppTextStyles.body.copyWith(
                          color: CupertinoColors.systemRed,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Nút hành động chính
                    Button.primary(
                      text: _currentStep == _totalSteps - 1
                          ? 'Get Started'
                          : 'Next Step',
                      isLoading: isLoading,
                      onPressed: (_isNextButtonEnabled() && !isLoading)
                          ? _nextStep
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
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

  // --- STEP 1: AVATAR STEP ---
  Widget _buildAvatarStep(bool isDisabled) {
    return Column(
      key: const ValueKey(0),
      children: [
        Text('Choose your avatar', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Set up an avatar or skip to do it later',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              CupertinoIcons.person_alt,
              size: 64,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isDisabled ? null : () {},
          child: Text(
            'Upload Custom Photo',
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 2: COUNTRY STEP ---
  Widget _buildCountryStep(bool isDisabled) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('Where are you from?', style: AppTextStyles.titleLarge),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _countries.length,
            separatorBuilder: (_, __) =>
                Container(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final country = _countries[index];
              final isSelected = country['code'] == _selectedCountryCode;

              return CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                onPressed: isDisabled
                    ? null
                    : () => setState(
                        () => _selectedCountryCode = country['code']!,
                      ),
                child: Row(
                  children: [
                    Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        country['name']!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- STEP 3: NAME STEP ---
  Widget _buildNameStep(bool isDisabled) {
    return Column(
      key: const ValueKey(2),
      children: [
        Text('What should we call you?', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Your display name will be visible to your friends',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        Input(
          label: 'Display Name',
          placeholder: 'e.g. Alex Smith',
          controller: _nameController,
          disabled: isDisabled,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  bool _isNextButtonEnabled() {
    if (_currentStep == 2) {
      return _nameController.text.trim().length >= 3;
    }
    return true;
  }

  String _parseError(Object error) {
    final msg = error.toString();
    if (msg.contains('Country code')) {
      return 'Invalid country selected.';
    }
    if (msg.contains('Display name')) {
      return 'Display name must be between 3 and 100 characters.';
    }
    return 'Something went wrong. Please try again.';
  }
}
