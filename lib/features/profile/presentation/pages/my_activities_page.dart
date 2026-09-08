import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/components/ui/sliding_segmented_control.dart';
import 'package:lorofy/components/ui/loader.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/features/profile/presentation/widgets/status_select_sheet.dart';
import 'package:lorofy/features/profile/presentation/widgets/activity_list_items.dart';

class MyActivitiesPage extends ConsumerStatefulWidget {
  const MyActivitiesPage({super.key});

  @override
  ConsumerState<MyActivitiesPage> createState() => _MyActivitiesPageState();
}

class _MyActivitiesPageState extends ConsumerState<MyActivitiesPage> {
  String _selectedStatus = 'ALL'; // 'ALL', 'COMPLETED', 'FAILED'
  String _selectedTimeframe = 'ALL'; // 'ALL', 'TODAY', 'WEEK'
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isLastPage = false;
  int _currentPage = 0;
  List<FocusSession> _sessions = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadActivities(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger when user scrolls to 90% of the list
    if (currentScroll >= maxScroll * 0.9) {
      if (!_isLoading && !_isLoadingMore && !_isLastPage) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadActivities({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 0;
        _isLastPage = false;
        _isLoading = true;
        _sessions = [];
      });
    }

    try {
      final repository = ref.read(exploreRepositoryProvider);

      String? startDate;
      String? endDate;
      final now = DateTime.now();

      if (_selectedTimeframe == 'TODAY') {
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
          999,
        );
        startDate = todayStart.toUtc().toIso8601String();
        endDate = todayEnd.toUtc().toIso8601String();
      } else if (_selectedTimeframe == 'WEEK') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final weekStart = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final weekEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        startDate = weekStart.toUtc().toIso8601String();
        endDate = weekEnd.toUtc().toIso8601String();
      }

      String? statusParam;
      if (_selectedStatus != 'ALL') {
        statusParam = _selectedStatus;
      }

      final list = await repository.getFilteredActivities(
        status: statusParam,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: 20,
      );

      if (mounted) {
        setState(() {
          _sessions.addAll(list);
          _isLastPage = list.length < 20;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        AppToast.show(
          context,
          message: 'Failed to load activities: ${e.toString()}',
          type: ToastType.error,
        );
      }
    }
  }

  void _loadNextPage() {
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    _loadActivities();
  }

  List<dynamic> _buildDisplayList() {
    final sorted = List<FocusSession>.from(_sessions)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    if (_selectedTimeframe == 'TODAY') {
      // Show every session individually by hour
      return sorted;
    } else {
      // Group everything by day
      final Map<DateTime, List<FocusSession>> groupedMap = {};
      for (final session in sorted) {
        final localTime = DateTime.parse(session.startedAt).toLocal();
        final sessionDate = DateTime(
          localTime.year,
          localTime.month,
          localTime.day,
        );
        groupedMap.putIfAbsent(sessionDate, () => []).add(session);
      }

      final List<dynamic> displayList = [];
      final sortedDates = groupedMap.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      for (final date in sortedDates) {
        displayList.add(PastDaySummary(date, groupedMap[date]!));
      }
      return displayList;
    }
  }

  Widget _buildSegmentedControl({
    required List<String> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabChanged,
    double? width,
  }) {
    return SlidingSegmentedControl(
      tabs: tabs,
      selectedIndex: selectedIndex,
      onTabChanged: onTabChanged,
      width: width,
      activeColor: const Color(0xFF232321),
      backgroundColor: const Color(0xFFECECED),
      inactiveTextColor: const Color(0xFF8E8E93),
    );
  }

  void _showStatusPicker(BuildContext context) {
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
          child: StatusSelectSheet(
            currentStatus: _selectedStatus,
            onSelect: (status) {
              setState(() => _selectedStatus = status);
              _loadActivities(reset: true);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    String displayLabel = 'All';
    if (_selectedStatus == 'COMPLETED') {
      displayLabel = 'Completed';
    } else if (_selectedStatus == 'FAILED') {
      displayLabel = 'Failed';
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: () => _showStatusPicker(context),
      child: Container(
        height: 32.0,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFECECED),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayLabel,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const SVG(
              'assets/icons/chevron-down.svg',
              width: 16,
              height: 16,
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFECECED), width: 1),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShimmerPlaceholder.rectangular(
                    width: 32,
                    height: 24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 24,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  children: List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ShimmerPlaceholder.rectangular(
                        width: 18,
                        height: 32,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              ShimmerPlaceholder.rectangular(
                width: 54,
                height: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SVG(
              'assets/illustrations/dead_plant.svg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'No activities found',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing your filters or start a new focus session.',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _buildDisplayList();

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
              title: 'My activities',
            ),

            const SizedBox(height: 12),

            // Filters row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSegmentedControl(
                    tabs: const ['All', 'Today', 'Week'],
                    selectedIndex: _selectedTimeframe == 'ALL'
                        ? 0
                        : (_selectedTimeframe == 'TODAY' ? 1 : 2),
                    onTabChanged: (index) {
                      final timeframe = index == 0
                          ? 'ALL'
                          : (index == 1 ? 'TODAY' : 'WEEK');
                      setState(() => _selectedTimeframe = timeframe);
                      _loadActivities(reset: true);
                    },
                  ),
                  _buildStatusDropdown(context),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List of items
            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : (displayList.isEmpty
                        ? _buildEmptyState()
                        : CupertinoScrollbar(
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              itemCount:
                                  displayList.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == displayList.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: Loader(size: 24)),
                                  );
                                }

                                final item = displayList[index];
                                if (item is FocusSession) {
                                  return TodayActivityItem(session: item);
                                } else if (item is PastDaySummary) {
                                  return PastDayActivityItem(summary: item);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          )),
            ),
          ],
        ),
      ),
    );
  }
}
