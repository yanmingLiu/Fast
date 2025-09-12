import 'dart:io';

// 在终端中直接运行 main 方法：
/*
dart run /Users/hookup/Documents/kira_ai/test/json_key_replay.dart
*/
/// 入口方法
void main() {
  // 指定文件夹路径（你的开发机上的绝对路径）
  const String folderPath = '/Users/ai3/Documents/fast_ai/lib/data';

  // 调用替换方法
  replace(folderPath);
}

void replace(String folderPath) {
  // 替换规则
  final Map<String, String> replacementMap = {
    "acfzch": "session_count",
    "acpfyg": "render_style",
    "agnjqb": "report_type",
    "aooyac": "sign",
    "axnfwo": "product_id",
    "blwpav": "password",
    "bqqynl": "gen_video",
    "braouc": "enable_auto_translate",
    "bswwcu": "create_img",
    "caggef": "gems",
    "crgsgg": "chat_image_price",
    "csdcwj": "order_num",
    "cxchkf": "name",
    "dclesw": "upgrade",
    "digxuw": "gname",
    "djsqps": "chat_video_price",
    "dvfbov": "age",
    "dvonxk": "gtype",
    "emdduy": "nick_name",
    "eoormy": "chat_model",
    "euhrhf": "taskId",
    "fcottq": "choose_env",
    "fnivfn": "conv_id",
    "foaqje": "voice_duration",
    "gejhdy": "thumbnail_url",
    "gmzplw": "voice_id",
    "gnctmz": "translate_question",
    "hsxufq": "ctype",
    "ieyxlg": "subscription",
    "ilubju": "avatar",
    "imftoj": "cname",
    "iptgpo": "platform",
    "ivkasx": "media",
    "jcxxvw": "chat_audio_price",
    "jdpgll": "template_id",
    "jrtqer": "character_id",
    "kbwvep": "gender",
    "keryof": "gen_photo_tags",
    "kjckes": "update_time",
    "kkwgbf": "next_msgs",
    "koybww": "price",
    "kphtct": "greetings_voice",
    "kvrjki": "target_language",
    "kzedme": "tags",
    "kzssvb": "unlock_card_num",
    "lhfenv": "original_transaction_id",
    "lorggn": "transaction_id",
    "loylzj": "model_id",
    "lrtpjy": "time_need",
    "maamrl": "vip",
    "mqfkju": "url",
    "mvusjp": "source",
    "nezklq": "character_video_chat",
    "npdrdn": "scene",
    "nsbvib": "video_chat",
    "nxwock": "likes",
    "ogvzft": "character_name",
    "ohjkii": "visual",
    "ojsbmv": "estimated_time",
    "omfmzh": "fileMd5",
    "ophbla": "answer",
    "pbvbko": "greetings",
    "pizmoo": "currency_symbol",
    "przkjk": "about_me",
    "pttgjv": "user_id",
    "puevny": "device_id",
    "pybwdk": "email",
    "qbyseq": "gen_photo",
    "qekjgk": "image_path",
    "qrandh": "change_clothing",
    "qxqmil": "video_unlock",
    "rbiyym": "profile_id",
    "rditgz": "result_path",
    "rqelpt": "idfa",
    "rziltp": "style",
    "sayucj": "lock_level_media",
    "schwrn": "recharge_status",
    "srsrtx": "deserved_gems",
    "stykbx": "planned_msg_id",
    "tahwnw": "subscription_end",
    "toaqrn": "receipt",
    "twschm": "nickname",
    "txiwuk": "engine",
    "ugcicg": "characterId",
    "uuovie": "undress_count",
    "uvpftb": "create_time",
    "vakqle": "chat",
    "vhzwuw": "free_message",
    "vkvqck": "activate",
    "vmmqud": "translate_answer",
    "vnvqou": "question",
    "vwchxr": "signature",
    "wddsho": "card_num",
    "wfvibl": "create_video",
    "wjhrab": "last_message",
    "woulqf": "currency_code",
    "wouomy": "rewards",
    "wtaibz": "voice_url",
    "wtfivi": "source_language",
    "wtkibu": "amount",
    "wuwgwa": "token",
    "xerwgj": "hide_character",
    "xxhseg": "cid",
    "xyyrws": "duration",
    "xzhyab": "uid",
    "ybvhjk": "conversation_id",
    "ydnjjt": "order_type",
    "yiasvv": "app_user_chat_level",
    "yrzytz": "auto_translate",
    "ysjpqk": "shelving",
    "ytwtbr": "lock_level",
    "yzujoc": "msg_id",
    "yzxxkn": "adid",
    "zbzpjx": "message",
    "zlirye": "free_overrun",
    "zvijmg": "pay",
  };

  // 获取文件夹
  final Directory directory = Directory(folderPath);
  if (!directory.existsSync()) {
    print('文件夹不存在: $folderPath');
    return;
  }
  final List<FileSystemEntity> files = directory.listSync();

  for (final FileSystemEntity entity in files) {
    if (entity is File) {
      String fileContent = entity.readAsStringSync();

      // 使用简单的字符串替换来避免正则表达式格式化问题
      String replacedContent = fileContent;

      // 遍历所有需要替换的值
      for (final entry in replacementMap.entries) {
        final String oldKey = entry.key;
        final String newValue = entry.value;

        // 替换 JSON 对象中的键名: "key": value
        replacedContent = replacedContent.replaceAll('"$newValue":', '"$oldKey":');

        // 替换 JSON 访问: json['key'] 和 json["key"]
        replacedContent = replacedContent.replaceAll("json['$newValue']", "json['$oldKey']");
        replacedContent = replacedContent.replaceAll('json["$newValue"]', 'json["$oldKey"]');

        // 替换 Map 字面量中的键名: 'key': value 和 "key": value
        replacedContent = replacedContent.replaceAll("'$newValue':", "'$oldKey':");
        replacedContent = replacedContent.replaceAll('"$newValue":', '"$oldKey":');
      }

      entity.writeAsStringSync(replacedContent);
      print('文件已成功替换: ${entity.path}');
    }
  }
}
