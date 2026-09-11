import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_checkbox.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/services/installed_apps_service.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class AppPickerDialog extends StatefulWidget {
  final Set<String> initialSelectedPackages;

  const AppPickerDialog({
    super.key,
    required this.initialSelectedPackages,
  });

  @override
  State<AppPickerDialog> createState() => _AppPickerDialogState();
}

class _AppPickerDialogState extends State<AppPickerDialog> {
  late Set<String> _selectedPackages;
  List<AppInfoItem> _allApps = [];
  List<AppInfoItem> _filteredApps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPackages = Set<String>.from(widget.initialSelectedPackages);
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await InstalledAppsService().getInstalledApps();
    if (mounted) {
      setState(() {
        _allApps = apps;
        _filteredApps = apps;
        _isLoading = false;
      });
    }
  }

  void _filterApps(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredApps = _allApps);
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filteredApps = _allApps
            .where((app) =>
                app.name.toLowerCase().contains(q) ||
                app.packageName.toLowerCase().contains(q))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
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
              title: 'Select Apps',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.xl,
                vertical: AppPadding.sm,
              ),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search apps...',
                onChanged: _filterApps,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : _filteredApps.isEmpty
                      ? const Center(
                          child: Text(
                            'No apps found',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.xl,
                            vertical: AppPadding.sm,
                          ),
                          itemCount: _filteredApps.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final app = _filteredApps[index];
                            final isSelected =
                                _selectedPackages.contains(app.packageName);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedPackages.remove(app.packageName);
                                  } else {
                                    _selectedPackages.add(app.packageName);
                                  }
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
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
                                              size: 24,
                                              color: AppColors.mutedForeground,
                                            ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        app.name,
                                        style: const TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                    ),
                                    IgnorePointer(
                                      child: AppCheckbox(
                                        value: isSelected,
                                        onChanged: (_) {},
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.xl,
                vertical: AppPadding.md,
              ),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: Button.primary(
                  text: 'Done (${_selectedPackages.length})',
                  onPressed: () => Navigator.pop(context, _selectedPackages),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
