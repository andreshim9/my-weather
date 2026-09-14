import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/app_state_provider.dart';

class WidgetSettingsScreen extends StatefulWidget {
  const WidgetSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  bool _isSyncing = false;

  Future<void> _triggerManualSync(AppStateProvider provider) async {
    setState(() => _isSyncing = true);
    await provider.refreshAllData();
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('휴대폰 바탕화면 위젯 정보가 최신으로 업데이트되었습니다!'),
          backgroundColor: AppColors.accentGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isDark = provider.isDarkMode;
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: const Text('📱 바탕화면 위젯 설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Sync Action Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF075985)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '스마트폰 바탕화면 위젯',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '앱을 켜지 않아도 스마트폰 첫 화면에서 날씨와 일출·일몰 시간을 크게 볼 수 있습니다.',
                    style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSyncing ? null : () => _triggerManualSync(provider),
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Icon(Icons.sync, size: 24),
                      label: const Text('지금 바탕화면 위젯 새로고침', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0369A1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Widget 1: 2x1 요약
            const Text(
              '1. 오늘 날씨 & 일출·일몰 요약 위젯 (2x1)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _buildWeatherSunPreview(provider, timeFormat),

            const SizedBox(height: 24),
            // Widget 2: 4x2 태양 상세
            const Text(
              '2. 태양 상세 & 일출·일몰 종합 위젯 (4x2)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _buildSunDetailPreview(provider, timeFormat),

            const SizedBox(height: 24),
            // Widget 3: 4x2 3일간 예보
            const Text(
              '3. 3일간 날씨 & 일출·일몰 예보 위젯 (4x2) ✨신규',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _buildThreeDaysPreview(provider, timeFormat),

            const SizedBox(height: 32),
            _buildSeniorGuideCard(isDark),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSunPreview(AppStateProvider provider, DateFormat timeFormat) {
    final weather = provider.weather;
    final sunTime = provider.sunTime;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weather?.locationName ?? '서울시 중구',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
              ),
              const Text('오늘 날씨', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '°C',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                ' ',
                style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🌅 해뜸 ',
                style: const TextStyle(color: AppColors.accentSun, fontSize: 15, fontWeight: FontWeight.w900),
              ),
              Text(
                '🌇 해짐 ',
                style: const TextStyle(color: AppColors.accentSunset, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSunDetailPreview(AppStateProvider provider, DateFormat timeFormat) {
    final weather = provider.weather;
    final sunTime = provider.sunTime;
    final dayLength = sunTime != null ? sunTime.sunset.difference(sunTime.sunrise) : const Duration(hours: 12, minutes: 36);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weather?.locationName ?? '서울시 중구',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
              ),
              Text(
                '°C  ',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('🌅 일출', style: TextStyle(color: AppColors.accentSun, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      sunTime != null ? timeFormat.format(sunTime.sunrise) : '06:12',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('🌞 남중', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      sunTime != null ? timeFormat.format(sunTime.solarNoon) : '12:30',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('🌇 일몰', style: TextStyle(color: AppColors.accentSunset, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      sunTime != null ? timeFormat.format(sunTime.sunset) : '18:48',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '☀️ 오늘 낮의 총 길이: 시간 분',
            style: const TextStyle(color: AppColors.accentGreen, fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  /// 3. 신규 3일간 예보 위젯 미리보기 카드
  Widget _buildThreeDaysPreview(AppStateProvider provider, DateFormat timeFormat) {
    final weather = provider.weather;
    final weekSun = provider.weekSunDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📍 ',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
              ),
              const Text(
                '3일간 날씨 & 일출몰',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              final title = i == 0 ? '오늘' : (i == 1 ? '내일' : '모레');
              final titleColor = i == 0 ? AppColors.accentSun : (i == 1 ? AppColors.primary : AppColors.accentGreen);
              final forecast = (weather != null && i < weather.dailyForecasts.length) ? weather.dailyForecasts[i] : null;
              final sun = (weekSun.length > i) ? weekSun[i] : null;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: i == 0 ? 0 : 4,
                    right: i == 2 ? 0 : 4,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(title, style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(forecast?.weatherIcon ?? '☀️', style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(
                        forecast != null ? '° / °' : '18° / 26°',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🌅',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        '🌇',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSeniorGuideCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                '바탕화면에 위젯 꺼내는 법 (쉬운 안내)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '1. 스마트폰 첫 화면의 빈 곳을 손가락으로 2초간 꾹 누릅니다.\n\n'
            '2. 화면 아래에 나타나는 [위젯] 글자를 누릅니다.\n\n'
            '3. 목록에서 [my-weather]를 찾아 2x1 요약, 4x2 태양종합, 또는 3일간 예보 위젯을 선택해 바탕화면으로 끌어다 놓습니다.\n\n'
            '4. 이제 폰을 켤 때마다 큰 글씨로 날씨와 해 뜨고 지는 시간을 바로 볼 수 있습니다!',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}