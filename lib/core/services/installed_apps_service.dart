import 'package:flutter/foundation.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoItem {
  final String name;
  final String packageName;
  final Uint8List? icon;

  const AppInfoItem({
    required this.name,
    required this.packageName,
    this.icon,
  });
}

class InstalledAppsService {
  static final InstalledAppsService _instance = InstalledAppsService._internal();
  factory InstalledAppsService() => _instance;
  InstalledAppsService._internal();

  List<AppInfoItem>? _cachedApps;

  /// Fetch all installed launchable applications on Android with icons
  Future<List<AppInfoItem>> getInstalledApps({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedApps != null) {
      return _cachedApps!;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final packageInfo = await PackageInfo.fromPlatform();
        final currentPackageName = packageInfo.packageName;

        final List<AppInfo> apps = await InstalledApps.getInstalledApps(
          excludeSystemApps: true,
          withIcon: true,
        );

        // Map, dynamically filter out current running app (Lorofy), and sort alphabetically by app name
        final mapped = apps
            .where((app) => app.packageName != currentPackageName)
            .map((app) => AppInfoItem(
                  name: app.name,
                  packageName: app.packageName,
                  icon: app.icon,
                ))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        _cachedApps = mapped;
        return mapped;
      }
    } catch (e) {
      debugPrint('Error fetching installed apps: $e');
    }

    return [];
  }

  /// Get app infos for a set of package names
  Future<List<AppInfoItem>> getAppsByPackages(Set<String> packageNames) async {
    final allApps = await getInstalledApps();
    return allApps.where((app) => packageNames.contains(app.packageName)).toList();
  }
}
