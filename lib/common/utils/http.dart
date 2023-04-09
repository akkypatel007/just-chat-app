import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just/common/utils/utils.dart';
import 'package:just/common/values/server.dart';

import '../entities/user.dart';
import '../store/user.dart';

class HttpUtil {
  static HttpUtil _instance = HttpUtil._internal();

  factory HttpUtil() => _instance;

  late Dio dio;
  CancelToken cancelToken = CancelToken();

  HttpUtil._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: SERVER_API_URL,
      connectTimeout: 10000,
      receiveTimeout: 5000,
      headers: {},
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
//cookie management
    CookieJar cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
//add interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          Loading.dismiss();
          ErrorEntity eInfo = createErrorEntity(e);
          onError(eInfo);
          return handler.next(e);
        },
      ),
    );
  }

  void onError(ErrorEntity eInfo) {
    print('error,code ->' +
        eInfo.code.toString() +
        ', error.message -> ' +
        eInfo.message);
    switch (eInfo.code) {
      case 401:
        UserStore.to.onLogout();
        EasyLoading.showError(eInfo.message);
        break;
      default:
        EasyLoading.showError('unknown error');
        break;
    }
  }

/*
  ErrorEntity createErrorEntity(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        return ErrorEntity(code: -1, message: "");
      case DioErrorType.connectTimeout:
        return ErrorEntity(code: -1, message: "");
      case DioErrorType.sendTimeout:
        return ErrorEntity(code: -1, message: "");
      case DioErrorType.receiveTimeout:
        return ErrorEntity(code: -1, message: "");
      case DioErrorType.cancel:
        return ErrorEntity(code: -1, message: "");
      case DioErrorType.response:
        {
          try {
            int errCode =
                error.response != null ? error.response!.statusCode! : -1;
// String errMsg error.response.statusMessage;
// return ErrorEntity (code: errCode, message: errmsg);
            switch (errCode) {
              case 400:
                return ErrorEntity(code: errCode, message: "");
              case 401:
                return ErrorEntity(code: errCode, message: "");
              case 403:
                return ErrorEntity(code: errCode, message: "");
              case 404:
                return ErrorEntity(code: errCode, message: "");
              case 405:
                return ErrorEntity(code: errCode, message: "");
              case 500:
                return ErrorEntity(code: errCode, message: "");
              case 502:
                return ErrorEntity(code: errCode, message: "FR");
              case 503:
                return ErrorEntity(code: errCode, message: "7");
              case 505:
                return ErrorEntity(code: errCode, message: "HTTP");
              default:
                {
// return ErrorEntity (code: errCode, message: "*");
                  return ErrorEntity(
                      code: errCode,
                      message: error.response != null
                          ? error.response!.statusMessage!
                          : "");
                }
            }
          } on Exception catch (_) {
            return ErrorEntity(code: -1, message: "");
          }
        }
      default:
        {
          return ErrorEntity(code: -1, message: "");
        }
    }
  }
*/

  ErrorEntity createErrorEntity(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        return ErrorEntity(code: -1, message: "Request cancelled");
      case DioErrorType.connectTimeout:
        return ErrorEntity(code: -1, message: "Connection timed out");
      case DioErrorType.sendTimeout:
        return ErrorEntity(
            code: -1, message: "Request timed out while sending data");
      case DioErrorType.receiveTimeout:
        return ErrorEntity(
            code: -1, message: "Request timed out while receiving data");
      case DioErrorType.response:
        {
          try {
            int errCode =
                error.response != null ? error.response!.statusCode! : -1;
            switch (errCode) {
              case 400:
                return ErrorEntity(code: errCode, message: "Bad request");
              case 401:
                return ErrorEntity(
                    code: errCode, message: "Unauthorized access");
              case 403:
                return ErrorEntity(code: errCode, message: "Forbidden access");
              case 404:
                return ErrorEntity(
                    code: errCode, message: "Resource not found");
              case 405:
                return ErrorEntity(
                    code: errCode, message: "Method not allowed");
              case 500:
                return ErrorEntity(
                    code: errCode, message: "Internal server error");
              case 502:
                return ErrorEntity(code: errCode, message: "Bad gateway");
              case 503:
                return ErrorEntity(
                    code: errCode, message: "Service unavailable");
              case 505:
                return ErrorEntity(
                    code: errCode, message: "HTTP version not supported");
              default:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response != null
                          ? error.response!.statusMessage!
                          : "Unknown error");
                }
            }
          } on Exception catch (_) {
            return ErrorEntity(code: -1, message: "Unknown error");
          }
        }
      default:
        {
          return ErrorEntity(code: -1, message: "Unknown error");
        }
    }
  }

  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }

  Map<String, dynamic>? getAuthorizationHeader() {
    var headers = <String, dynamic>{};
    if (Get.isRegistered<UserStore>() && UserStore.to.hasToken == true) {
      headers['Authorization'] = 'Bearer ${UserStore.to.token}';
    }
    return headers;
  }

  /* Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool refresh = false,
    bool noCache = !CACHE_ENABLE,
    bool list = false,
    String cacheKey = '',
    bool cacheDisk = false,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= Map();
    requestOptions.extra!.addAll({
      "refresh": refresh,
      "noCache": noCache,
      "list": list,
      "cacheKey": cacheKey,
      "cacheDisk": cacheDisk,
    });
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return response.data;
  }
*/

  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response.data;
  }
}
