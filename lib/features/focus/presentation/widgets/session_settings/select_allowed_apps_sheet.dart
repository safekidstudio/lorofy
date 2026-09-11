import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/services/foreground_app_service.dart';
import 'package:lorofy/core/services/installed_apps_service.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'allowed_apps_grid_view.dart';
import 'app_picker_dialog.dart';
import 'usage_permission_dialog.dart';
import 'whitelist_intro_view.dart';

enum WhitelistStep { intro, grid }

class SelectAllowedAppsSheet extends ConsumerStatefulWidget {
  const SelectAllowedAppsSheet({super.key});

  @override
  ConsumerState<SelectAllowedAppsSheet> createState() =>
      _SelectAllowedAppsSheetState();
}

class _SelectAllowedAppsSheetState
    extends ConsumerState<SelectAllowedAppsSheet> {
  late WhitelistStep _step;
  late Set<String> _initialSavedPackages;
  late Set<String> _workingSelectedPackages;
  late Set<String> _gridAppPackages;

  List<AppInfoItem> _allInstalledApps = [];
  List<AppInfoItem> _allowedAppsForGrid = [];
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pomodoroSettingsProvider);
    _initialSavedPackages = Set<String>.from(settings.allowedAppPackages);
    _workingSelectedPackages = Set<String>.from(settings.allowedAppPackages);
    _gridAppPackages = Set<String>.from(settings.allowedAppPackages);

    _step = _initialSavedPackages.isNotEmpty
        ? WhitelistStep.grid
        : WhitelistStep.intro;

    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await InstalledAppsService().getInstalledApps();
    if (mounted) {
      setState(() {
        _allInstalledApps = apps;
        _updateGridAppsList();
        _isLoadingApps = false;
      });
    }
  }

  void _updateGridAppsList() {
    _allowedAppsForGrid = _allInstalledApps
        .where((app) => _gridAppPackages.contains(app.packageName))
        .toList();
  }

  bool get _hasChanges =>
      !setEquals(_initialSavedPackages, _workingSelectedPackages);

  Future<void> _openAppPickerSheet() async {
    final hasPermission = await ForegroundAppService().hasUsagePermission();
    if (!hasPermission) {
      if (!mounted) return;
      final granted = await showUsagePermissionDialog(context);
      if (!granted) return;
    }

    if (!mounted) return;

    final result = await showCupertinoModalPopup<Set<String>>(
      context: context,
      builder: (context) => AppPickerDialog(
        initialSelectedPackages: _workingSelectedPackages,
      ),
    );

    if (result != null) {
      setState(() {
        _workingSelectedPackages = Set<String>.from(result);
        _gridAppPackages = Set<String>.from(result);
        _updateGridAppsList();
        _step = WhitelistStep.grid;
      });
    }
  }

  void _togglePackage(String packageName) {
    setState(() {
      if (_workingSelectedPackages.contains(packageName)) {
        _workingSelectedPackages.remove(packageName);
      } else {
        _workingSelectedPackages.add(packageName);
      }
    });
  }

  void _saveChanges() {
    if (!_hasChanges) return;
    final settings = ref.read(pomodoroSettingsProvider);
    ref.read(pomodoroSettingsProvider.notifier).updateSettings(
          settings.copyWith(allowedAppPackages: _workingSelectedPackages),
        );
    setState(() {
      _initialSavedPackages = Set<String>.from(_workingSelectedPackages);
      _gridAppPackages = Set<String>.from(_workingSelectedPackages);
      _updateGridAppsList();
    });
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _workingSelectedPackages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _step == WhitelistStep.intro
              ? WhitelistIntroView(
                  key: const ValueKey('intro_view'),
                  onSelectApps: _openAppPickerSheet,
                  onReset: _reset,
                  isResetDisabled: _workingSelectedPackages.isEmpty,
                  onClose: () => Navigator.pop(context),
                )
              : AllowedAppsGridView(
                  key: const ValueKey('grid_view'),
                  allowedApps: _allowedAppsForGrid,
                  workingSelectedPackages: _workingSelectedPackages,
                  onTogglePackage: _togglePackage,
                  isLoading: _isLoadingApps,
                  hasChanges: _hasChanges,
                  isClearAllDisabled: _workingSelectedPackages.isEmpty,
                  onAddApps: _openAppPickerSheet,
                  onSave: _saveChanges,
                  onClearAll: _reset,
                  onClose: () => Navigator.pop(context),
                ),
        ),
      ),
    );
  }
}
