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
    "recharge_status": "adepfr",
    "render_style": "ancpkk",
    "user_id": "azwgqp",
    "password": "bpccnm",
    "character_id": "bwpesr",
    "engine": "cioomj",
    "message": "cnainu",
    "currency_code": "dryxgv",
    "cname": "ecdkty",
    "about_me": "edjrsn",
    "avatar": "efryam",
    "signature": "eidhqn",
    "translate_answer": "enmubt",
    "character_video_chat": "ettypz",
    "chat": "fcrvsv",
    "platform": "fdxtuh",
    "voice_duration": "fflilq",
    "lock_level": "flaidq",
    "vip": "fqlpsq",
    "gender": "fvziqv",
    "token": "fzftjg",
    "ctype": "gaynjl",
    "tags": "gonnkr",
    "url": "gvswxd",
    "likes": "gyzbsg",
    "receipt": "hhhron",
    "deserved_gems": "hicbtv",
    "shelving": "hldwav",
    "character_name": "hnvycs",
    "device_id": "hwalsg",
    "lock_level_media": "idbasf",
    "planned_msg_id": "ilyoav",
    "change_clothing": "inqtop",
    "image_path": "iuxhak",
    "gname": "ivkngs",
    "translate_question": "jgayoa",
    "fileMd5": "jpzbtp",
    "answer": "jrfecj",
    "subscription": "jyijef",
    "idfa": "kbgigm",
    "order_type": "khzgdj",
    "adid": "masvbs",
    "currency_symbol": "mcrtot",
    "result_path": "mwxxsc",
    "source": "mxklzw",
    "product_id": "ngyzbr",
    "uid": "njodtb",
    "duration": "nrimhf",
    "conv_id": "oabdcr",
    "estimated_time": "occpps",
    "chat_image_price": "ocikxj",
    "gen_video": "okjzpb",
    "media": "oscqfo",
    "amount": "owbwrh",
    "conversation_id": "ozrkqm",
    "model_id": "pdlurn",
    "choose_env": "pkdtcf",
    "hide_character": "pvegrx",
    "report_type": "qdvjal",
    "create_time": "qgskua",
    "gen_photo_tags": "qhupps",
    "time_need": "rqerhm",
    "transaction_id": "rulpub",
    "chat_audio_price": "sckhox",
    "chat_video_price": "sehymk",
    "style": "sfxdql",
    "voice_url": "sjoxiu",
    "taskId": "sycksj",
    "gems": "tmhhwa",
    "greetings": "tnnjfp",
    "session_count": "tptktw",
    "characterId": "umydxb",
    "thumbnail_url": "ursiea",
    "price": "usqljw",
    "msg_id": "uwxfyh",
    "gen_photo": "vitvrg",
    "voice_id": "vjmmdn",
    "nick_name": "vkwpip",
    "greetings_voice": "vxzlrn",
    "next_msgs": "vzbwow",
    "order_num": "vzlmnz",
    "original_transaction_id": "wqmhef",
    "video_chat": "wuouyu",
    "question": "xrdlko",
    "update_time": "xtgcdv",
    "gtype": "yfgoby",
    "age": "yggzsv",
    "template_id": "zmwvjo",
    "chat_model": "zogojt",
    "name": "zxxfat",
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

      // 使用正则替换内容
      final RegExp regex = RegExp(r'"([^"]*)"');
      final String replacedContent = regex.allMatches(fileContent).fold(fileContent, (
        String content,
        Match match,
      ) {
        final String key = match.group(1)!;
        if (replacementMap.containsKey(key)) {
          return content.replaceFirst(match[0]!, '"${replacementMap[key]}"');
        }
        return content;
      });

      entity.writeAsStringSync(replacedContent);
      print('文件已成功替换: ${entity.path}');
    }
  }
}
