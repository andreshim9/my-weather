import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import '../models/sun_time_model.dart';
import '../models/weather_model.dart';
import 'sun_arc_widget.dart';
import 'weather_detail_card.dart';

class DayViewWidget extends StatelessWidget {
  final WeatherModel weather;
  final SunTimeModel sunTime;

  const DayViewWidget({
    Key? key,
    required this.weather,
    required this.sunTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final boxBg = isDark ? AppColors.darkSurfaceLight.withValues(alpha: 0.6) : const Color(0xFFF1F5F9);

    final timeFormat = DateFormat('HH:mm');
    final dayLength = sunTime.sunset.difference(sunTime.sunrise);
    final dayLengthStr = '시간 분';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Current Weather Big Card
          WeatherDetailCard(weather: weather),
          const SizedBox(height: 16),

          // 2. Sun Arc Widget
          SunArcWidget(sunTime: sunTime),
          const SizedBox(height: 16),

          // 3. Astronomical Details Card
          Container(
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
                Row(
                  children: [
                    const Icon(Icons.wb_twilight, color: AppColors.primary, size: 26),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '오늘의 태양 & 일조 상세',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 320;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _buildDetailSlot(
                            title: '☀️ 낮의 총 길이',
                            value: dayLengthStr,
                            subtitle: '일출부터 일몰까지',
                            color: AppColors.accentSun,
                            boxBg: boxBg,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailSlot(
                            title: '🌞 태양 남중',
                            value: timeFormat.format(sunTime.solarNoon),
                            subtitle: '가장 높이 뜬 시각',
                            color: AppColors.primary,
                            boxBg: boxBg,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailSlot(
                            title: '🌅 아침 여명(시민박명)',
                            value: timeFormat.format(sunTime.dawn),
                            subtitle: '해 뜨기 전 밝아지는 시각',
                            color: AppColors.accentSun,
                            boxBg: boxBg,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailSlot(
                            title: '🌇 저녁 황혼(시민박명)',
                            value: timeFormat.format(sunTime.dusk),
                            subtitle: '해 지고 어두워지는 시각',
                            color: AppColors.accentSunset,
                            boxBg: boxBg,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailSlot(
                                title: '☀️ 낮의 총 길이',
                                value: dayLengthStr,
                                subtitle: '일출부터 일몰까지',
                                color: AppColors.accentSun,
                                boxBg: boxBg,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailSlot(
                                title: '🌞 태양 남중',
                                value: timeFormat.format(sunTime.solarNoon),
                                subtitle: '가장 높이 뜬 시각',
                                color: AppColors.primary,
                                boxBg: boxBg,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailSlot(
                                title: '🌅 아침 여명(시민박명)',
                                value: timeFormat.format(sunTime.dawn),
                                subtitle: '해 뜨기 전 밝아지는 시각',
                                color: AppColors.accentSun,
                                boxBg: boxBg,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailSlot(
                                title: '🌇 저녁 황혼(시민박명)',
                                value: timeFormat.format(sunTime.dusk),
                                subtitle: '해 지고 어두워지는 시각',
                                color: AppColors.accentSunset,
                                boxBg: boxBg,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. 24-Hour Temperature Timeline
          if (weather.hourlyForecasts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '시간대별 기온 변화',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weather.hourlyForecasts.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final h = weather.hourlyForecasts[index];
                        return Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: boxBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '시',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(h.weatherIcon, style: const TextStyle(fontSize: 22)),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '°',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSlot({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color boxBg,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
