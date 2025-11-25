import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:flutter/material.dart';

class FRate extends StatefulWidget {
  const FRate({super.key, required this.msg});

  final String msg;

  @override
  State<FRate> createState() => _FRateState();
}

class _FRateState extends State<FRate> {
  void close() {
    FDialog.dismiss(tag: 'afasdf524151');
  }

  String _text = '';
  int _rate = 0;

  void _onTap(int rate) {
    setState(() {
      _rate = rate;
      if (rate == 1) {
        _text = 'Not satisfied, needs improvement.';
      } else if (rate == 2) {
        _text = "It's okay, could be better.";
      } else if (rate == 3) {
        _text = "Great! I'm loving it.";
      }
    });
  }

  void _onSubmit() {
    close();
    if (_rate == 3) {
      NTN.openAppStoreReview();
    } else {
      NTN.toEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            margin: EdgeInsets.only(top: 28),
            decoration: BoxDecoration(
              color: Color(0xFF333333),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Do You Like Us?',
                      style: ThemeStyle.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      spacing: 6,
                      children: [
                        FButton(
                          onTap: () => _onTap(1),
                          color: _rate == 1
                              ? Color(0x33FDC13F)
                              : Color(0x1AFFFFFF),
                          border: Border.all(
                            color: _rate == 1
                                ? Color(0xFFFFD170)
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          width: 88,
                          height: 88,
                          child: Center(
                            child: Text(
                              '😓',
                              style: TextStyle(
                                fontSize: 34,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        FButton(
                          onTap: () => _onTap(2),
                          color: _rate == 2
                              ? Color(0x33FDC13F)
                              : Color(0x1AFFFFFF),
                          border: Border.all(
                            color: _rate == 2
                                ? Color(0xFFFFD170)
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          width: 88,
                          height: 88,
                          child: Center(
                            child: Text(
                              '😐',
                              style: TextStyle(
                                fontSize: 34,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        FButton(
                          onTap: () => _onTap(3),
                          color: _rate == 3
                              ? Color(0x33FDC13F)
                              : Color(0x1AFFFFFF),
                          border: Border.all(
                            color: _rate == 3
                                ? Color(0xFFFFD170)
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          width: 88,
                          height: 88,
                          child: Center(
                            child: Text(
                              '😊',
                              style: TextStyle(
                                fontSize: 34,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _text,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    FButton(
                      onTap: _rate == 0 ? null : _onSubmit,
                      color: Color(0xFFFFD170),
                      hasShadow: true,
                      boxShadows: [
                        BoxShadow(
                          color: Color(0x4DFFD170),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                      child: Center(
                        child: Text(
                          'Submit',
                          style: ThemeStyle.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF531903),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PositionedDirectional(
            end: 0,
            child: Assets.images.rateIcon.image(width: 90),
          ),
        ],
      ),
    );
  }
}
