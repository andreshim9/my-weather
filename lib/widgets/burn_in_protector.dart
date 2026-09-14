import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// OLED/AMOLED 화면 잔상(번인) 방지 픽셀 시프트 래퍼 위젯
/// 60초마다 UI 전체 위치를 눈에 띄지 않게 X/Y축으로 1~2픽셀씩 미세 이동시킵니다.
class BurnInProtector extends StatefulWidget {
  final Widget child;

  const BurnInProtector({Key? key, required this.child}) : super(key: key);

  @override
  State<BurnInProtector> createState() => _BurnInProtectorState();
}

class _BurnInProtectorState extends State<BurnInProtector> {
  Timer? _shiftTimer;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // 60초마다 픽셀 시프트 트리거
    _shiftTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _applyPixelShift();
    });
  }

  void _applyPixelShift() {
    if (!mounted) return;
    setState(() {
      // -2픽셀 ~ +2픽셀 사이 미세 변위
      _offsetX = (_random.nextInt(5) - 2).toDouble();
      _offsetY = (_random.nextInt(5) - 2).toDouble();
    });
  }

  @override
  void dispose() {
    _shiftTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(_offsetX, _offsetY, 0.0),
      child: widget.child,
    );
  }
}
