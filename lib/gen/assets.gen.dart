/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/gems.png
  AssetGenImage get gems => const AssetGenImage('assets/images/gems.png');

  /// File path: assets/images/gems_succ.png
  AssetGenImage get gemsSucc =>
      const AssetGenImage('assets/images/gems_succ.png');

  /// File path: assets/images/image_place.png
  AssetGenImage get imagePlace =>
      const AssetGenImage('assets/images/image_place.png');

  /// File path: assets/images/launch_logo.png
  AssetGenImage get launchLogo =>
      const AssetGenImage('assets/images/launch_logo.png');

  /// File path: assets/images/loading.png
  AssetGenImage get loading => const AssetGenImage('assets/images/loading.png');

  /// File path: assets/images/me_vip_bg_0.png
  AssetGenImage get meVipBg0 =>
      const AssetGenImage('assets/images/me_vip_bg_0.png');

  /// File path: assets/images/me_vip_bg_1.png
  AssetGenImage get meVipBg1 =>
      const AssetGenImage('assets/images/me_vip_bg_1.png');

  /// File path: assets/images/me_vip_icon.png
  AssetGenImage get meVipIcon =>
      const AssetGenImage('assets/images/me_vip_icon.png');

  /// File path: assets/images/me_vip_person.png
  AssetGenImage get meVipPerson =>
      const AssetGenImage('assets/images/me_vip_person.png');

  /// File path: assets/images/member.png
  AssetGenImage get member => const AssetGenImage('assets/images/member.png');

  /// File path: assets/images/no_data.png
  AssetGenImage get noData => const AssetGenImage('assets/images/no_data.png');

  /// File path: assets/images/no_loading.png
  AssetGenImage get noLoading =>
      const AssetGenImage('assets/images/no_loading.png');

  /// File path: assets/images/no_network.png
  AssetGenImage get noNetwork =>
      const AssetGenImage('assets/images/no_network.png');

  /// File path: assets/images/page_bg.png
  AssetGenImage get pageBg => const AssetGenImage('assets/images/page_bg.png');

  /// File path: assets/images/page_pg_me.png
  AssetGenImage get pagePgMe =>
      const AssetGenImage('assets/images/page_pg_me.png');

  /// File path: assets/images/rate_icon.png
  AssetGenImage get rateIcon =>
      const AssetGenImage('assets/images/rate_icon.png');

  /// File path: assets/images/selected.png
  AssetGenImage get selected =>
      const AssetGenImage('assets/images/selected.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        gems,
        gemsSucc,
        imagePlace,
        launchLogo,
        loading,
        meVipBg0,
        meVipBg1,
        meVipIcon,
        meVipPerson,
        member,
        noData,
        noLoading,
        noNetwork,
        pageBg,
        pagePgMe,
        rateIcon,
        selected
      ];
}

class $AssetsLocalesGen {
  const $AssetsLocalesGen();

  /// File path: assets/locales/en.json
  String get en => 'assets/locales/en.json';

  /// List of all assets
  List<String> get values => [en];
}

class $AssetsSvgGen {
  const $AssetsSvgGen();

  /// File path: assets/svg/back.svg
  String get back => 'assets/svg/back.svg';

  /// File path: assets/svg/close.svg
  String get close => 'assets/svg/close.svg';

  /// File path: assets/svg/filter.svg
  String get filter => 'assets/svg/filter.svg';

  /// File path: assets/svg/like.svg
  String get like => 'assets/svg/like.svg';

  /// File path: assets/svg/search.svg
  String get search => 'assets/svg/search.svg';

  /// File path: assets/svg/tab_chat.svg
  String get tabChat => 'assets/svg/tab_chat.svg';

  /// File path: assets/svg/tab_creat.svg
  String get tabCreat => 'assets/svg/tab_creat.svg';

  /// File path: assets/svg/tab_home.svg
  String get tabHome => 'assets/svg/tab_home.svg';

  /// File path: assets/svg/tab_me.svg
  String get tabMe => 'assets/svg/tab_me.svg';

  /// List of all assets
  List<String> get values =>
      [back, close, filter, like, search, tabChat, tabCreat, tabHome, tabMe];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLocalesGen locales = $AssetsLocalesGen();
  static const $AssetsSvgGen svg = $AssetsSvgGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
