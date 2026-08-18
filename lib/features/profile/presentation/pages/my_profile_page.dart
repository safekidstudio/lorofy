import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/features/profile/presentation/widgets/avatar_select_sheet.dart';
import 'package:lorofy/core/constants/app_constants.dart';
import 'package:lorofy/features/profile/data/repositories/profile_repository_impl.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  late FormGroup _form;
  bool _isLoading = true;
  bool _isUpdating = false;

  // Selected avatar state (supports gallery selection / custom upload)
  String? _selectedAvatarUrl;
  String? _uploadedImagePath;
  bool _isUploading = false;

  String _originalDisplayName = '';
  String? _originalAvatarUrl;

  @override
  void initState() {
    super.initState();

    // Initialize the Reactive form group
    _form = FormGroup({
      'username': FormControl<String>(value: '', disabled: true),
      'displayName': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(3)],
      ),
      'avatarId': FormControl<String>(value: null),
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

          // Reset the form state with loaded data to clear dirty states
          _form.control('username').reset(value: profile.username);
          _form.control('displayName').reset(value: _originalDisplayName);
          _form.control('avatarId').reset(value: null);

          _selectedAvatarUrl = _originalAvatarUrl;
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
        builder: (context) => Sheet(
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Color(0xFFF6F6F6),
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

  Future<void> _updateAvatarDirectly(String assetId, String url) async {
    setState(() {
      _isLoading = true;
      _selectedAvatarUrl = url;
      _uploadedImagePath = null;
    });

    try {
      final displayName = (_form.value['displayName'] as String?)?.trim() ?? _originalDisplayName;
      await ref.read(authRepositoryProvider).updateProfile(
        displayName: displayName,
        avatarAssetId: assetId,
      );

      if (mounted) {
        AppToast.show(
          context,
          message: 'Avatar updated successfully!',
          type: ToastType.success,
        );
        setState(() {
          _originalAvatarUrl = url;
          _form.control('avatarId').reset(value: null);
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Failed to update avatar: ${e.toString()}',
          type: ToastType.error,
        );
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

      // Optimistic UI: immediately show local image preview & set uploading status
      setState(() {
        _uploadedImagePath = image.path;
        _selectedAvatarUrl = null;
        _isUploading = true;
      });

      final bytes = await image.readAsBytes();
      final uploadResult = await ref.read(profileRepositoryProvider).uploadAvatar(bytes, image.name);
      final assetId = uploadResult.id;

          final displayName = (_form.value['displayName'] as String?)?.trim() ?? _originalDisplayName;
          final profile = await ref.read(authRepositoryProvider).updateProfile(
            displayName: displayName,
            avatarAssetId: assetId,
          );

          if (mounted) {
            AppToast.show(
              context,
              message: 'Avatar updated successfully!',
              type: ToastType.success,
            );
            setState(() {
              _originalAvatarUrl = profile.avatarUrl;
              _selectedAvatarUrl = profile.avatarUrl;
              _uploadedImagePath = null;
              _form.control('avatarId').reset(value: null);
            });
          }
    } catch (e) {
      // Revert optimistic UI on upload/update failure
      setState(() {
        _uploadedImagePath = null;
        _selectedAvatarUrl = _originalAvatarUrl;
        _form.control('avatarId').reset(value: null);
      });
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Failed to upload and update avatar: ${e.toString()}',
        type: ToastType.error,
      );
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

    setState(() => _isUpdating = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfile(
            displayName: displayName,
          );

      if (mounted) {
        AppToast.show(
          context,
          message: 'Profile updated successfully!',
          type: ToastType.success,
        );
        Navigator.pop(context); // Go back to profile page
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Failed to update profile: ${e.toString()}',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          // Circular Avatar Skeleton
          Center(
            child: ShimmerPlaceholder.circular(size: 100),
          ),
          const SizedBox(height: 36),
          // Username Input Skeleton
          ShimmerPlaceholder.rectangular(
            height: 54,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 16),
          // Display Name Input Skeleton
          ShimmerPlaceholder.rectangular(
            height: 54,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 32),
          // Button Skeleton
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
                    color: Color(0xFFE4E4E6),
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: 'My Profile',
            ),

            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : ReactiveForm(
                      formGroup: _form,
                      child: ReactiveFormConsumer(
                        builder: (context, form, child) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 32),

                                // Blob Avatar Stack
                                Center(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      AppAvatar(
                                        path: _uploadedImagePath ?? _selectedAvatarUrl,
                                        size: 100,
                                        isDrawing: true,
                                        isLoading: _isUploading,
                                      ),
                                      Positioned(
                                        bottom: -10,
                                        right: -5,
                                        child: GestureDetector(
                                          onTap: _isUploading ? null : _showAvatarOptions,
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
                                            child: const SVG(
                                              'assets/icons/image.svg',
                                              width: 18,
                                              height: 18,
                                              color: Color(0xFF232321),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 36),

                                // Username Input (Disabled/Read-only)
                                const Input(
                                  placeholder: 'Username',
                                  formControlName: 'username',
                                  prefix: SVG(
                                    'assets/icons/at-symbol.svg',
                                    width: 20,
                                    height: 20,
                                    color: AppColors.secondary,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Display Name Input (Editable)
                                const Input(
                                  placeholder: 'Display Name',
                                  formControlName: 'displayName',
                                  prefix: SVG(
                                    'assets/icons/user-square.svg',
                                    width: 20,
                                    height: 20,
                                    color: AppColors.secondary,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Update Button
                                Center(
                                  child: SizedBox(
                                    width: 180,
                                    child: Button.primary(
                                      text: 'Update',
                                      onPressed: (form.valid && form.dirty && !_isUpdating)
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
