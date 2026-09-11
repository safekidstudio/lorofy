import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/services/installed_apps_service.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'app_picker_dialog.dart';

class AllowedAppsGridSheet extends ConsumerStatefulWidget {
  const AllowedAppsGridSheet({super.key});

  @override
  ConsumerState<AllowedAppsGridSheet> createState() => _AllowedAppsGridSheetState();
}

class _AllowedAppsGridSheetState extends ConsumerState<AllowedAppsGridSheet> {
  late Set<String> _selectedPackages;
  List<AppInfoItem> _allowedApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pomodoroSettingsProvider);
    _selectedPackages = Set<String>.from(settings.allowedAppPackages);
    _loadAllowedApps();
  }

  Future<void> _loadAllowedApps() async {
    final apps = await InstalledAppsService().getAppsByPackages(_selectedPackages);
    if (mounted) {
      setState(() {
        _allowedApps = apps;
        _isLoading = false;
      });
    }
  }

  Future<void> _openAppPicker() async {
    final result = await showCupertinoModalPopup<Set<String>>(
      context: context,
      builder: (context) => AppPickerDialog(
        initialSelectedPackages: _selectedPackages,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPackages = result;
        _isLoading = true;
      });
      await _loadAllowedApps();
    }
  }

  void _saveChanges() {
    final settings = ref.read(pomodoroSettingsProvider);
    ref.read(pomodoroSettingsProvider.notifier).updateSettings(
          settings.copyWith(allowedAppPackages: _selectedPackages),
        );
    Navigator.pop(context);
  }

  void _clearAll() {
    setState(() {
      _selectedPackages.clear();
      _allowedApps.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const SVG(
                  'assets/icons/cancel.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              title: 'Set whitelist apps',
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Allowed apps',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _openAppPicker,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8E8EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.add,
                        size: 20,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _allowedApps.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.square_grid_2x2,
                                size: 48,
                                color: Color(0xFFC7C7CC),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No allowed apps selected yet',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(20),
                                onPressed: _openAppPicker,
                                child: const Text(
                                  'Add Apps',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.xl,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: _allowedApps.length,
                          itemBuilder: (context, index) {
                            final app = _allowedApps[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF1E1E1E),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: app.icon != null
                                                ? Image.memory(
                                                    app.icon!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Icon(
                                                    CupertinoIcons.app_fill,
                                                    size: 32,
                                                    color: AppColors.secondary,
                                                  ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            app.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: AppTextStyles.fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E1E1E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E1E1E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.checkmark,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.xl,
                vertical: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(26),
                      onPressed: _saveChanges,
                      child: const Text(
                        'Save change',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _clearAll,
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
