import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:get/get.dart';

class FHttp {
  // 单例模式
  static final FHttp _instance = FHttp._internal();
  factory FHttp() => _instance;
  FHttp._internal();

  final GetConnect _client = GetConnect();

  void init({required String baseUrl}) {
    _client.baseUrl = baseUrl;
    _client.timeout = const Duration(seconds: 60);
    // 配置 header
    _client.httpClient.addRequestModifier<dynamic>((request) async {
      final deviceId = await FCache().phoneId();
      final version = await FService().version();
      final headers = {
        'Content-Type': 'application/json',
        'device-id': deviceId,
        'platform': FService().platform,
        'version': version,
        // 添加语言
        'lang': Get.deviceLocale?.languageCode ?? 'en',
      };
      request.headers.addAll(headers);
      return request;
    });
  }

  /// GET 请求
  Future<Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await _client.get(path, headers: headers, query: queryParameters);
      log.i('GET $path: ${response.request?.headers} $queryParameters');
      log.i('response: ${response.bodyString}\n');
      if (!response.isOk) {
        FToast.toast(LocaleKeys.network_error.tr);
      }
      return response;
    } catch (e) {
      log.e('GET $path: catch  ${e.toString()}');
      return Response(statusCode: -1, statusText: 'Error: $e');
    }
  }

  /// POST 请求
  Future<Response> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    String? contentType,
  }) async {
    try {
      final response = await _client.post(
        path,
        body,
        headers: headers,
        query: queryParameters,
        contentType: contentType,
      );
      log.i(
        'POST $path:${response.request?.headers} $queryParameters: $queryParameters body:$body',
      );
      log.i('response: ${response.bodyString}\n');
      if (!response.isOk) {
        FToast.toast(LocaleKeys.network_error.tr);
      }
      return response;
    } catch (e) {
      log.e('POST $path: catch ${e.toString()}');
      return Response(statusCode: -1, statusText: 'Error: $e');
    }
  }
}
