import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lorofy/features/explore/domain/models/focus_stats.dart';
import 'package:lorofy/features/explore/presentation/providers/explore_stats_provider.dart';

class ExploreChartSection extends ConsumerStatefulWidget {
  const ExploreChartSection({super.key});

  @override
  ConsumerState<ExploreChartSection> createState() => _ExploreChartSectionState();
}

class _ExploreChartSectionState extends ConsumerState<ExploreChartSection> {
  int? _selectedIndex;

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}.${date.day}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(exploreStatsProvider);

    return statsAsync.when(
      loading: () => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        height: 230,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShimmerPlaceholder.rectangular(height: 24, width: 120),
            SizedBox(height: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerPlaceholder.rectangular(height: 80, width: 30, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ShimmerPlaceholder.rectangular(height: 120, width: 30, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ShimmerPlaceholder.rectangular(height: 40, width: 30, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ShimmerPlaceholder.rectangular(height: 100, width: 30, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ShimmerPlaceholder.rectangular(height: 60, width: 30, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ShimmerPlaceholder.rectangular(height: 90, width: 30, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ShimmerPlaceholder.rectangular(height: 110, width: 30, borderRadius: BorderRadius.all(Radius.circular(8))),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (err, stack) => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        height: 230,
        child: Center(
          child: Text(
            'Error loading chart: $err',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: CupertinoColors.systemRed,
            ),
          ),
        ),
      ),
      data: (stats) {
        final weeklyProgress = stats.weeklyProgress;

        if (_selectedIndex == null && weeklyProgress.isNotEmpty) {
          _selectedIndex = weeklyProgress.length - 1;
        }

        final double totalMinutes = weeklyProgress.fold(0.0, (sum, e) => sum + e.minutes);
        final int dailyAverage = weeklyProgress.isNotEmpty
            ? (totalMinutes / weeklyProgress.length).round()
            : 0;

        return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Recent Focus Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Focus',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Daily Average ',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: AppColors.mutedForeground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: dailyAverage.toString(),
                          style: TextStyle(
                            fontFamily: AppTextStyles.titleFontFamily,
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecentFocusChart(weeklyProgress),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentFocusChart(List<DailyProgress> weeklyProgress) {
    if (weeklyProgress.isEmpty) {
      return const SizedBox(
        height: 170,
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double barWidth = 30.0;
        final int totalBars = weeklyProgress.length;
        final double totalBarsWidth = totalBars * barWidth;
        final double spaceWidth =
            (totalWidth - totalBarsWidth) / (totalBars + 1);

        double? centerX;
        double? bottomDistance;
        String? tooltipText;

        final double maxVal = weeklyProgress
            .map((e) => e.minutes.toDouble())
            .reduce((a, b) => a > b ? a : b);
        final double maxY = maxVal > 20 ? maxVal * 1.2 : 26.0;

        final bool isAllZero = weeklyProgress.every((e) => e.minutes == 0);

        if (!isAllZero && _selectedIndex != null && _selectedIndex! >= 0 && _selectedIndex! < totalBars) {
          final double leftEdge =
              (_selectedIndex! + 1) * spaceWidth + _selectedIndex! * barWidth;
          centerX = leftEdge + (barWidth / 2);

          final double value = weeklyProgress[_selectedIndex!].minutes.toDouble();
          final double chartGridHeight = 170.0 - 32.0;
          final double barHeight = chartGridHeight * (value / maxY);
          final double yTop = chartGridHeight - barHeight;
          bottomDistance = 170.0 - yTop + 4.0;
          tooltipText = value.toInt().toString();
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 170,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF232321), width: 2.0),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= weeklyProgress.length) {
                            return const SizedBox();
                          }
                          final String day = _formatDate(weeklyProgress[index].date);
                          return SideTitleWidget(
                            meta: meta,
                            space: 8,
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(weeklyProgress.length, (index) {
                    final data = weeklyProgress[index];
                    final double val = data.minutes.toDouble();
                    final bool isActive = val > 0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          color: isActive
                              ? const Color(0xFF072013)
                              : const Color(0xFFE5E5EA),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    enabled: !isAllZero,
                    handleBuiltInTouches: false,
                    touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                      if (!isAllZero && response != null && response.spot != null) {
                        setState(() {
                          _selectedIndex = response.spot!.touchedBarGroupIndex;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            if (isAllZero)
              Positioned.fill(
                bottom: 32,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No focus data this week 🌿',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: AppColors.mutedForeground,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            if (!isAllZero &&
                centerX != null &&
                bottomDistance != null &&
                tooltipText != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: centerX - 50,
                width: 100,
                bottom: bottomDistance,
                child: Center(
                  child: _TooltipWithArrow(
                    text: tooltipText,
                    backgroundColor: const Color(0xFF072013),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TooltipWithArrow extends StatelessWidget {
  final String text;
  final Color backgroundColor;

  const _TooltipWithArrow({required this.text, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              text,
              key: ValueKey<String>(text),
              style: const TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(10, 5),
          painter: _TrianglePainter(color: backgroundColor),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w * 0.7, h * 0.5)
      ..quadraticBezierTo(w / 2, h, w * 0.3, h * 0.5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
