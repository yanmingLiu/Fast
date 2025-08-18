import 'package:fast_ai/data/role_tags.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:get/get.dart';

enum HomeListCategroy { all, realistic, anime, dressUp, video }

// 为枚举添加扩展，提供title和icon等属性
extension HomeListCategoryExtension on HomeListCategroy {
  String get title {
    switch (this) {
      case HomeListCategroy.all:
        return LocaleKeys.all.tr;
      case HomeListCategroy.realistic:
        return LocaleKeys.realistic.tr;
      case HomeListCategroy.anime:
        return LocaleKeys.anime.tr;
      case HomeListCategroy.dressUp:
        return LocaleKeys.dress_up.tr;
      case HomeListCategroy.video:
        return LocaleKeys.video.tr;
    }
  }

  int get index => HomeListCategroy.values.indexOf(this);
}

class HomeCtr extends GetxController {
  var categroyList = <HomeListCategroy>[].obs;
  var categroy = HomeListCategroy.all.obs;

  //
  Rx<Set<RoleTag>> filterEvent = Rx<Set<RoleTag>>({});

  // 关注
  Rx<(FollowEvent, String)> followEvent = (FollowEvent.follow, '').obs;

  @override
  void onInit() {
    super.onInit();

    categroyList.addAll([
      HomeListCategroy.all,
      HomeListCategroy.realistic,
      HomeListCategroy.anime,
      HomeListCategroy.video,
      HomeListCategroy.dressUp,
    ]);
  }

  void onTapCate(HomeListCategroy value) {
    categroy.value = value;
  }

  void onTapFilter() {}
}
