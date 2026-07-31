import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class ExploreChartSection extends StatefulWidget {
  const ExploreChartSection({super.key});

  @override
  State<ExploreChartSection> createState() => _ExploreChartSectionState();
}

class _ExploreChartSectionState extends State<ExploreChartSection> {
  int _selectedIndex = 6; // By default, show tooltip for the last bar (10.12)

  final List<Map<String, dynamic>> chartData = const [
    {'day': '10.6', 'value': 22.0, 'active': true},
    {'day': '10.7', 'value': 10.0, 'active': true},
    {'day': '10.8', 'value': 3.0, 'active': false},
    {'day': '10.9', 'value': 14.0, 'active': true},
    {'day': '10.10', 'value': 3.0, 'active': false},
    {'day': '10.11', 'value': 10.0, 'active': true},
    {'day': '10.12', 'value': 18.0, 'active': true},
  ];

  @override
  Widget build(BuildContext context) {
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
                    color: AppColors.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '12',
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
          _buildRecentFocusChart(),
        ],
      ),
    );
  }

  Widget _buildRecentFocusChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double barWidth = 30.0;
        final int totalBars = chartData.length;
        final double totalBarsWidth = totalBars * barWidth;
        // spaceEvenly has space at start, end, and between all bars (totalBars + 1 spaces)
        final double spaceWidth =
            (totalWidth - totalBarsWidth) / (totalBars + 1);

        double? centerX;
        double? bottomDistance;
        String? tooltipText;

        if (_selectedIndex >= 0 && _selectedIndex < totalBars) {
          final double leftEdge =
              (_selectedIndex + 1) * spaceWidth + _selectedIndex * barWidth;
          centerX = leftEdge + (barWidth / 2);

          final double value = (chartData[_selectedIndex]['value'] as num)
              .toDouble();
          final double chartGridHeight =
              170.0 - 32.0; // container height - bottom titles reserved size
          final double barHeight =
              chartGridHeight * (value / 26.0); // maxY is 26
          final double yTop = chartGridHeight - barHeight;
          bottomDistance = 170.0 - yTop + 4.0; // 4px margin above the bar
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
                  maxY: 26,
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
                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox();
                          }
                          final String day = chartData[index]['day'].toString();
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
                  barGroups: List.generate(chartData.length, (index) {
                    final data = chartData[index];
                    final double val = (data['value'] as num).toDouble();
                    final bool isActive = data['active'] as bool;
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
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                      if (response != null && response.spot != null) {
                        setState(() {
                          _selectedIndex = response.spot!.touchedBarGroupIndex;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            if (centerX != null &&
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
