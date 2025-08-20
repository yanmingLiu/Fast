import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

String numberPart(String skuId) {
  return skuId.replaceAll(RegExp(r'[^0-9]'), '');
}

String unitPart(String skuId) {
  return skuId.replaceAll(RegExp(r'[0-9]'), ''); // 保留非数字部分
}

String numFixed(dynamic nums, {int position = 2}) {
  double num = nums is double ? nums : double.parse(nums.toString());
  String numString = num.toStringAsFixed(position);

  return numString.endsWith('.0') ? numString.substring(0, numString.lastIndexOf('.')) : numString;
}

String formatVideoDuration(int seconds) {
  // 计算小时、分钟、秒
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  // 格式化成视频时长格式
  if (hours > 0) {
    // 如果时长包含小时，则显示 HH:mm:ss
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  } else {
    // 如果时长不足一小时，则显示 mm:ss
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

String formatTime(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int secs = seconds % 60;

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}s';
  } else if (minutes > 0) {
    return '$minutes:${secs.toString().padLeft(2, '0')}s';
  } else {
    return '${secs}s';
  }
}

String formatTimestamp(int timestampInMilliseconds) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0'); // 保证两位数格式
  String day = dateTime.day.toString().padLeft(2, '0'); // 保证两位数格式
  return '$year-$month-$day';
}

var _random = Random();

extension ListKx<T> on List<T>? {
  T? get randomOrNull {
    if (this == null || this!.isEmpty) {
      return null;
    } else {
      return this![_random.nextInt(this!.length)];
    }
  }

  bool get isNullOrEmpty => this == null || this!.isEmpty;

  String? get toJsonString {
    if (this == null || this!.isEmpty) {
      return null;
    } else {
      try {
        return jsonEncode(this);
      } catch (e) {
        e.toString();
      }
      return null;
    }
  }
}

Future<File?> processImage(File file) async {
  // 压缩并转换为 JPG 格式
  final compressedFile = await compressAndConvertToJpg(file);
  return compressedFile;
}

Future<File?> compressAndConvertToJpg(
  File file, {
  int initialQuality = 85,
  int minSize = 2 * 1024 * 1024,
}) async {
  try {
    int fileSize = await file.length();
    if (fileSize <= minSize && file.path.split('.').last.toLowerCase() == 'jpg') {
      return file;
    }

    int quality = initialQuality;
    File? compressedFile;

    do {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      // 创建新的文件路径
      final targetPath = join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath, // 将压缩后的图片保存到不同路径
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressedXFile != null) {
        compressedFile = File(compressedXFile.path);
        int compressedFileSize = await compressedFile.length();

        if (compressedFileSize <= minSize) {
          return compressedFile;
        } else {
          quality -= 5; // 每次减少5的质量
          if (quality < 10) break; // 避免质量过低
        }
      } else {
        return null;
      }
    } while (quality >= 10);

    return compressedFile;
  } catch (e) {
    debugPrint('compressAndConvertToJpg ❌: $e');
  }
  return null;
}

/// 对文件进行 md5 计算
Future<String> calculateMd5(File file) async {
  try {
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  } catch (e) {
    debugPrint('calculateMd5 ❌: $e');
    return '';
  }
}

/// 判断 2 个文件是否相同
Future<bool> isSameImage(File file1, File file2) async {
  final hash1 = await calculateMd5(file1);
  final hash2 = await calculateMd5(file2);
  return hash1.isNotEmpty && hash1 == hash2;
}

/// 微信会话列表英文时间格式转换
/// Rules:
/// - Today's messages: show HH:MM (e.g. 14:30)
/// - Yesterday's messages: show "Yesterday"
/// - Messages within this week: show weekday (e.g. Mon, Tue)
/// - Messages within this year: show MM/DD (e.g. 08/20)
/// - Messages from previous years: show YYYY/MM/DD (e.g. 2023/08/20)
String formatSessionTimeEnglish(int timestamp) {
  // Convert timestamp to DateTime object
  DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  DateTime now = DateTime.now();

  // Check if two dates are the same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get weekday abbreviation in English
  String getWeekdayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  // Format number with leading zero if needed
  String twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  // Today
  if (isSameDay(messageTime, now)) {
    return '${twoDigits(messageTime.hour)}:${twoDigits(messageTime.minute)}';
  }

  // Yesterday
  DateTime yesterday = now.subtract(const Duration(days: 1));
  if (isSameDay(messageTime, yesterday)) {
    return 'Yesterday';
  }

  // Within this week (last 7 days)
  DateTime aWeekAgo = now.subtract(const Duration(days: 7));
  if (messageTime.isAfter(aWeekAgo) && messageTime.isBefore(yesterday)) {
    return getWeekdayAbbreviation(messageTime.weekday);
  }

  // Within this year
  if (messageTime.year == now.year) {
    return '${twoDigits(messageTime.month)}/${twoDigits(messageTime.day)}';
  }

  // Previous years
  return '${messageTime.year}/${twoDigits(messageTime.month)}/${twoDigits(messageTime.day)}';
}
