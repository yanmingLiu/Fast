import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../services/f_service.dart';

/// Represents different types of files that can be downloaded.
///
/// Each file type has specific properties that determine how files
/// of that type are stored and named in the file system.
enum FileType {
  /// Audio files like mp3, wav, etc.
  audio('Audio', 'audios_files', true),

  /// Video files like mp4, mov, etc.
  video('Video', 'video_files', false),

  /// Image files like jpg, png, etc.
  image('Image', 'image_files', true),

  /// Document files like pdf, doc, etc.
  document('Document', 'document_files', false),

  /// Other file types not covered by specific categories.
  other('File', 'downloads', false);

  /// Display label for the file type.
  final String label;

  /// Default folder name where files of this type are stored.
  final String folderName;

  /// Whether to use hash-based naming for this file type.
  final bool useHashName;

  /// Creates a file type with the specified properties.
  const FileType(this.label, this.folderName, this.useHashName);

  @override
  String toString() => label;
}

/// A utility class for downloading files with configurable storage options.
///
/// This class provides methods to download files from URLs and store them
/// in the application's documents directory with various naming and
/// organization strategies.
class Downloader {
  /// Downloads a file from the specified URL.
  ///
  /// This method downloads a file from [url] and stores it in the application's
  /// documents directory. The storage location and naming strategy are determined
  /// by the [fileType] parameter, but can be overridden with [folderName] and
  /// [useHashName].
  ///
  /// Parameters:
  /// - [url]: The URL to download the file from.
  /// - [folderName]: Optional custom folder name to override the default from [fileType].
  /// - [useHashName]: Optional flag to override the default hash naming strategy from [fileType].
  /// - [fileExtension]: Optional file extension to override the one in the URL.
  /// - [fileType]: The type of file being downloaded, which determines default storage behavior.
  ///
  /// Returns a [Future] that completes with the path to the downloaded file,
  /// or `null` if the download failed.
  static Future<String?> downloadFile(
    String url, {
    String? folderName,
    bool? useHashName,
    String? fileExtension,
    FileType fileType = FileType.other,
  }) async {
    // Validate input URL
    if (url.isEmpty) {
      log.e('[DownloadUtil] Download failed: Empty URL provided');
      SmartDialog.showNotify(
          msg: 'Invalid download URL', notifyType: NotifyType.error);
      return null;
    }

    // Apply configuration with defaults from FileType and optional overrides
    final String actualFolderName = folderName ?? fileType.folderName;
    final bool actualUseHashName = useHashName ?? fileType.useHashName;
    try {
      // 获取文档目录
      Directory docDir = await getApplicationDocumentsDirectory();
      String folderPath = path.join(docDir.path, actualFolderName);

      // 创建文件夹（如果不存在）
      Directory folder = Directory(folderPath);
      if (!folder.existsSync()) {
        await folder.create(recursive: true);
      }

      // 确定文件名和保存路径
      String fileName;
      String savePath;
      String targetFilePath;

      if (actualUseHashName) {
        // 使用哈希命名方式
        String originalFileName = generateFileNameFromUrl(url);
        savePath = path.join(folderPath, originalFileName);

        // 获取文件的扩展名
        String currentExtension =
            path.extension(originalFileName).toLowerCase();
        String fileNameWithoutExtension =
            path.basenameWithoutExtension(originalFileName);

        // 如果提供了扩展名覆盖，则使用它
        String finalExtension = fileExtension ?? currentExtension;
        targetFilePath =
            path.join(folderPath, '$fileNameWithoutExtension$finalExtension');
      } else {
        // 使用原始文件名
        fileName = Uri.parse(url).pathSegments.last;
        savePath = path.join(folderPath, fileName);
        targetFilePath = savePath;

        // 如果提供了扩展名覆盖，则替换原始扩展名
        if (fileExtension != null) {
          String fileNameWithoutExtension =
              path.basenameWithoutExtension(fileName);
          targetFilePath =
              path.join(folderPath, '$fileNameWithoutExtension$fileExtension');
        }
      }

      // 规范化路径，确保分隔符一致
      targetFilePath = path.normalize(targetFilePath);

      // 检查文件是否已存在
      bool fileExists = await File(targetFilePath).exists();
      if (fileExists) {
        log.d('[df] $fileType already exists, path: $targetFilePath');
        return targetFilePath;
      } else {
        log.d('[df] $fileType does not exist, path: $targetFilePath');
      }

      // 检查临时下载文件是否存在
      if (File(savePath).existsSync()) {
        log.d(
            '[df] $fileType is being downloaded or already downloaded, path: $savePath');
        return savePath;
      }

      // File doesn't exist, proceed with download
      final dio = Dio();

      // Configure timeout and headers
      final options = Options(
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 2),
        headers: {'User-Agent': 'FastAI-App/1.0'},
      );

      // Show download starting notification
      log.d('[DownloadUtil] Starting download: $url');

      await dio.download(
        url,
        savePath,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            log.d('[DownloadUtil] Download progress: $progress% for $fileType');
          }
        },
      );

      // 如果目标路径与保存路径不同，需要重命名文件
      if (savePath != targetFilePath) {
        File downloadedFile = File(savePath);
        if (downloadedFile.existsSync()) {
          File newFile = await downloadedFile.rename(targetFilePath);
          log.d(
              '[df] $fileType downloaded and renamed successfully, path: $targetFilePath');
          return newFile.path;
        }
        log.d('[df] $fileType rename failed, path: $savePath');
        return savePath;
      } else {
        log.d('[df] $fileType download completed, path: $savePath');
        return savePath;
      }
    } catch (e, stackTrace) {
      // Provide detailed error logging
      log.e('[DownloadUtil] $fileType download failed: $e, URL: $url');
      log.d('[DownloadUtil] Stack trace: $stackTrace');

      // Provide user-friendly error message based on error type
      String errorMessage;
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Connection timed out';
            break;
          case DioExceptionType.badResponse:
            errorMessage =
                'Server error: ${e.response?.statusCode ?? "Unknown"}';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'No internet connection';
            break;
          default:
            errorMessage = 'Download failed';
        }
      } else if (e is FileSystemException) {
        errorMessage = 'Storage error: ${e.message}';
      } else {
        errorMessage = 'Download error';
      }

      // Show user-friendly notification
      SmartDialog.showNotify(
        msg: '$errorMessage - ${fileType.label}',
        notifyType: NotifyType.error,
      );

      return null;
    }
  }

  /// Generates a unique filename based on the URL.
  ///
  /// This method creates a filename by combining a SHA-256 hash of the URL
  /// with the original filename from the URL. This ensures uniqueness while
  /// preserving some information about the original file.
  ///
  /// Parameters:
  /// - [url]: The URL to generate a filename from.
  ///
  /// Returns a string containing the generated filename.
  static String generateFileNameFromUrl(String url) {
    // Generate a hash from the URL for uniqueness
    final bytes = utf8.encode(url);
    final hash = sha256.convert(bytes);

    // Extract the original filename from the URL
    final fileName = Uri.parse(url).pathSegments.isEmpty
        ? 'file'
        : Uri.parse(url).pathSegments.last;

    // Use the first 16 characters of the hash for reasonable uniqueness
    final hashedPrefix = hash.toString().substring(0, 16);

    return '$hashedPrefix-$fileName';
  }
}
