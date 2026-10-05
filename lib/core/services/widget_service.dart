import 'package:home_widget/home_widget.dart';
import 'package:lorofy/core/utils/logger.dart';

class WidgetService {
  static const String _tag = 'WidgetService';
  static const String appGroupId = 'group.com.lorofy.app';
  static const List<String> androidProviders = [
    'FocusPillWidgetProvider',
    'FocusDarkGlassWidgetProvider',
  ];

  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Update widget with specific focus session state
  /// [widgetState]: 'idle' | 'running' | 'paused' | 'break' | 'completed'
  Future<void> updateWidgetState({
    required String statusText,
    required String widgetState,
    DateTime? targetEndTime,
    int? remainingSeconds,
    int? totalSeconds,
    String mascotName = 'lorofy_mascot',
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      await HomeWidget.saveWidgetData<String>('status_text', statusText);
      await HomeWidget.saveWidgetData<String>('widget_state', widgetState);

      if (targetEndTime != null) {
        await HomeWidget.saveWidgetData<int>(
          'target_end_timestamp',
          targetEndTime.millisecondsSinceEpoch,
        );
      }
      if (remainingSeconds != null) {
        await HomeWidget.saveWidgetData<int>('remaining_seconds', remainingSeconds);
      }
      if (totalSeconds != null) {
        await HomeWidget.saveWidgetData<int>('total_seconds', totalSeconds);
      }
      await HomeWidget.saveWidgetData<String>('mascot_name', mascotName);

      for (final provider in androidProviders) {
        await HomeWidget.updateWidget(
          name: provider,
          iOSName: 'FocusWidget',
        );
      }
      AppLogger.debug('Widget updated to state: $widgetState ($statusText)', tag: _tag);
    } catch (e, stack) {
      AppLogger.error(
        'Error updating widget state',
        error: e,
        stackTrace: stack,
        tag: _tag,
      );
    }
  }

  /// Convenience method for running focus/break state
  Future<void> updateFocusWidget({
    required String categoryName,
    required DateTime targetEndTime,
    required int totalSeconds,
    required bool isRunning,
    String mascotName = 'lorofy_mascot',
  }) async {
    await updateWidgetState(
      statusText: categoryName,
      widgetState: isRunning ? 'running' : 'idle',
      targetEndTime: targetEndTime,
      totalSeconds: totalSeconds,
      mascotName: mascotName,
    );
  }

  /// Clear widget state to Idle with user settings focusMinutes
  Future<void> clearWidget({int focusMinutes = 25}) async {
    await updateWidgetState(
      statusText: 'Sẵn sàng Focus 🎯',
      widgetState: 'idle',
      remainingSeconds: focusMinutes * 60,
    );
  }

  /// Update widget to Completed state
  Future<void> markCompleted({String statusText = 'Hoàn thành! 🎉'}) async {
    await updateWidgetState(
      statusText: statusText,
      widgetState: 'completed',
      remainingSeconds: 0,
    );
  }

  /// Update widget to Paused state
  Future<void> markPaused({required String categoryName, required int remainingSeconds}) async {
    await updateWidgetState(
      statusText: '$categoryName (Tạm dừng)',
      widgetState: 'paused',
      remainingSeconds: remainingSeconds,
    );
  }
}
