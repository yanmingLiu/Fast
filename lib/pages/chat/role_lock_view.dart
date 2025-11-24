import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/f_service.dart';

class RoleLockView extends StatelessWidget {
  const RoleLockView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log.d('clicked vip space');
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                decoration: BoxDecoration(
                  color: Color(0xFF333333),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      LocaleKeys.unlock_role.tr,
                      style: ThemeStyle.openSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      LocaleKeys.unlock_role_description.tr,
                      textAlign: TextAlign.center,
                      style: ThemeStyle.openSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 32),
                    FButton(
                      color: Color(0xFF3F8DFD),
                      hasShadow: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.unlock_now.tr,
                            style: ThemeStyle.openSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              size: 16, color: Colors.white),
                        ],
                      ),
                      onTap: () {
                        AppRouter.pushVip(ProFrom.viprole);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                      color: Colors.transparent, width: 60, height: 44),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
