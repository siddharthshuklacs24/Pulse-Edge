import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../core/constants.dart';

// ================================================================
// Live Intensity Chart
// Appends a new data point every time intensityProvider updates.
// Displays last 30 readings (= 5 minutes at 10-second intervals).
// Horizontal reference lines show activity boundaries.
// ================================================================

class LiveChart extends ConsumerStatefulWidget {
  const LiveChart({super.key});

  @override
  ConsumerState<LiveChart> createState() => _LiveChartState();
}

class _LiveChartState extends ConsumerState<LiveChart> {
  final List<FlSpot> _points = [];
  double _xTime = 0;

  static const int _maxPoints = 30; // 30 × 10s = 5 minutes

  @override
  Widget build(BuildContext context) {
    // 🟢 BACKEND LOGIC: Listen for provider updates (From Main)
    ref.listen<double>(intensityProvider, (previous, next) {
      setState(() {
        _points.add(FlSpot(_xTime, next));
        _xTime += 10; // Each point = 10 seconds
        if (_points.length > _maxPoints) {
          _points.removeAt(0);
        }
      });
    });

    // Seed with current value if empty (first build)
    if (_points.isEmpty) {
      final current = ref.read(intensityProvider);
      _points.add(FlSpot(0, current));
    }

    // Compute x-axis range for sliding window
    final double xMin = _points.first.x;
    final double xMax = _points.last.x + 1;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          minX: xMin,
          maxX: xMax,

          // 🎨 UI: Gradient Grid and Lines (From Branch)
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),

          // 🎨 UI: Titles (From Branch - keeping it clean)
          titlesData: const FlTitlesData(show: false),

          borderData: FlBorderData(show: false),

          // 🎨 UI: Threshold Lines (Integrated constants from Main with Branch styles)
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: INTENSITY_SITTING_MAX,
                color: Colors.blueAccent,
                strokeWidth: 1.5,
                dashArray: [6, 4],
              ),
              HorizontalLine(
                y: INTENSITY_WALKING_MAX,
                color: Colors.orangeAccent,
                strokeWidth: 1.5,
                dashArray: [6, 4],
              ),
            ],
          ),

          // 🎨 UI: Main Intensity Line (From Branch - Gradients & Curves)
          lineBarsData: [
            LineChartBarData(
              spots: _points,
              isCurved: true,
              curveSmoothness: 0.35,
              barWidth: 3,
              isStrokeCapRound: true,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00E5FF),
                  Color(0xFF7C4DFF),
                ],
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300), // Smooth sliding animation
        curve: Curves.easeOut,
      ),
    );
  }
}