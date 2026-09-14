import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import '../models/month_sun_day_model.dart';

class MonthViewWidget extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final List<MonthSunDayModel> monthSunDays;
  final MonthSunDayModel? selectedDay;
  final Function(int year, int month) onMonthChanged;
  final Function(MonthSunDayModel day) onDaySelected;

  const MonthViewWidget({
    Key? key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.monthSunDays,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();

    final firstDayOfWeek = DateTime(selectedYear, selectedMonth, 1).weekday;
    final leadingEmptyCells = (firstDayOfWeek % 7);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Month Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 32, color: AppColors.primary),
                  onPressed: () {
                    if (selectedMonth == 1) {
                      onMonthChanged(selectedYear - 1, 12);
                    } else {
                      onMonthChanged(selectedYear, selectedMonth - 1);
                    }
                  },
                ),
                Text(
                  '$selectedYear년 $selectedMonth월',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 32, color: AppColors.primary),
                  onPressed: () {
                    if (selectedMonth == 12) {
                      onMonthChanged(selectedYear + 1, 1);
                    } else {
                      onMonthChanged(selectedYear, selectedMonth + 1);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Selected Day Highlight Card
          if (selectedDay != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFF1F5F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedDay!.date.month}월 ${selectedDay!.date.day}일 태양 정보',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (selectedDay!.solarTerm != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.accentGreen),
                          ),
                          child: Text(
                            selectedDay!.solarTerm!,
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailSlot(
                          title: '🌅 일출 (해뜸)',
                          value: timeFormat.format(selectedDay!.sunrise),
                          color: AppColors.accentSun,
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDetailSlot(
                          title: '🌇 일몰 (해짐)',
                          value: timeFormat.format(selectedDay!.sunset),
                          color: AppColors.accentSunset,
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailSlot(
                          title: '☀️ 낮의 총 길이',
                          value: selectedDay!.formattedDayLength,
                          color: AppColors.primary,
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDetailSlot(
                          title: '🌞 남중 시각',
                          value: timeFormat.format(selectedDay!.solarNoon),
                          color: textPrimary,
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3. Calendar Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Weekday Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WeekdayText('일', isSunday: true, isDark: isDark),
                    _WeekdayText('월', isDark: isDark),
                    _WeekdayText('화', isDark: isDark),
                    _WeekdayText('수', isDark: isDark),
                    _WeekdayText('목', isDark: isDark),
                    _WeekdayText('금', isDark: isDark),
                    _WeekdayText('토', isSaturday: true, isDark: isDark),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: isDark ? const Color(0x33FFFFFF) : const Color(0x18000000), height: 1),
                const SizedBox(height: 12),

                // Calendar Days Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: leadingEmptyCells + monthSunDays.length,
                  itemBuilder: (context, index) {
                    if (index < leadingEmptyCells) {
                      return const SizedBox();
                    }
                    final dayIndex = index - leadingEmptyCells;
                    final dayModel = monthSunDays[dayIndex];
                    final isToday = dayModel.date.year == now.year &&
                        dayModel.date.month == now.month &&
                        dayModel.date.day == now.day;
                    final isSelected = selectedDay?.date.day == dayModel.date.day;

                    final weekday = dayModel.date.weekday;
                    Color dateColor = textPrimary;
                    if (weekday == 7) dateColor = AppColors.accentRed;
                    if (weekday == 6) dateColor = AppColors.primary;

                    return InkWell(
                      onTap: () => onDaySelected(dayModel),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.18)
                              : (isToday
                                  ? (isDark ? AppColors.darkSurfaceLight : const Color(0xFFE2E8F0))
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isToday
                                    ? AppColors.accentSun
                                    : (isDark ? Colors.white10 : Colors.black12)),
                            width: isSelected || isToday ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${dayModel.date.day}',
                              style: TextStyle(
                                color: dateColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeFormat.format(dayModel.sunrise),
                              style: const TextStyle(
                                color: AppColors.accentSun,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              timeFormat.format(dayModel.sunset),
                              style: const TextStyle(
                                color: AppColors.accentSunset,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (dayModel.solarTerm != null)
                              Container(
                                margin: const EdgeInsets.only(top: 1),
                                child: Text(
                                  dayModel.solarTerm!.split(' ')[0],
                                  style: const TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailSlot({
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceLight.withOpacity(0.6) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _WeekdayText extends StatelessWidget {
  final String text;
  final bool isSunday;
  final bool isSaturday;
  final bool isDark;

  const _WeekdayText(this.text, {this.isSunday = false, this.isSaturday = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    if (isSunday) color = AppColors.accentRed;
    if (isSaturday) color = AppColors.primary;

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
