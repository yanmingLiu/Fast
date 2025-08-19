import 'package:fast_ai/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RechargeDialog extends StatelessWidget {
  const RechargeDialog({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.circular(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Assets.images.gemsSucc.image(width: 160, height: 122, fit: BoxFit.cover),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Text(
                '+$number',
                style: GoogleFonts.openSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Gems',
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
