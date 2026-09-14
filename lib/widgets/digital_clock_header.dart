import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import 'location_select_dialog.dart';

class DigitalClockHeader extends StatefulWidget {
  final String locationName;
  final bool isCustomLocation;
  final bool isLandscape;

  const DigitalClockHeader({
    Key? key,
    required this.locationName,
    this.isCustomLocation = false,
    this.isLandscape = false,
  }) : super(key: key);

  @override
  State<DigitalClockHeader> createState() => _DigitalClockHeaderState();
}

class _DigitalClockHeaderState extends State<DigitalClockHeader> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(_currentTime);
    final secStr = DateFormat(':ss').format(_currentTime);
    final dateStr = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(_currentTime);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: widget.isLandscape ? 20 : 16,
        horizontal: widget.isLandscape ? 24 : 16,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: widget.isLandscape ? 0 : 16,
        vertical: widget.isLandscape ? 0 : 6,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Clickable Location Badge & Date (Wrapped for font scale flexibility)
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              InkWell(
                onTap: () => LocationSelectDialog.show(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isCustomLocation ? Icons.place : Icons.my_location,
                        color: widget.isCustomLocation ? AppColors.accentSun : AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.locationName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.isCustomLocation ? AppColors.accentSun : AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isLandscape ? 12 : 6),

          // Big Glowing Live Clock (HH:mm :ss) with FittedBox to prevent overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0F2FE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: widget.isLandscape ? 72 : 54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      height: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accentSun, AppColors.accentSunset],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    secStr,
                    style: TextStyle(
                      fontSize: widget.isLandscape ? 36 : 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white,
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
