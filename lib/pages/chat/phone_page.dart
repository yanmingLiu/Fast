import 'dart:async';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/phone_ctr.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> with RouteAware {
  final ctr = Get.put(PhoneCtr());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Obx(() {
          var callState = ctr.callState.value;
          if (callState == CallState.incoming) {
            return SafeArea(
              child: Padding(padding: const EdgeInsets.all(16), child: _buildContainer()),
            );
          }
          return _buildContainer();
        }),
      ),
    );
  }

  Stack _buildContainer() {
    return Stack(
      children: [
        Positioned.fill(
          child: FImage(
            url: ctr.guideVideo?.gifUrl ?? ctr.role.avatar,
            borderRadius: BorderRadius.circular(ctr.callState.value == CallState.incoming ? 24 : 0),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: SafeArea(
            child: Column(
              children: [
                PhoneTitle(role: ctr.role),
                SizedBox(height: 12),
                Obx(() => _buildTimer()),
                Expanded(child: Container()),
                Obx(() => _buildLoading()),
                _buildAnswering(),
                SizedBox(height: 30),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: _buildButtons()),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    if (ctr.callState.value == CallState.calling ||
        ctr.callState.value == CallState.answering ||
        ctr.callState.value == CallState.listening) {
      return LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40);
    }
    return Container();
  }

  Widget _buildTimer() {
    if (ctr.showFormattedDuration.value) {
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0x333F8DFD),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF04A4C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: 8,
                      height: 8,
                    ),
                    Text(
                      ctr.formattedDuration(ctr.callDuration.value),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildAnswering() {
    final text = ctr.callStateDescription(ctr.callState.value);
    if (text.isEmpty) {
      return Container();
    }

    return SizedBox(
      width: Get.width - 60,
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          child: AnimatedTextKit(
            key: ValueKey(ctr.callState.value),
            totalRepeatCount: 1,
            animatedTexts: [TypewriterAnimatedText(text, speed: const Duration(milliseconds: 50))],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    List<Widget> buttons = [PhoneBtn(icon: Assets.images.hangup.image(), onTap: ctr.onTapHangup)];

    if (ctr.callState.value == CallState.incoming) {
      buttons.add(PhoneBtn(icon: Assets.images.accept.image(), onTap: ctr.onTapAccept));
    }

    if (ctr.callState.value == CallState.listening) {
      buttons.add(
        PhoneBtn(
          icon: Assets.images.micon.image(),
          animationColor: const Color(0xFF3F8DFD),
          onTap: () => ctr.onTapMic(false),
        ),
      );
    }

    if (ctr.callState.value == CallState.answering ||
        ctr.callState.value == CallState.micOff ||
        ctr.callState.value == CallState.answered) {
      buttons.add(PhoneBtn(icon: Assets.images.micoff.image(), onTap: () => ctr.onTapMic(true)));
    }

    return buttons;
  }
}

class PhoneBtn extends StatelessWidget {
  const PhoneBtn({
    super.key,
    required this.icon,
    this.animationColor,
    required this.onTap,
    this.isLinearGradientBg = false,
  });

  final Widget icon;
  final bool isLinearGradientBg;
  final Color? animationColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(borderRadius: BorderRadiusDirectional.circular(36)),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (animationColor != null)
                    WaterRippleEffect(
                      width: 72,
                      height: 72,
                      color: animationColor!,
                      borderWidth: 1.0,
                      rippleSpacing: 300, // ripple interval in milliseconds
                      scaleMultiplier: 0.5, // adjust the scale multiplier to reduce the size change
                    ),
                  icon,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneTitle extends StatelessWidget {
  const PhoneTitle({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Color(0x801C1C1C),
                borderRadius: BorderRadius.circular(30),
              ),
              constraints: BoxConstraints(maxWidth: context.mediaQuerySize.width / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      FImage(
                        url: role.avatar,
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.name ?? '',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (role.age != null)
                            Text(
                              LocaleKeys.age_years_olds.trParams({'age': role.age.toString()}),
                              style: GoogleFonts.openSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFDEDEDE),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WaterRippleEffect extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final double borderWidth;
  final int rippleSpacing;
  final double scaleMultiplier;

  const WaterRippleEffect({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.borderWidth,
    required this.rippleSpacing,
    required this.scaleMultiplier,
  });

  @override
  State<WaterRippleEffect> createState() => _WaterRippleEffectState();
}

class _WaterRippleEffectState extends State<WaterRippleEffect> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Timer> _timers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(vsync: this, duration: const Duration(seconds: 1));
    });

    _animations = _controllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.linear);
    }).toList();

    _timers = List.generate(3, (index) {
      return Timer(Duration(milliseconds: widget.rippleSpacing * index), () {
        _controllers[index].repeat();
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            double scale = 1.0 + _animations[index].value * widget.scaleMultiplier;
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: 1.0 - _animations[index].value,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color, width: widget.borderWidth),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
