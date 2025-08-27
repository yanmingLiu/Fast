import 'dart:async';

import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VipTimer extends StatefulWidget {
  const VipTimer({super.key});

  @override
  State<VipTimer> createState() => _VipTimerState();
}

class _VipTimerState extends State<VipTimer> {
  int minutes = 30;
  int seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.expiration_time.tr,
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 4),
        _buildDigit(minutesStr[0]),
        SizedBox(width: 4),
        _buildDigit(minutesStr[1]),
        SizedBox(width: 8),
        Text(
          ':',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        SizedBox(width: 8),
        _buildDigit(secondsStr[0]),
        SizedBox(width: 4),
        _buildDigit(secondsStr[1]),
      ],
    );
  }

  Container _buildDigit(String digit) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds == 0) {
          if (minutes == 0) {
            timer.cancel();
          } else {
            minutes--;
            seconds = 59;
          }
        } else {
          seconds--;
        }
      });
    });
  }
}
