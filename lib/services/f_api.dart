import 'dart:async';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/data/a_pop_tags.dart';
import 'package:fast_ai/data/a_pop_toy_data.dart';
import 'package:fast_ai/data/accouont.dart';
import 'package:fast_ai/data/ans_level.dart';
import 'package:fast_ai/data/base_data.dart';
import 'package:fast_ai/data/gems_config.dart';
import 'package:fast_ai/data/level_base.dart';
import 'package:fast_ai/data/mask_data.dart';
import 'package:fast_ai/data/msg_ans_data.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/data/p_d_data.dart';
import 'package:fast_ai/data/pay_order.dart';
import 'package:fast_ai/data/r_clo_data.dart';
import 'package:fast_ai/data/session_data.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_http.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/services/ur_path.dart';
import 'package:get/get.dart';
import 'package:pointycastle/asymmetric/api.dart';

final api = FHttp();

class FApi {
  FApi._();

  static Map<String, dynamic> get _qp => FCache().isBig ? {'v': 'C001'} : {};

  static Future<Accouont?> register() async {
    try {
      final deviceId = await FCache().phoneId();
      var res = await api.post(
        UrPath.register,
        body: {"device_id": deviceId, "platform": FService().platform},
      );
      if (!res.isOk) {
        return null;
      }
      final user = Accouont.fromJson(res.body);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<Accouont?> getUserInfo() async {
    try {
      final deviceId = await FCache().phoneId();
      final res = await api
          .get(UrPath.getUserInfo, queryParameters: {'device_id': deviceId});
      if (!res.isOk) {
        return null;
      }
      final user = Accouont.fromJson(res.body);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUserInfo(Map<String, dynamic> body) async {
    try {
      final res = await api.post(UrPath.updateUserInfo, body: body);
      final reult = BaseData.fromJson(res.body, null);
      return reult.data;
    } catch (e) {
      return false;
    }
  }

  static Future<List<APopTagRes>?> roleTagsList() async {
    try {
      var res = await api.get(UrPath.roleTag, queryParameters: _qp);
      if (res.isOk) {
        if (res.body is List) {
          final list =
              (res.body as List).map((e) => APopTagRes.fromJson(e)).toList();
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
  static Future<APop?> splashRandomRole() async {
    try {
      var res = await api.get(UrPath.splashRandomRole, queryParameters: _qp);
      if (res.isOk) {
        var result = BaseData.fromJson(res.body, (json) => APop.fromJson(json));
        return result.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<APopRes?> homeList({
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
      var data = {'page': page, 'size': size, 'platform': FService().platform};
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
      var res =
          await api.post(UrPath.roleList, body: data, queryParameters: _qp);
      if (res.isOk) {
        final rolePage = APopRes.fromJson(res.body);
        return rolePage;
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

  static Future<APop?> loadRoleById(String roleId) async {
    try {
      var qp = _qp;
      qp['id'] = roleId;
      var res = await api.get(UrPath.getRoleById, queryParameters: qp);
      if (res.isOk) {
        var role = APop.fromJson(res.body);
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
      final uid = MY().user?.id;
      if (uid == null || uid.isEmpty) return null;
      const derEncodedPublicKey =
          'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCLWMEjJb703WZJ5Nqf7qJ2wefSSYvbmQZM0CgHGrYstUaj4Mlz+P06mCqpVAYmyf3dJxLrEsUiobWvhi1Ut5W+PY0yrzEsIOJ5lJrIt1pm0/kcPsPj2d4cEl9S7DTEIJVQTGMzquAlhEkgbA0yDVXNtqqf4MECCADU/WM3WTCH2QIDAQAB';
      const pemPublicKey =
          '-----BEGIN PUBLIC KEY-----\n$derEncodedPublicKey\n-----END PUBLIC KEY-----';
      final parser = RSAKeyParser();
      final RSAPublicKey publicKey = parser.parse(pemPublicKey) as RSAPublicKey;
      final encrypter =
          Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1));
      final encrypted = encrypter.encrypt(uid);
      return encrypted.base64;
    } catch (e) {
      log.e('ras catch: $e');
      return null;
    }
  }

  static Future<int> consumeReq(int value, String from) async {
    // 使用公钥加密消息
    final uid = MY().user?.id;
    if (uid == null || uid.isEmpty) return 0;
    final signature = await getApiSignature();

    var body = <String, dynamic>{
      'signature': signature,
      'id': uid,
      'gems': value,
      'description': from,
    };

    try {
      var res =
          await api.post(UrPath.minusGems, body: body, queryParameters: _qp);
      if (res.isOk) {
        return res.body;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

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

  static Future<PayOrder?> makeIosOrder(
      {required String skuId, required String orderType}) async {
    try {
      final userId = MY().user?.id;
      if (userId == null || userId.isEmpty) return null;

      String deviceId = await FCache().phoneId();

      var body = {
        'user_id': userId,
        'sku_id': skuId,
        'order_type': orderType,
        'device_id': deviceId,
      };

      var res = await api.post(UrPath.createIosOrder, body: body);
      if (res.isOk) {
        final result =
            BaseData.fromJson(res.body, (data) => PayOrder.fromJson(data));
        return result.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> verifyIosOrder({
    required int orderId,
    required String? receipt,
    required String skuId,
    required String? transactionId,
    required String? purchaseDate,
    bool? dres,
    bool? createImg,
    bool? createVideo,
  }) async {
    log.d('verifyIosOrder----------start----------');
    try {
      log.d('verifyIosOrder: 检查用户ID...');
      final userId = MY().user?.id;
      if (userId == null || userId.isEmpty) {
        log.w('verifyIosOrder: 用户ID为空');
        return false;
      }
      var chooseEnv = FService().isDebugMode ? false : true;

      final idfa = await FService().getIdfa();
      final adid = await FService().getAdid();

      var params = <String, dynamic>{
        'order_id': orderId,
        'user_id': userId,
        'receipt': receipt,
        'choose_env': chooseEnv,
        'idfa': idfa,
        'adid': adid,
        'sku_id': skuId,
        'transaction_id': transactionId,
        'purchase_date': purchaseDate,
      };
      if (dres != null) {
        params['dres'] = dres;
      }
      if (createImg != null) {
        params['create_img'] = createImg;
      }
      if (createVideo != null) {
        params['create_video'] = createVideo;
      }
      var res = await api.post(UrPath.verifyIosReceipt, body: params);

      if (res.isOk) {
        var data = BaseData.fromJson(res.body, null);
        if (data.code == 0 || data.code == 200) {
          log.d('verifyIosOrder: 验证成功 ✅');
          return true;
        }
        log.w('verifyIosOrder: 验证失败 - code: ${data.code}');
        return false;
      } else {
        log.e('verifyIosOrder: 网络请求失败 - 状态码: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      log.e('verifyIosOrder: 异常 - $e');
      return false;
    }
  }

  static Future<PayOrder?> makeAndOrder(
      {required String orderType, required String skuId}) async {
    try {
      final userId = MY().user?.id;
      if (userId == null || userId.isEmpty) return null;

      String deviceId = await FCache().phoneId();

      var body = {
        'device_id': deviceId,
        'platform': FService().platform,
        'order_type': orderType,
        'sku_id': skuId,
        'user_id': userId,
      };

      var res = await api.post(UrPath.createAndOrder, body: body);

      if (res.isOk) {
        var result =
            BaseData.fromJson(res.body, (data) => PayOrder.fromJson(data));
        return result.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // 安卓验签
  static Future<bool> verifyAndOrder({
    required String originalJson,
    required String purchaseToken,
    required String orderType,
    required String skuId,
    required String orderId,
    bool? dres,
    bool? createImg,
    bool? createVideo,
  }) async {
    log.d('verifyAndOrder----------start----------');
    try {
      log.d('verifyAndOrder: 检查用户ID...');
      final userId = MY().user?.id;
      if (userId == null || userId.isEmpty) {
        log.w('verifyAndOrder: 用户ID为空');
        return false;
      }
      String androidId = await FCache().phoneId(isOrigin: true);
      final adid = await FService().getAdid();
      final gpsAdid = await FService().getGoogleAdId();
      var body = <String, dynamic>{
        'original_json': originalJson,
        'purchase_token': purchaseToken,
        'order_type': orderType,
        'sku_id': skuId,
        'order_id': orderId,
        'android_id': androidId,
        'gps_adid': gpsAdid,
        'adid': adid,
        'user_id': userId,
      };
      if (dres != null) {
        body['dres'] = dres;
      }
      if (createImg != null) {
        body['create_img'] = createImg;
      }
      if (createVideo != null) {
        body['create_video'] = createVideo;
      }
      log.d('verifyAndOrder: 请求参数构建完成 - ${body.keys.join(", ")}');
      var res = await api.post(UrPath.verifyAndOrder, body: body);
      if (res.isOk) {
        final data = BaseData.fromJson(res.body, null);
        if (data.code == 0 || data.code == 200) {
          log.d('verifyAndOrder: 验证成功 ✅');
          return true;
        }
        log.w('verifyAndOrder: 验证失败 - code: ${data.code}');
        return false;
      } else {
        log.e('verifyAndOrder: 网络请求失败 - 状态码: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      log.e('verifyAndOrder: 异常 - $e');
      return false;
    }
  }

  static Future<bool> collectRole(String roleId) async {
    try {
      var res =
          await api.post(UrPath.collectRole, body: {'character_id': roleId});
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelCollectRole(String roleId) async {
    try {
      var res = await api
          .post(UrPath.cancelCollectRole, body: {'character_id': roleId});
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future<SessionDataRes?> sessionList(int page, int size) async {
    try {
      var res = await api.post(
        UrPath.sessionList,
        body: {'page': page, 'size': size},
        queryParameters: _qp,
      );
      if (res.isOk) {
        final data = SessionDataRes.fromJson(res.body);
        return data;
      }
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  static Future<SessionData?> addSession(String charId) async {
    try {
      var res = await api
          .post(UrPath.addSession, queryParameters: {'charId': charId});
      if (res.isOk) {
        return SessionData.fromJson(res.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<SessionData?> resetSession(int id) async {
    try {
      var res = await api.post(
        UrPath.resetSession,
        queryParameters: {'conversationId': id.toString()},
      );
      if (res.isOk) {
        return SessionData.fromJson(res.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteSession(int id) async {
    try {
      var res = await api
          .post(UrPath.deleteSession, queryParameters: {'id': id.toString()});
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future<APopRes?> likedList(int page, int size) async {
    try {
      var res = await api.post(
        UrPath.collectList,
        body: {'page': page, 'size': size},
        queryParameters: _qp,
      );
      if (res.isOk) {
        var data = APopRes.fromJson(res.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // 消息列表
  static Future<MsgRes?> messageList(int page, int size, int convId) async {
    try {
      var res = await api.post(
        UrPath.messageList,
        body: {'page': page, 'size': size, 'conversation_id': convId},
        queryParameters: _qp,
      );
      if (res.isOk) {
        var data = MsgRes.fromJson(res.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<MsgAnsData?> sendVoiceChatMsg({
    required String roleId,
    required String userId,
    required String nickName,
    required String message,
    String? msgId,
  }) async {
    try {
      var res = await api.post(
        UrPath.voiceChat,
        body: {
          'char_id': roleId,
          'user_id': userId,
          'nick_name': nickName,
          'message': message,
          if (msgId?.isNotEmpty == true) 'msg_id': msgId,
        },
        queryParameters: _qp,
      );
      if (res.isOk && res.body != null) {
        return MsgAnsData.fromJson(res.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateEventParams({bool? autoTranslate}) async {
    try {
      String deviceId = await FCache().phoneId();
      final adid = await FService().getAdid();
      Map<String, dynamic> data = {
        'adid': adid,
        'device_id': deviceId,
        'platform': FService().platform,
      };

      if (Platform.isIOS) {
        String idfa = await FService().getIdfa();
        data['idfa'] = idfa;
      } else if (Platform.isAndroid) {
        final gpsAdid = await FService().getGoogleAdId();
        data['gps_adid'] = gpsAdid;
      }

      if (autoTranslate != null) {
        data['auto_translate'] = autoTranslate;
      }
      data['source_language'] = 'en';
      data['target_language'] = Get.deviceLocale?.languageCode;

      var result = await api.post(UrPath.eventParams, body: data);

      final res = BaseData.fromJson(result.body, null);
      if (res.code == 0 || res.code == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<LevelBase>?> getChatLevelConfig() async {
    try {
      var result = await api.get(UrPath.chatLevelConfig);
      final list = result.body;
      if (list is List) {
        final datas = list.map((x) => LevelBase.fromJson(x)).toList();
        return datas;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> unlockImageReq(int imageId, String modelId) async {
    try {
      var result = await api.post(
        UrPath.unlockImage,
        body: {'image_id': imageId, 'model_id': modelId},
      );

      // 检查返回值类型
      if (result.body is bool) {
        // 如果直接返回布尔值，直接返回
        return result.body;
      }

      // 如果是字符串，尝试解析
      if (result.body is String) {
        final bodyStr = result.body as String;
        // 检查是否是 "true" 或 "false" 字符串
        if (bodyStr.toLowerCase() == 'true') {
          return true;
        } else if (bodyStr.toLowerCase() == 'false') {
          return false;
        }

        // 尝试解析为 JSON
        try {
          final res = BaseData.fromJson(result.body, null);
          if (res.code == 0 || res.code == 200) {
            return true;
          }
          return false; // 返回 false 而不是原始错误信息
        } catch (e) {
          // JSON 解析失败，返回 false
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<AnsLevel?> fetchChatLevel({
    required String charId,
    required String userId,
  }) async {
    try {
      var qb = _qp;
      qb['charId'] = charId;
      qb['userId'] = userId;

      var result = await api.post(UrPath.chatLevel, queryParameters: qb);
      if (result.isOk) {
        var res =
            BaseData.fromJson(result.body, (json) => AnsLevel.fromJson(json));
        return res.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> translateText(String content,
      {String? slan = 'en', String? tlan}) async {
    try {
      var result = await api.post(
        UrPath.translate,
        body: {
          'content': content,
          'source_language': slan,
          'target_language': tlan ?? Get.deviceLocale?.languageCode,
        },
      );
      final res = BaseData.fromJson(result.body, null);
      return res.data;
    } catch (e) {
      return null;
    }
  }

  static Future getDailyReward() async {
    try {
      var result = await api.post(UrPath.signIn);
      final res = BaseData.fromJson(result.body, null);
      if (res.code == 0 || res.code == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<APopToyData>?> getToysConfigs() async {
    try {
      var result = await api.get(UrPath.giftConfig);
      if (result.body is List) {
        final list =
            (result.body as List).map((e) => APopToyData.fromJson(e)).toList();
        return list;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<RCloData>?> getClotheConfigs() async {
    try {
      var result = await api.get(UrPath.changeConfig);
      if (result.body is List) {
        final list =
            (result.body as List).map((e) => RCloData.fromJson(e)).toList();
        return list;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<MsgData?> sendToys({
    required String roleId,
    required int id,
    required int convId,
  }) async {
    try {
      var result = await api.post(
        UrPath.sendToy,
        body: {'model_id': roleId, 'id': id, 'conversation_id': convId},
      );
      var res =
          BaseData.fromJson(result.body, (json) => MsgData.fromJson(json));
      return res.data;
    } catch (e) {
      return null;
    }
  }

  static Future<MsgData?> sendClothes({
    required String roleId,
    required int id,
    required int convId,
  }) async {
    try {
      var result = await api.post(
        UrPath.sendClothes,
        body: {'model_id': roleId, 'id': id, 'conversation_id': convId},
      );
      var res =
          BaseData.fromJson(result.body, (json) => MsgData.fromJson(json));
      return res.data;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveMsgTrans(
      {required String id, required String text}) async {
    try {
      var result = await api
          .post(UrPath.saveMsg, body: {'translate_answer': text, 'id': id});
      return result.isOk;
    } catch (e) {
      return false;
    }
  }

  /// 获取商品列表
  static Future<List<PDData>?> getSkuList() async {
    try {
      var result = await api.get(UrPath.skuList);
      var res = BaseData.fromJson(result.body, null);
      if (res.data != null) {
        List<PDData> skus = [];
        for (var item in res.data) {
          skus.add(PDData.fromJson(item));
        }
        return skus;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // /// 编辑消息
  static Future<MsgData?> editMsg(
      {required String id, required String text}) async {
    try {
      var result =
          await api.post(UrPath.editMsg, body: {'id': id, 'answer': text});
      var res =
          BaseData.fromJson(result.body, (json) => MsgData.fromJson(json));
      return res.data;
    } catch (e) {
      return null;
    }
  }

  /// 修改聊天场景
  static Future<bool> editScene({
    required int convId,
    required String scene,
    required String roleId,
  }) async {
    try {
      var result = await api.post(
        UrPath.editScene,
        body: {
          'conversation_id': convId,
          'character_id': roleId,
          'scene': scene
        },
      );
      var res = BaseData.fromJson(result.body, null);
      return res.data == null ? false : true;
    } catch (e) {
      return false;
    }
  }

  /// 修改会话模式
  static Future<bool> editChatMode(
      {required int convId, required String mode}) async {
    try {
      var result = await api
          .post(UrPath.editMode, body: {'id': convId, 'chat_model': mode});
      var res = BaseData.fromJson(result.body, null);
      return res.data;
    } catch (e) {
      return false;
    }
  }

  /// 新建 mask
  static Future<bool> createOrUpdateMask({
    required String name,
    required String age,
    required int gender,
    required String? description,
    required String? otherInfo,
    required int? id,
  }) async {
    try {
      final userId = MY().user?.id;
      final isEdit = id != null;
      final path = isEdit ? UrPath.editMask : UrPath.createMask;
      final body = <String, dynamic>{
        'profile_name': name,
        'age': age,
        'gender': gender,
        'description': description,
        'other_info': otherInfo,
        'user_id': userId,
      };
      if (isEdit) {
        body['id'] = id;
      }

      var result = await api.post(path, body: body);
      var res = BaseData.fromJson(result.body, null);
      return isEdit ? res.data : res.data != null;
    } catch (e) {
      return false;
    }
  }

  /// 获取 mask 列表 分页
  static Future<MaskListRes?> getMaskList({int page = 1, int size = 10}) async {
    try {
      var result = await api.post(
        UrPath.getMaskList,
        body: {'page': page, 'size': size, 'user_id': MY().user?.id},
      );
      var res = MaskListRes.fromJson(result.body);
      return res;
    } catch (e) {
      return null;
    }
  }

  /// 切换 mask
  static Future<bool> changeMask(
      {required int? conversationId, required int? maskId}) async {
    try {
      var result = await api.post(
        UrPath.changeMask,
        body: {'conversation_id': conversationId, 'profile_id': maskId},
      );
      var res = BaseData.fromJson(result.body, null);
      return res.data;
    } catch (e) {
      return false;
    }
  }

  /// 获取各种价格配置
  static Future<GemsConfig?> getPriceConfig() async {
    try {
      var result = await api.get(UrPath.getPriceConfig);
      var res = GemsConfig.fromJson(result.body);
      return res;
    } catch (e) {
      return null;
    }
  }

  /// 删除 mask
  static Future<bool> deleteMask({required int id}) async {
    try {
      var result = await api.post(UrPath.deleteMask, body: {'id': id});
      var res = BaseData.fromJson(result.body, null);
      return res.data ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 发送消息
  static Future<BaseData<MsgData>?> sendMsg({
    required String path,
    Map<String, Object>? body,
  }) async {
    try {
      var result = await api.post(path, body: body);
      var res = BaseData.fromJson(result.body, (x) => MsgData.fromJson(x));
      return res;
    } catch (e) {
      return null;
    }
  }
}
