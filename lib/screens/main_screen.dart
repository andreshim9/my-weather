import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../services/update_service.dart';
import '../widgets/burn_in_protector.dart';
import '../widgets/day_view_widget.dart';
import '../widgets/digital_clock_header.dart';
import '../widgets/font_size_dialog.dart';
import '../widgets/location_select_dialog.dart';
import '../widgets/month_view_widget.dart';
import '../widgets/week_view_widget.dart';
import 'widget_settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 GitHub Releases 최신 버전 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  Future<void> _checkForAppUpdate() async {
    final info = await UpdateService.checkUpdate();
    if (info != null && info.hasUpdate && mounted) {
      UpdateService.showUpdateDialog(context, info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isDark = provider.isDarkMode;

    if (provider.isLoading && provider.weather == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4),
        ),
      );
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: isLandscape ? 48 : 56,
            title: Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: AppColors.accentSun, size: 24),
                const SizedBox(width: 8),
                Text(
                  'my-weather',
                  style: TextStyle(
                    fontSize: isLandscape ? 18 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            actions: [
              // Font Size Dialog Button (A±)
              IconButton(
                icon: const Icon(Icons.format_size_rounded, size: 22, color: AppColors.primary),
                onPressed: () => FontSizeDialog.show(context),
                tooltip: '글자 크기 조절',
              ),
              // Theme Toggle Button (Light ☀️ / Dark 🌙)
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  size: 22,
                  color: isDark ? AppColors.accentSun : AppColors.primary,
                ),
                onPressed: () => provider.toggleTheme(),
                tooltip: isDark ? '화이트 모드로 전환' : '다크 모드로 전환',
              ),
              // Location Change Button
              IconButton(
                icon: Icon(
                  provider.isCustomLocation ? Icons.place : Icons.my_location,
                  size: 22,
                  color: provider.isCustomLocation ? AppColors.accentSun : AppColors.primary,
                ),
                onPressed: () => LocationSelectDialog.show(context),
                tooltip: '위치 검색 및 저장된 위치',
              ),
              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 22, color: AppColors.primary),
                onPressed: () => provider.refreshAllData(),
                tooltip: '새로고침',
              ),
              // Widget Settings Button
              IconButton(
                icon: const Icon(Icons.widgets_outlined, size: 22, color: AppColors.accentSun),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WidgetSettingsScreen()),
                  );
                },
                tooltip: '바탕화면 위젯 설정',
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: BurnInProtector(
            child: isLandscape
                ? _buildLandscapeLayout(context, provider, isDark)
                : _buildPortraitLayout(context, provider, isDark),
          ),
        );
      },
    );
  }

  /// 세로 모드 레이아웃
  Widget _buildPortraitLayout(BuildContext context, AppStateProvider provider, bool isDark) {
    return Column(
      children: [
        // 1. Top Center Big Live Clock Header
        DigitalClockHeader(
          locationName: provider.currentLocationName,
          isCustomLocation: provider.isCustomLocation,
          isLandscape: false,
        ),

        // 2. Segmented View Mode Switcher (하루 보기 / 일주일 보기 / 한달 보기)
        _buildSegmentedTabBar(context, provider, isDark),

        // 3. Main View Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.refreshAllData(),
            color: AppColors.primary,
            child: _buildCurrentView(provider),
          ),
        ),
      ],
    );
  }

  /// 가로 모드 (탁상시계 특화 2컬럼 레이아웃)
  Widget _buildLandscapeLayout(BuildContext context, AppStateProvider provider, bool isDark) {
    final weather = provider.weather;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column (45% Width): Prominent Big Clock & Live Summary Box
        Expanded(
          flex: 45,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, top: 10, right: 8, bottom: 12),
            child: Column(
              children: [
                // Prominent Big Clock
                DigitalClockHeader(
                  locationName: provider.currentLocationName,
                  isCustomLocation: provider.isCustomLocation,
                  isLandscape: true,
                ),
                const SizedBox(height: 12),

                // Quick Weather & Sun Summary Card on Landscape Left
                if (weather != null && provider.sunTime != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  weather.weatherIcon,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '°C',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      weather.weatherDescription,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '🌅 :',
                                  style: const TextStyle(
                                    color: AppColors.accentSun,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '🌇 :',
                                  style: const TextStyle(
                                    color: AppColors.accentSunset,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Right Column (55% Width): Tabs & Scrollable Content
        Expanded(
          flex: 55,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 6, right: 16, bottom: 4),
                child: _buildSegmentedTabBar(context, provider, isDark),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refreshAllData(),
                  color: AppColors.primary,
                  child: _buildCurrentView(provider),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context, AppStateProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildSegmentButton(
            context,
            title: '하루 보기',
            icon: Icons.wb_sunny,
            mode: ViewMode.day,
            currentMode: provider.viewMode,
            isDark: isDark,
            onTap: () => provider.setViewMode(ViewMode.day),
          ),
          const SizedBox(width: 4),
          _buildSegmentButton(
            context,
            title: '일주일 보기',
            icon: Icons.calendar_view_week,
            mode: ViewMode.week,
            currentMode: provider.viewMode,
            isDark: isDark,
            onTap: () => provider.setViewMode(ViewMode.week),
          ),
          const SizedBox(width: 4),
          _buildSegmentButton(
            context,
            title: '한달 보기',
            icon: Icons.calendar_month,
            mode: ViewMode.month,
            currentMode: provider.viewMode,
            isDark: isDark,
            onTap: () => provider.setViewMode(ViewMode.month),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ViewMode mode,
    required ViewMode currentMode,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final unselectedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : unselectedColor,
              ),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : unselectedColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView(AppStateProvider provider) {
    if (provider.weather == null || provider.sunTime == null) {
      return const Center(child: Text('데이터를 불러올 수 없습니다.'));
    }

    switch (provider.viewMode) {
      case ViewMode.day:
        return DayViewWidget(
          weather: provider.weather!,
          sunTime: provider.sunTime!,
        );
      case ViewMode.week:
        return WeekViewWidget(
          weather: provider.weather!,
          weekSunDays: provider.weekSunDays,
        );
      case ViewMode.month:
        return MonthViewWidget(
          selectedYear: provider.selectedYear,
          selectedMonth: provider.selectedMonth,
          monthSunDays: provider.monthSunDays,
          selectedDay: provider.selectedCalendarDay,
          onMonthChanged: (year, month) => provider.changeMonth(year, month),
          onDaySelected: (day) => provider.selectCalendarDay(day),
        );
    }
  }
}
