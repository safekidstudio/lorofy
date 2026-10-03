import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/global_loading_overlay.dart';
import 'package:lorofy/features/profile/presentation/widgets/avatar_select_sheet.dart';
import 'package:lorofy/features/profile/presentation/widgets/country_select_sheet.dart';
import 'package:lorofy/core/constants/app_constants.dart';
import 'package:lorofy/features/profile/data/repositories/profile_repository_impl.dart';

import 'package:lorofy/core/localization/l10n_extension.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  late FormGroup _form;
  bool _isLoading = true;
  bool _isUpdating = false;

  // Selected avatar state
  String? _selectedAvatarUrl;
  String? _uploadedImagePath;
  bool _isUploading = false;

  // Profile data state
  String _originalDisplayName = '';
  String _originalCountryCode = 'VN';
  String _originalCountryName = 'Vietnam';
  String _originalTimezone = 'Asia/Ho_Chi_Minh';
  String? _originalAvatarUrl;

  String _selectedCountryCode = 'VN';
  String _selectedCountryName = 'Vietnam';
  String _selectedTimezone = 'Asia/Ho_Chi_Minh';

  @override
  void initState() {
    super.initState();

    _form = FormGroup({
      'username': FormControl<String>(value: '', disabled: true),
      'displayName': FormControl<String>(
        value: '',
        validators: [
          Validators.required,
          Validators.minLength(3),
          Validators.maxLength(30),
        ],
      ),
    });

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(authRepositoryProvider).getMe();
      if (mounted) {
        setState(() {
          _originalDisplayName = profile.displayName ?? '';
          _originalAvatarUrl = profile.avatarUrl;
          _originalCountryCode = profile.countryCode;
          _originalCountryName = profile.countryName;
          _originalTimezone = profile.timezone;

          _selectedCountryCode = _originalCountryCode;
          _selectedCountryName = _originalCountryName;
          _selectedTimezone = _originalTimezone;
          _selectedAvatarUrl = _originalAvatarUrl;

          _form.control('username').reset(value: profile.username);
          _form.control('displayName').reset(value: _originalDisplayName);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.show(
          context,
          message: 'Failed to load profile details.',
          type: ToastType.error,
        );
      }
    }
  }

  void _showAvatarOptions() {
    Navigator.push(
      context,
      CupertinoModalSheetRoute(
        swipeDismissible: true,
        builder: (context) => Sheet(
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: AppColors.background,
          ),
          child: AvatarSelectSheet(
            defaultAvatars: AppConstants.defaultAvatars,
            onSelectPreset: (id, url) {
              _updateAvatarDirectly(id, url);
            },
            onPickGallery: _uploadAvatarAndSaveDirectly,
          ),
        ),
      ),
    );
  }

  void _showCountryOptions() {
    Navigator.push(
      context,
      CupertinoModalSheetRoute(
        swipeDismissible: true,
        builder: (context) => Sheet(
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: AppColors.background,
          ),
          child: CountrySelectSheet(
            currentCountryCode: _selectedCountryCode,
            onSelect: (country) {
              setState(() {
                _selectedCountryCode = country.code;
                _selectedCountryName = country.name;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateAvatarDirectly(String assetId, String url) async {
    AppLoading.show(ref, 'Updating avatar...');
    setState(() {
      _isLoading = true;
      _selectedAvatarUrl = url;
      _uploadedImagePath = null;
    });

    try {
      final displayName =
          (_form.value['displayName'] as String?)?.trim() ??
          _originalDisplayName;
      await ref
          .read(authRepositoryProvider)
          .updateProfile(
            displayName: displayName,
            countryCode: _selectedCountryCode,
            timezone: _selectedTimezone,
            avatarAssetId: assetId,
          );

      if (mounted) {
        AppLoading.showSuccess(ref, 'Avatar updated!');
        setState(() {
          _originalAvatarUrl = url;
        });
      }
    } catch (e) {
      if (mounted) {
        AppLoading.showError(ref, 'Failed to update avatar');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadAvatarAndSaveDirectly() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      AppLoading.show(ref, 'Uploading avatar...');
      setState(() {
        _uploadedImagePath = image.path;
        _selectedAvatarUrl = null;
        _isUploading = true;
      });

      final bytes = await image.readAsBytes();
      final assetId = await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(bytes, image.name);

      final displayName =
          (_form.value['displayName'] as String?)?.trim() ??
          _originalDisplayName;
      final profile = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            displayName: displayName,
            countryCode: _selectedCountryCode,
            timezone: _selectedTimezone,
            avatarAssetId: assetId,
          );

      if (mounted) {
        AppLoading.showSuccess(ref, 'Avatar uploaded!');
        setState(() {
          _originalAvatarUrl = profile.avatarUrl;
          _selectedAvatarUrl = profile.avatarUrl;
          _uploadedImagePath = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadedImagePath = null;
        _selectedAvatarUrl = _originalAvatarUrl;
      });
      if (!mounted) return;
      AppLoading.showError(ref, 'Failed to upload avatar');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    final displayName = (_form.value['displayName'] as String?)?.trim() ?? '';
    if (displayName.length < 3) {
      AppToast.show(
        context,
        message: 'Display name must be at least 3 characters.',
        type: ToastType.error,
      );
      return;
    }

    AppLoading.show(ref, 'Updating profile...');
    setState(() => _isUpdating = true);

    try {
      final updatedProfile = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            displayName: displayName,
            countryCode: _selectedCountryCode,
            timezone: _selectedTimezone,
          );

      if (mounted) {
        setState(() {
          _originalDisplayName = updatedProfile.displayName ?? displayName;
          _originalCountryCode = updatedProfile.countryCode;
          _originalCountryName = updatedProfile.countryName;
          _originalTimezone = updatedProfile.timezone;
        });
        AppLoading.showSuccess(ref, 'Profile updated!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppLoading.showError(ref, 'Failed to update profile');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Widget _buildSelectorTile({
    required String label,
    required String value,
    required String countryCode,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    final resolvedBg = CupertinoDynamicColor.resolve(AppColors.input, context);

    // Compute flag emoji from 2-letter country code
    String flagEmoji = '🏳️';
    if (countryCode.length == 2) {
      final int firstLetter =
          countryCode.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;
      final int secondLetter =
          countryCode.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;
      flagEmoji =
          String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: DrawingContainer(
            fillColor: resolvedBg,
            borderColor: CupertinoColors.transparent,
            borderWidth: 0.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              child: Row(
                children: [
                  SVG(
                    iconPath,
                    width: 20,
                    height: 20,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        color: AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(flagEmoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  const SVG(
                    'assets/icons/chevron-right.svg',
                    width: 18,
                    height: 18,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Center(child: ShimmerPlaceholder.circular(size: 100)),
          const SizedBox(height: 36),
          ShimmerPlaceholder.rectangular(
            height: 54,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 16),
          ShimmerPlaceholder.rectangular(
            height: 54,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 16),
          ShimmerPlaceholder.rectangular(
            height: 60,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 16),
          ShimmerPlaceholder.rectangular(
            height: 60,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 32),
          Center(
            child: ShimmerPlaceholder.rectangular(
              width: 180,
              height: 51,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: context.l10n.profile_myProfile,
            ),

            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : ReactiveForm(
                      formGroup: _form,
                      child: ReactiveFormConsumer(
                        builder: (context, form, child) {
                          final l10n = context.l10n;
                          final currentDisplayName =
                              (_form.value['displayName'] as String?)?.trim() ??
                              '';
                          final isChanged =
                              currentDisplayName != _originalDisplayName ||
                              _selectedCountryCode != _originalCountryCode;

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 32),

                                // Avatar Stack
                                Center(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      AppAvatar(
                                        path:
                                            _uploadedImagePath ??
                                            _selectedAvatarUrl,
                                        size: 100,
                                        isDrawing: true,
                                        isLoading: _isUploading,
                                      ),
                                      Positioned(
                                        bottom: -10,
                                        right: -5,
                                        child: GestureDetector(
                                          onTap: _isUploading
                                              ? null
                                              : _showAvatarOptions,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: CupertinoColors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.secondary,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: CupertinoColors
                                                      .systemGrey
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.camera_fill,
                                              size: 18,
                                              color: AppColors.foreground,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 36),

                                // Username Input (Disabled)
                                Input(
                                  placeholder: l10n.profile_username,
                                  formControlName: 'username',
                                  prefix: const SVG(
                                    'assets/icons/at-symbol.svg',
                                    width: 20,
                                    height: 20,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Display Name Input
                                Input(
                                  placeholder: l10n.profile_displayName,
                                  formControlName: 'displayName',
                                  maxLength: 30,
                                  prefix: const SVG(
                                    'assets/icons/user-square.svg',
                                    width: 20,
                                    height: 20,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Country / Region Tile
                                _buildSelectorTile(
                                  label: l10n.profile_countryRegion,
                                  value: _selectedCountryName,
                                  countryCode: _selectedCountryCode,
                                  iconPath: 'assets/icons/global.svg',
                                  onTap: _showCountryOptions,
                                ),

                                const SizedBox(height: 32),

                                // Update Button
                                Center(
                                  child: SizedBox(
                                    width: 180,
                                    child: Button.primary(
                                      text: l10n.common_update,
                                      onPressed:
                                          (form.valid &&
                                              isChanged &&
                                              !_isUpdating)
                                          ? _updateProfile
                                          : null,
                                      isLoading: _isUpdating,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
