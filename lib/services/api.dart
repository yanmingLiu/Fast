import 'dart:async';
import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:encrypt/encrypt.dart';
import 'package:fast_ai/data/base_data.dart';
import 'package:fast_ai/data/role.dart';
import 'package:fast_ai/data/role_tags.dart';
import 'package:fast_ai/data/session_data.dart';
import 'package:fast_ai/data/user.dart';
import 'package:fast_ai/services/api_service.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:get/get.dart';
import 'package:pointycastle/asymmetric/api.dart';

final api = ApiService();

class ApiPath {
  ApiPath._();

  // 注册
  static const String register = '/v2/user/device/register';
  // 获取用户信息
  static const String getUserInfo = '/v2/appUser/getByDeviceId/user';
  // 修改用户信息
  static const String updateUserInfo = '/v2/appUser/updateUserInfo';
  // 角色列表
  static const String roleList = '/v2/charProfile/getAll';
  // moments list
  static const String momentsList = '/moments/getAll';
  // 根据角色 id 查询角色
  static const String getRoleById = '/v2/charProfile/getById';
  // 用户减钻石
  static const String minusGems = '/v2/appUserDetails/minusGems';
  // 通过角色随机查一条查询
  static const String genRandomOne = '/v2/characterMedia/getByRole/randomOne';
  // 支持 auto-mask 支持角色生成
  static const String undrCharacter = '/isNaked/undressOutcome';
  // undr image result
  static const String undrImageRes = '/isNaked/getUndressResult';
  // undr styles
  static const String undrStyles = '/getStyleConfig';
  // ios 创建订单
  static const String createIosOrder = '/rechargeList/createOrder';
  // iOS 完成订单
  static const String verifyIosReceipt = '/rechargeList/finishOrder';
  // 创建 google 订单
  static const String createAndOrder = '/pay/google/create';
  // 谷歌验签
  static const String verifyAndOrder = '/pay/google/verify';
  // 收藏角色
  static const String collectRole = '/v2/charProfile/collect';
  // 取消收藏角色
  static const String cancelCollectRole = '/v2/charProfile/cancelCollect';
  // 角色标签
  static const String roleTag = '/v2/charProfile/tags';
  // 会话列表
  static const String sessionList = '/aiChatConversation/list';
  // 新增会话
  static const String addSession = '/aiChatConversation/add';
  // 重置会话
  static const String resetSession = '/aiChatConversation/reset';
  // 删除会话
  static const String deleteSession = '/aiChatConversation/delete';
  // 收藏列表
  static const String collectList = '/v2/charProfile/collect/list';
  // 消息列表
  static const String messageList = '/v2/history/getAll';
  // 语音聊天
  static const String voiceChat = '/audioClips/chat';
  // 开屏随机角色
  static const String splashRandomRole = '/plfC/getRecommendRole';
  // 上报事件 用户参数
  static String eventParams = '/v2/user/upinfo';
  // 聊天等级配置
  static String chatLevelConfig = '/system/chatLevelConf';
  // 解锁图片
  static String unlockImage = '/v2/characterProfile/unlockImage';
  // 聊天等级
  static String chatLevel = '/aiChatConversation/getChatLevel';
  // translate
  static String translate = '/translate';
  // 签到
  static String signIn = '/signin';
  // 送礼配置
  static String giftConfig = '/v2/charProfile/getGiftConf';
  // 换装配置
  static String changeConfig = '/v2/charProfile/getClothingConf';
  // 送玩具
  static String sendToy = '/v2/message/gift';
  // 送衣服
  static String sendClothes = '/v2/message/clothes';
  // 保存消息信息
  static String saveMsg = '/v2/history/saveMessage';
  // 用户加钻石
  static String addGems = '/v2/appUser/plusGems';
  // sku 列表
  static String skuList = '/platformConfig/getAllSku';
  // 编辑消息 /v2/message/consumption/editMsg
  static String editMsg = '/v2/message/editMsg';
  // 续写
  static String continueWrite = '/v2/message/resume';
  // 重新发送消息
  static String resendMsg = '/v2/message/resend';
  // 发送消息
  static String sendMsg = '/v2/message/conversation/ask';
  // 修改聊天场景
  static String editScene = '/v2/message/conversation/change';
  // 修改会话模式
  static String editMode = '/aiChatConversation/editMode';
  // 新建 mask
  static String createMask = '/userProfile/add';
  // 编辑 mask
  static String editMask = '/userProfile/update';
  // 获取 mask 列表
  static String getMaskList = '/userProfile/getAll';
  // 切换 mask
  static String changeMask = '/v2/message/conversation/changeArchive';
  // 各种价格配置
  static String getPriceConfig = '/system/price/config';
  // 删除mask
  static String deleteMask = '/userProfile/del';
}

class Api {
  Api._();

  static Map<String, dynamic> get _qp => AppCache().isBig ? {'v': 'C001'} : {};

  static Future<User?> register() async {
    try {
      final deviceId = await AppCache().phoneId();
      var res = await api.post(
        ApiPath.register,
        body: {"device_id": deviceId, "platform": AppService().platform},
      );
      if (!res.isOk) {
        return null;
      }
      final user = User.fromJson(res.body);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> getUserInfo() async {
    try {
      final deviceId = await AppCache().phoneId();
      final res = await api.get(ApiPath.getUserInfo, queryParameters: {'device_id': deviceId});
      if (!res.isOk) {
        return null;
      }
      final user = User.fromJson(res.body);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUserInfo(Map<String, dynamic> body) async {
    try {
      final res = await api.post(ApiPath.updateUserInfo, body: body);
      final reult = BaseData.fromJson(res.body, null);
      return reult.data;
    } catch (e) {
      return false;
    }
  }

  /// 获取角色标签列表。
  ///
  /// 通过调用 API 接口 [ApiPath.roleTag] 获取角色标签数据，并将其解析为 [RoleTagRes] 对象的列表。
  /// 如果 API 调用成功且返回的数据是有效的列表，则返回解析后的列表；否则返回 `null`。
  ///
  /// 返回：
  /// - 成功时返回 `List<RoleTagRes>`，包含解析后的角色标签数据。
  /// - 失败时返回 `null`（包括 API 调用失败、数据格式错误或异常情况）。
  ///
  /// 示例：
  /// ```dart
  /// final tags = await roleTagsList();
  /// if (tags != null) {
  ///   print('角色标签数量: ${tags.length}');
  /// }
  /// ```

  static Future<List<RoleTagRes>?> roleTagsList() async {
    try {
      var res = await api.get(ApiPath.roleTag, queryParameters: _qp);
      if (res.isOk) {
        if (res.body is List) {
          final list = (res.body as List).map((e) => RoleTagRes.fromJson(e)).toList();
          return list;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // 获取开屏随机角色
  static Future<Role?> splashRandomRole() async {
    try {
      var res = await api.get(ApiPath.splashRandomRole, queryParameters: _qp);
      if (res.isOk) {
        var result = BaseData.fromJson(res.body, (json) => Role.fromJson(json));
        return result.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<RolePage?> homeList({
    required int page,
    required int size,
    String? rendStyl,
    String? name,
    bool? videoChat,
    bool? genImg,
    bool? genVideo,
    bool? dress,
    List<int>? tags,
  }) async {
    try {
      var data = {'page': page, 'size': size, 'platform': AppService().platform};
      if (rendStyl != null) {
        data['render_style'] = rendStyl;
      }
      if (videoChat != null) {
        data['video_chat'] = videoChat;
      }
      if (genImg != null) {
        data['gen_img'] = genImg;
      }
      if (genVideo != null) {
        data['gen_video'] = genVideo;
      }
      if (dress != null) {
        data['change_clothing'] = dress;
      }
      if (name != null) {
        data['name'] = name;
      }
      if (tags != null && tags.isNotEmpty) {
        data['tags'] = tags;
      }
      var res = await api.post(ApiPath.roleList, body: data, queryParameters: _qp);
      if (res.isOk) {
        return RolePage.fromJson(res.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // static Future<MomentsRes?> momensListPage({required int page, required int size}) async {
  //   try {
  //     var res = await api.post(
  //       ApiPath.momentsList,
  //       body: {'page': page, 'size': size, 'hide_character': CacheUtil().isb ? true : false},
  //       queryParameters: _qp,
  //     );
  //     if (res.isOk) {
  //       return MomentsRes.fromJson(res.body);
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static Future<Role?> loadRoleById(String roleId) async {
    try {
      var qp = _qp;
      qp['id'] = roleId;
      var res = await api.get(ApiPath.getRoleById, queryParameters: qp);
      if (res.isOk) {
        var role = Role.fromJson(res.body);
        return role;
      } else {
        return null;
      }
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  /// api signature msg
  static Future<String?> getApiSignature() async {
    try {
      final uid = AppUser().user?.id;
      if (uid == null || uid.isEmpty) return null;
      const derEncodedPublicKey =
          'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCLWMEjJb703WZJ5Nqf7qJ2wefSSYvbmQZM0CgHGrYstUaj4Mlz+P06mCqpVAYmyf3dJxLrEsUiobWvhi1Ut5W+PY0yrzEsIOJ5lJrIt1pm0/kcPsPj2d4cEl9S7DTEIJVQTGMzquAlhEkgbA0yDVXNtqqf4MECCADU/WM3WTCH2QIDAQAB';
      const pemPublicKey =
          '-----BEGIN PUBLIC KEY-----\n$derEncodedPublicKey\n-----END PUBLIC KEY-----';
      final parser = RSAKeyParser();
      final RSAPublicKey publicKey = parser.parse(pemPublicKey) as RSAPublicKey;
      final encrypter = Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1));
      final encrypted = encrypter.encrypt(uid);
      return encrypted.base64;
    } catch (e) {
      log.e('ras catch: $e');
      return null;
    }
  }

  static Future<int> consumeReq(int value, String from) async {
    // 使用公钥加密消息
    final uid = AppUser().user?.id;
    if (uid == null || uid.isEmpty) return 0;
    final signature = await getApiSignature();

    var body = <String, dynamic>{
      'signature': signature,
      'id': uid,
      'gems': value,
      'description': from,
    };

    try {
      var res = await api.post(ApiPath.minusGems, body: body, queryParameters: _qp);
      if (res.isOk) {
        return res.body;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // // 加钻石
  // static Future<bool> addGems(int value, String from) async {
  //   // 使用公钥加密消息
  //   final uid = AccountUtil().user?.id;
  //   if (uid == null || uid.isEmpty) return false;
  //   final signature = await getApiSignature();

  //   var body = <String, dynamic>{
  //     'signature': signature,
  //     'id': uid,
  //     'gems': value,
  //     'description': from,
  //   };

  //   try {
  //     var res = await api.post(ApiPath.addGems, body: body);
  //     return res.isOk;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<GenRes?> genResult({
  //   required String id,
  //   required String mediaType,
  //   required String tag,
  // }) async {
  //   var queryParameters = <String, dynamic>{};
  //   queryParameters['media_type'] = mediaType.toUpperCase();
  //   queryParameters['tag'] = tag;
  //   queryParameters['id'] = id;

  //   try {
  //     var res = await api.get(ApiPath.genRandomOne, queryParameters: queryParameters);
  //     if (res.isOk) {
  //       var data = GenRes.fromJson(res.body);
  //       return data;
  //     } else {
  //       SmartDialog.showToast('Gen failed, please try again later');
  //       return null;
  //     }
  //   } catch (e) {
  //     SmartDialog.showToast('Gen failed, please try again later');
  //     return null;
  //   }
  // }

  // static Future<String?> undrChater(String id, String? style) async {
  //   try {
  //     var res = await api.post(
  //       ApiPath.undrCharacter,
  //       body: {'character_id': id, 'style': style},
  //       queryParameters: _qp,
  //     );
  //     if (res.isOk) {
  //       var result = BaseRes.fromJson(res.body, null);
  //       if (result.code == 20003) {
  //         SmartDialog.showToast('Gems are not enough, please recharge');
  //       }

  //       return result.data;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<String?> undrImage({
  //   required String sourceImage,
  //   required String fileName,
  //   required String mask,
  //   required String style,
  // }) async {
  //   try {
  //     final deviceId = await InfoUtil().deviceId();
  //     final version = await InfoUtil().version();
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       'device-id': deviceId,
  //       'platform': ConstUtil().platform,
  //       'version': version,
  //     };

  //     var dio = Dio(
  //       BaseOptions(
  //         baseUrl: ConstUtil().baseUrl,
  //         headers: headers,
  //         sendTimeout: const Duration(minutes: 1),
  //         receiveTimeout: const Duration(minutes: 3),
  //       ),
  //     );

  //     dio.interceptors.add(LogInterceptor(responseBody: true));

  //     var res = await dio.request(
  //       ApiPath.undrImageRes,
  //       data: {'source_image': sourceImage, 'file_name': fileName, 'mask': mask, 'style': style},
  //       options: Options(method: 'POST'),
  //       queryParameters: _qp,
  //     );
  //     if (res.statusCode == 200) {
  //       var result = BaseRes<String>.fromJson(res.data, null);
  //       if (result.code == 20003) {
  //         SmartDialog.showToast('Gems are not enough, please recharge');
  //       }
  //       return result.data;
  //     } else {
  //       log.e('undrImage: ${res.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     log.e('undrImage: ${e.toString()}');
  //     if (e is TimeoutException) {
  //       log.e('undrImage: Request timed out');
  //     } else {
  //       log.e('undrImage: ${e.toString()}');
  //     }
  //     return null;
  //   }
  // }

  // static Future<List<Datum>> getUndrStyles() async {
  //   try {
  //     final res = await api.post(ApiPath.undrStyles, queryParameters: _qp);
  //     if (res.isOk) {
  //       var r = UndrRes.fromJson(res.body);
  //       return r.data ?? [];
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     return [];
  //   }
  // }

  // static Future<OrderIosRes?> makeIosOrder({
  //   required String skuId,
  //   required String orderType,
  // }) async {
  //   try {
  //     final userId = AccountUtil().user?.id;
  //     if (userId == null || userId.isEmpty) return null;

  //     String deviceId = await InfoUtil().deviceId();

  //     var body = {
  //       'user_id': userId,
  //       'sku_id': skuId,
  //       'order_type': orderType,
  //       'device_id': deviceId,
  //     };

  //     var res = await api.post(ApiPath.createIosOrder, body: body);
  //     if (res.isOk) {
  //       final result = BaseRes.fromJson(res.body, (data) => OrderIosRes.fromJson(data));
  //       return result.data;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<bool> verifyIosOrder({
  //   required int orderId,
  //   required String? receipt,
  //   required String skuId,
  //   required String? transactionId,
  //   required String? purchaseDate,
  //   bool? dres,
  //   bool? createImg,
  //   bool? createVideo,
  // }) async {
  //   try {
  //     final userId = AccountUtil().user?.id;
  //     if (userId == null || userId.isEmpty) return false;

  //     var chooseEnv = ConstUtil().isDeving ? false : true;
  //     final idfa = await Adjust.getIdfa();
  //     final adid = await Adjust.getAdid();

  //     var params = <String, dynamic>{
  //       'order_id': orderId,
  //       'user_id': userId,
  //       'receipt': receipt,
  //       'choose_env': chooseEnv,
  //       'idfa': idfa,
  //       'adid': adid,
  //       'sku_id': skuId,
  //       'transaction_id': transactionId,
  //       'purchase_date': purchaseDate,
  //     };
  //     if (dres != null) {
  //       params['dres'] = dres;
  //     }
  //     if (createImg != null) {
  //       params['create_img'] = createImg;
  //     }
  //     if (createVideo != null) {
  //       params['create_video'] = createVideo;
  //     }

  //     var res = await api.post(ApiPath.verifyIosReceipt, body: params);
  //     if (res.isOk) {
  //       var data = BaseRes.fromJson(res.body, null);
  //       if (data.code == 0 || data.code == 200) {
  //         return true;
  //       }
  //       return false;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<OrderAndRes?> makeAndOrder({
  //   required String orderType,
  //   required String skuId,
  // }) async {
  //   try {
  //     final userId = AccountUtil().user?.id;
  //     if (userId == null || userId.isEmpty) return null;

  //     String deviceId = await InfoUtil().deviceId();

  //     var body = {
  //       'device_id': deviceId,
  //       'platform': ConstUtil().platform,
  //       'order_type': orderType,
  //       'sku_id': skuId,
  //       'user_id': userId,
  //     };

  //     var res = await api.post(ApiPath.createAndOrder, body: body);

  //     if (res.isOk) {
  //       var result = BaseRes.fromJson(res.body, (data) => OrderAndRes.fromJson(data));
  //       return result.data;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // // 安卓验签
  // static Future<bool> verifyAndOrder({
  //   required String originalJson,
  //   required String purchaseToken,
  //   required String orderType,
  //   required String skuId,
  //   required String orderId,
  //   bool? dres,
  //   bool? createImg,
  //   bool? createVideo,
  // }) async {
  //   try {
  //     final userId = AccountUtil().user?.id;
  //     if (userId == null || userId.isEmpty) return false;
  //     String androidId = await InfoUtil().deviceId(isOrigin: true);
  //     final adid = await Adjust.getAdid();
  //     final gpsAdid = await Adjust.getGoogleAdId();

  //     var body = <String, dynamic>{
  //       'original_json': originalJson,
  //       'purchase_token': purchaseToken,
  //       'order_type': orderType,
  //       'sku_id': skuId,
  //       'order_id': orderId,
  //       'android_id': androidId,
  //       'gps_adid': gpsAdid,
  //       'adid': adid,
  //       'user_id': userId,
  //     };
  //     if (dres != null) {
  //       body['dres'] = dres;
  //     }
  //     if (createImg != null) {
  //       body['create_img'] = createImg;
  //     }
  //     if (createVideo != null) {
  //       body['create_video'] = createVideo;
  //     }

  //     var res = await api.post(ApiPath.verifyAndOrder, body: body);

  //     if (res.isOk) {
  //       final data = BaseRes.fromJson(res.body, null);
  //       if (data.code == 0 || data.code == 200) {
  //         return true;
  //       }
  //       return false;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

  static Future<bool> collectRole(String roleId) async {
    try {
      var res = await api.post(ApiPath.collectRole, body: {'character_id': roleId});
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelCollectRole(String roleId) async {
    try {
      var res = await api.post(ApiPath.cancelCollectRole, body: {'character_id': roleId});
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  // static Future<SessionRes?> sessionList(int page, int size) async {
  //   try {
  //     var res = await api.post(
  //       ApiPath.sessionList,
  //       body: {'page': page, 'size': size},
  //       queryParameters: _qp,
  //     );
  //     if (res.isOk) {
  //       return SessionRes.fromJson(res.body);
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static Future<SessionData?> addSession(String charId) async {
    try {
      var res = await api.post(ApiPath.addSession, queryParameters: {'charId': charId});
      if (res.isOk) {
        return SessionData.fromJson(res.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // static Future<Session?> resetSession(int id) async {
  //   try {
  //     var res = await api.post(
  //       ApiPath.resetSession,
  //       queryParameters: {'conversationId': id.toString()},
  //     );
  //     if (res.isOk) {
  //       return Session.fromJson(res.body);
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<bool> deleteSession(int id) async {
  //   try {
  //     var res = await api.post(ApiPath.deleteSession, queryParameters: {'id': id.toString()});
  //     return res.isOk;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<RoleRes?> collectList(int page, int size) async {
  //   try {
  //     var res = await api.post(
  //       ApiPath.collectList,
  //       body: {'page': page, 'size': size},
  //       queryParameters: _qp,
  //     );
  //     if (res.isOk) {
  //       var data = RoleRes.fromJson(res.body);
  //       return data;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // // 消息列表
  // static Future<MsgRes?> messageList(int page, int size, int convId) async {
  //   try {
  //     var res = await api.post(
  //       ApiPath.messageList,
  //       body: {'page': page, 'size': size, 'conversation_id': convId},
  //       queryParameters: _qp,
  //     );
  //     if (res.isOk) {
  //       var data = MsgRes.fromJson(res.body);
  //       return data;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<MsgAnswer?> sendVoiceChatMsg({
  //   required String roleId,
  //   required String userId,
  //   required String nickName,
  //   required String message,
  //   String? msgId,
  // }) async {
  //   try {
  //     var res = await api.post(
  //       ApiPath.voiceChat,
  //       body: {
  //         'char_id': roleId,
  //         'user_id': userId,
  //         'nick_name': nickName,
  //         'message': message,
  //         if (msgId?.isNotEmpty == true) 'msg_id': msgId,
  //       },
  //       queryParameters: _qp,
  //     );
  //     if (res.isOk) {
  //       return MsgAnswer.fromJson(res.body);
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static Future<bool> updateEventParams({bool? autoTranslate}) async {
    try {
      String deviceId = await AppCache().phoneId();
      final adid = await Adjust.getAdid();

      Map<String, dynamic> data = {
        'adid': adid,
        'device_id': deviceId,
        'platform': AppService().platform,
      };

      if (Platform.isIOS) {
        String? idfa = await Adjust.getIdfa();
        data['idfa'] = idfa;
      } else if (Platform.isAndroid) {
        final gpsAdid = await Adjust.getGoogleAdId();
        data['gps_adid'] = gpsAdid;
      }

      if (autoTranslate != null) {
        data['auto_translate'] = autoTranslate;
      }
      data['source_language'] = 'en';
      data['target_language'] = Get.deviceLocale?.languageCode;

      var result = await api.post(ApiPath.eventParams, body: data);

      final res = BaseData.fromJson(result.body, null);
      if (res.code == 0 || res.code == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // static Future<List<ChatLevelConfig>?> getChatLevelConfig() async {
  //   try {
  //     var result = await api.get(ApiPath.chatLevelConfig);
  //     final list = result.body;
  //     if (list is List) {
  //       final datas = list.map((x) => ChatLevelConfig.fromJson(x)).toList();
  //       return datas;
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<bool> unlockImageReq(int imageId, String modelId) async {
  //   try {
  //     var result = await api.post(
  //       ApiPath.unlockImage,
  //       body: {'image_id': imageId, 'model_id': modelId},
  //     );

  //     return result.body;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<ChatAnserLevel?> fetchChatLevel({
  //   required String charId,
  //   required String userId,
  // }) async {
  //   try {
  //     var qb = _qp;
  //     qb['charId'] = charId;
  //     qb['userId'] = userId;

  //     var result = await api.post(ApiPath.chatLevel, queryParameters: qb);
  //     if (result.isOk) {
  //       var res = BaseRes.fromJson(result.body, (json) => ChatAnserLevel.fromJson(json));
  //       return res.data;
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<String?> translateText(String content, {String? slan = 'en', String? tlan}) async {
  //   try {
  //     var result = await api.post(
  //       ApiPath.translate,
  //       body: {
  //         'content': content,
  //         'source_language': slan,
  //         'target_language': tlan ?? Get.deviceLocale?.languageCode,
  //       },
  //     );
  //     final res = BaseRes.fromJson(result.body, null);
  //     return res.data;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future getDailyReward() async {
  //   try {
  //     var result = await api.post(ApiPath.signIn);
  //     final res = BaseRes.fromJson(result.body, null);
  //     if (res.code == 0 || res.code == 200) {
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<List<MsgToys>?> getToysConfigs() async {
  //   try {
  //     var result = await api.get(ApiPath.giftConfig);
  //     if (result.body is List) {
  //       final list = (result.body as List).map((e) => MsgToys.fromJson(e)).toList();
  //       return list;
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<List<MsgClothing>?> getClotheConfigs() async {
  //   try {
  //     var result = await api.get(ApiPath.changeConfig);
  //     if (result.body is List) {
  //       final list = (result.body as List).map((e) => MsgClothing.fromJson(e)).toList();
  //       return list;
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<Msg?> sendToys({
  //   required String roleId,
  //   required int id,
  //   required int convId,
  // }) async {
  //   try {
  //     var result = await api.post(
  //       ApiPath.sendToy,
  //       body: {'model_id': roleId, 'id': id, 'conversation_id': convId},
  //     );
  //     var res = BaseRes.fromJson(result.body, (json) => Msg.fromJson(json));
  //     return res.data;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<Msg?> sendClothes({
  //   required String roleId,
  //   required int id,
  //   required int convId,
  // }) async {
  //   try {
  //     var result = await api.post(
  //       ApiPath.sendClothes,
  //       body: {'model_id': roleId, 'id': id, 'conversation_id': convId},
  //     );
  //     var res = BaseRes.fromJson(result.body, (json) => Msg.fromJson(json));
  //     return res.data;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<bool> saveMsgTrans({required String id, required String text}) async {
  //   try {
  //     var result = await api.post(ApiPath.saveMsg, body: {'translate_answer': text, 'id': id});
  //     return result.isOk;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // /// 获取商品列表
  // static Future<List<Sku>?> getSku() async {
  //   try {
  //     var result = await api.get(ApiPath.skuList);
  //     BaseRes res = BaseRes.fromJson(result.body, null);
  //     if (res.data != null) {
  //       List<Sku> skus = [];
  //       for (var item in res.data) {
  //         skus.add(Sku.fromJson(item));
  //       }
  //       return skus;
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // /// 编辑消息
  // static Future<Msg?> editMsg({required String id, required String text}) async {
  //   try {
  //     var result = await api.post(ApiPath.editMsg, body: {'id': id, 'answer': text});
  //     var res = BaseRes.fromJson(result.body, (json) => Msg.fromJson(json));
  //     return res.data;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // /// 修改聊天场景
  // static Future<bool> editScene({
  //   required int convId,
  //   required String scene,
  //   required String roleId,
  // }) async {
  //   try {
  //     var result = await api.post(
  //       ApiPath.editScene,
  //       body: {'conversation_id': convId, 'character_id': roleId, 'scene': scene},
  //     );
  //     BaseRes res = BaseRes.fromJson(result.body, null);
  //     return res.data == null ? false : true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // /// 修改会话模式
  // static Future<bool> editChatMode({required int convId, required String mode}) async {
  //   try {
  //     var result = await api.post(ApiPath.editMode, body: {'id': convId, 'chat_model': mode});
  //     BaseRes res = BaseRes.fromJson(result.body, null);
  //     return res.data;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // /// 新建 mask
  // static Future<bool> createOrUpdateMask({
  //   required String name,
  //   required String age,
  //   required int gender,
  //   required String? description,
  //   required String? otherInfo,
  //   required int? id,
  // }) async {
  //   try {
  //     final userId = AccountUtil().user?.id;
  //     final isEdit = id != null;
  //     final path = isEdit ? ApiPath.editMask : ApiPath.createMask;
  //     final body = <String, dynamic>{
  //       'profile_name': name,
  //       'age': age,
  //       'gender': gender,
  //       'description': description,
  //       'other_info': otherInfo,
  //       'user_id': userId,
  //     };
  //     if (isEdit) {
  //       body['id'] = id;
  //     }

  //     var result = await api.post(path, body: body);
  //     BaseRes res = BaseRes.fromJson(result.body, null);
  //     return isEdit ? res.data : res.data != null;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // /// 获取 mask 列表 分页
  // static Future<ChatMaskListRes?> getMaskList({int page = 1, int size = 10}) async {
  //   try {
  //     var result = await api.post(
  //       ApiPath.getMaskList,
  //       body: {'page': page, 'size': size, 'user_id': AccountUtil().user?.id},
  //     );
  //     var res = ChatMaskListRes.fromJson(result.body);
  //     return res;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // /// 切换 mask
  // static Future<bool> changeMask({required int? conversationId, required int? maskId}) async {
  //   try {
  //     var result = await api.post(
  //       ApiPath.changeMask,
  //       body: {'conversation_id': conversationId, 'profile_id': maskId},
  //     );
  //     BaseRes res = BaseRes.fromJson(result.body, null);
  //     return res.data;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // /// 获取各种价格配置
  // static Future<PriceConfig?> getPriceConfig() async {
  //   try {
  //     var result = await api.get(ApiPath.getPriceConfig);
  //     var res = PriceConfig.fromJson(result.body);
  //     return res;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // /// 删除 mask
  // /// [id] mask id
  // static Future<bool> deleteMask({required int id}) async {
  //   try {
  //     var result = await api.post(ApiPath.deleteMask, body: {'id': id});
  //     BaseRes res = BaseRes.fromJson(result.body, null);
  //     return res.data ?? false;
  //   } catch (e) {
  //     return false;
  //   }
  // }
}
