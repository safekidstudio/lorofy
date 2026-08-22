import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/components/ui/loader.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';

class MyPointsPage extends ConsumerStatefulWidget {
  const MyPointsPage({super.key});

  @override
  ConsumerState<MyPointsPage> createState() => _MyPointsPageState();
}

class _MyPointsPageState extends ConsumerState<MyPointsPage> {
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
    _loadHistory(reset: true);
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
    if (currentScroll >= maxScroll * 0.9) {
      if (!_isLoading && !_isLoadingMore && !_isLastPage) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadHistory({bool reset = false}) async {
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

      // Fetch completed sessions that earned points
      final list = await repository.getFilteredActivities(
        status: 'COMPLETED',
        page: _currentPage,
        size: 20,
      );

      if (mounted) {
        setState(() {
          // Filter to only sessions with earnedPoints > 0
          final pointSessions = list.where((s) => s.earnedPoints > 0).toList();
          _sessions.addAll(pointSessions);
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
          message: 'Failed to load point history: ${e.toString()}',
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
    _loadHistory();
  }

  String _formatDateTime(String startedAt) {
    final localTime = DateTime.parse(startedAt).toLocal();
    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final year = localTime.year;
    
    final hour = localTime.hour == 0 ? 12 : (localTime.hour > 12 ? localTime.hour - 12 : localTime.hour);
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = localTime.hour >= 12 ? 'PM' : 'AM';
    
    return '$day/$month/$year - ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Widget _buildPointsCard(int points) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF232321).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Medal/Star Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF2E2E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SVG(
                'assets/icons/point.svg',
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Balance',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$points pts',
            style: const TextStyle(
              fontFamily: AppTextStyles.titleFontFamily,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Keep focusing to earn more points!',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF34C759),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(FocusSession session) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFECECED), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Points Icon + Text
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2E2E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const SVG(
              'assets/icons/point.svg',
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Title & Subtitle (Date)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus session: ${session.categoryName}',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(session.startedAt),
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Earned Points Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${session.earnedPoints} pts',
                style: const TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF2E2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${session.actualMinutes} mins',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  color: AppColors.secondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFECECED), width: 1),
            ),
          ),
          child: Row(
            children: [
              ShimmerPlaceholder.circular(size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerPlaceholder.rectangular(
                      width: 150,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    ShimmerPlaceholder.rectangular(
                      width: 100,
                      height: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerPlaceholder.rectangular(
                    width: 50,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 40,
                    height: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SVG(
              'assets/illustrations/dead_plant.svg',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'No point history yet',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your first focus session to start earning points!',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
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
    final authStatus = ref.watch(authProvider);
    final int points = authStatus.rankPoints ?? 0;

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
              title: 'My Points',
            ),

            // Prominent Points Card
            _buildPointsCard(points),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'Point History',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

            // History List
            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : (_sessions.isEmpty
                      ? _buildEmptyState()
                      : CupertinoScrollbar(
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _sessions.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _sessions.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Loader(size: 24),
                                  ),
                                );
                              }

                              final session = _sessions[index];
                              return _buildHistoryItem(session);
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
