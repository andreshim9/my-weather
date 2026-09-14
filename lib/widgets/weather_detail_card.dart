import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/weather_model.dart';

class WeatherDetailCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailCard({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final boxBg = isDark ? AppColors.darkSurfaceLight.withValues(alpha: 0.6) : const Color(0xFFF1F5F9);

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
          // Location Header
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weather.locationName,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Temperature & Weather Icon (Wrapped to prevent overflow on large text)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${weather.weatherDescription} ',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                weather.weatherIcon,
                style: const TextStyle(fontSize: 60),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: isDark ? const Color(0x33FFFFFF) : const Color(0x18000000), height: 1.5),
          const SizedBox(height: 18),

          // 2x2 High-Contrast Details Grid with LayoutBuilder & FittedBox
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 320;
              final humidityStr = '${weather.humidity}%';
              final rainStr = '${weather.precipitationProbability}%';
              final windStr = '${weather.windSpeed.toStringAsFixed(1)} m/s';
              final uvStr = weather.uvIndex <= 2
                  ? '낮음'
                  : (weather.uvIndex <= 5 ? '보통' : '강함');

              if (isNarrow) {
                return Column(
                  children: [
                    _buildBigDetailBox(
                      icon: Icons.water_drop,
                      label: '습도',
                      value: humidityStr,
                      iconColor: AppColors.primary,
                      boxBg: boxBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 8),
                    _buildBigDetailBox(
                      icon: Icons.umbrella,
                      label: '비 올 확률',
                      value: rainStr,
                      iconColor: AppColors.primary,
                      boxBg: boxBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 8),
                    _buildBigDetailBox(
                      icon: Icons.air,
                      label: '바람 세기',
                      value: windStr,
                      iconColor: AppColors.accentGreen,
                      boxBg: boxBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 8),
                    _buildBigDetailBox(
                      icon: Icons.wb_sunny,
                      label: '햇빛(자외선)',
                      value: uvStr,
                      iconColor: AppColors.accentSun,
                      boxBg: boxBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildBigDetailBox(
                          icon: Icons.water_drop,
                          label: '습도',
                          value: humidityStr,
                          iconColor: AppColors.primary,
                          boxBg: boxBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBigDetailBox(
                          icon: Icons.umbrella,
                          label: '비 올 확률',
                          value: rainStr,
                          iconColor: AppColors.primary,
                          boxBg: boxBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBigDetailBox(
                          icon: Icons.air,
                          label: '바람 세기',
                          value: windStr,
                          iconColor: AppColors.accentGreen,
                          boxBg: boxBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBigDetailBox(
                          icon: Icons.wb_sunny,
                          label: '햇빛(자외선)',
                          value: uvStr,
                          iconColor: AppColors.accentSun,
                          boxBg: boxBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
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
    );
  }

  Widget _buildBigDetailBox({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color boxBg,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
