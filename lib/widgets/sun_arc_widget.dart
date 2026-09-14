import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import '../models/sun_time_model.dart';

class SunArcWidget extends StatelessWidget {
  final SunTimeModel sunTime;

  const SunArcWidget({Key? key, required this.sunTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final boxBg = isDark ? AppColors.darkSurfaceLight.withValues(alpha: 0.6) : const Color(0xFFF1F5F9);
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Wrapped for large fonts)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wb_sunny_rounded, color: AppColors.accentSun, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    '해 뜨고 지는 시간',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sunTime.isDayTime
                      ? AppColors.accentSun.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sunTime.isDayTime
                        ? AppColors.accentSun.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  sunTime.isDayTime ? '☀️ 낮 (해 뜸)' : '🌙 밤 (해 짐)',
                  style: TextStyle(
                    color: sunTime.isDayTime ? AppColors.accentSun : AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sun Arc Visual Canvas
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunArcPainter(
                progress: sunTime.dayProgress,
                isDay: sunTime.isDayTime,
                altitude: sunTime.sunAltitude,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3 Big Time Slots (일출, 남중, 일몰)
          Row(
            children: [
              Expanded(
                child: _buildBigTimeBox(
                  title: '🌅 일출',
                  time: timeFormat.format(sunTime.sunrise),
                  color: AppColors.accentSun,
                  boxBg: boxBg,
                  textPrimary: textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBigTimeBox(
                  title: '🌞 남중',
                  time: timeFormat.format(sunTime.solarNoon),
                  color: AppColors.primary,
                  boxBg: boxBg,
                  textPrimary: textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBigTimeBox(
                  title: '🌇 일몰',
                  time: timeFormat.format(sunTime.sunset),
                  color: AppColors.accentSunset,
                  boxBg: boxBg,
                  textPrimary: textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigTimeBox({
    required String title,
    required String time,
    required Color color,
    required Color boxBg,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              style: TextStyle(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  final bool isDay;
  final double altitude;
  final bool isDark;

  _SunArcPainter({
    required this.progress,
    required this.isDay,
    required this.altitude,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h - 15;

    // Horizon line
    final horizonPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, horizonY), Offset(w, horizonY), horizonPaint);

    // Arc Path
    final arcPath = Path();
    arcPath.moveTo(20, horizonY);
    arcPath.quadraticBezierTo(w / 2, -15, w - 20, horizonY);

    final arcPaint = Paint()
      ..color = AppColors.accentSun.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(arcPath, arcPaint);

    final t = progress.clamp(0.0, 1.0);
    final p0 = Offset(20, horizonY);
    final p1 = Offset(w / 2, -15);
    final p2 = Offset(w - 20, horizonY);

    final sunX = math.pow(1 - t, 2) * p0.dx + 2 * (1 - t) * t * p1.dx + math.pow(t, 2) * p2.dx;
    final sunY = math.pow(1 - t, 2) * p0.dy + 2 * (1 - t) * t * p1.dy + math.pow(t, 2) * p2.dy;

    // Glow
    final glowPaint = Paint()
      ..color = isDay ? AppColors.accentSun.withValues(alpha: 0.4) : Colors.indigo.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(Offset(sunX, sunY), 22, glowPaint);

    // Sun Center
    final sunPaint = Paint()
      ..color = isDay ? AppColors.accentSun : const Color(0xFF94A3B8);
    canvas.drawCircle(Offset(sunX, sunY), 12, sunPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(sunX - 3, sunY - 3), 4, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDay != isDay ||
        oldDelegate.altitude != altitude ||
        oldDelegate.isDark != isDark;
  }
}
