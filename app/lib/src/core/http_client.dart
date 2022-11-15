import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'config.dart';

class HttpNetworkUtil {
  // Setup a singleton
  static final HttpNetworkUtil _httpClient = HttpNetworkUtil._internal();
  factory HttpNetworkUtil() {
    return _httpClient;
  }
  HttpNetworkUtil._internal();

  // global variables
  final Logger _logger = Logger();

  static BaseOptions baseOptions = BaseOptions(
    baseUrl: AppConfig.getProd().apiUrl,
    contentType: 'application/json',
    connectTimeout: 30 * 1000,
    receiveTimeout: 30 * 1000,
    followRedirects: true,
    receiveDataWhenStatusError: true,
  );

  static Dio dio = Dio(baseOptions);

  // methods
  Future<Response> getRequest(String endpoint) async {
    try {
      Dio dio = await addInterceptors();
      Response response = await dio.get(
        endpoint,
      );

      _logger.i(
          "getRequest:\nurl:${response.realUri.toString()}\nresponse:${response.statusCode}");
      return response;
    } catch (e) {
      _logger.e(e);
      rethrow;
    }
  }

  Future<Response> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      Dio dio = await addInterceptors();
      _logger.i(
        "postPayload:\nendpoint: ${dio.options.baseUrl}$endpoint\nbody:${json.encode(body)}",
      );
      Response response = await dio.post(
        endpoint,
        data: json.encode(body),
      );
      _logger.i(
        "postRequest:\nurl:${response.realUri.toString()}\nresponse:\n${response.statusCode}\n${response.data}",
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> putRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    _logger.d(json.encode(body));
    try {
      Dio dio = await addInterceptors();
      Response response = await dio.put(
        endpoint,
        data: json.encode(body),
      );
      _logger.i(
        "putRequest:\nurl:${response.realUri.toString()}\nresponse:\n${response.statusCode}\n${response.data}",
      );
      return response;
    } catch (e) {
      _logger.e(e);
      rethrow;
    }
  }

  Future<Response> deleteRequest(String endpoint) async {
    try {
      Dio dio = await addInterceptors();
      Response response = await dio.delete(
        endpoint,
      );
      _logger.i(
        "deleteRequest:\nurl:${response.realUri.toString()}\nresponse:\n${response.statusCode}",
      );
      return response;
    } catch (e) {
      _logger.e(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> multipartUpload(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    final formData = FormData.fromMap({
      'name': body['name'],
      'path': body['path'],
      'access': body['access'],
      'type': body['type'],
      'file': await MultipartFile.fromFile(
        body['file'],
        filename: body['name'],
      )
    });
    Dio dio = await addInterceptors();
    final resp = await dio.post(url, data: formData);

    return resp.data;
  }

  Future<Dio> addInterceptors() async {
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (request, handler) {
        return handler.next(request);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (e, handler) {
        return handler.next(e);
      },
    ));
    // String token = await PreferencesRepository().getToken();
    // dio.interceptors.add(DioFirebasePerformanceInterceptor());
    // dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (request, handler) {
    //       if (token != '') request.headers['x-access-token'] = token;
    //       return handler.next(request);
    //     },
    //     onResponse: (response, handler) {
    //       return handler.next(response);
    //     },
    //     onError: (err, handler) async {
    //       if (err.response?.statusCode == 401) {
    //         try {
    //           _logger.e('401 error');
    //           dio.interceptors.requestLock.lock();
    //           dio.interceptors.errorLock.lock();
    //           dio.interceptors.responseLock.lock();
    //           final newToken = await specialRefresh();

    //           if (newToken != null) {
    //             await PreferencesRepository().setToken(newToken);
    //             err.requestOptions.headers['x-access-token'] = newToken;
    //             final opts = Options(
    //               method: err.requestOptions.method,
    //               headers: err.requestOptions.headers,
    //             );
    //             BaseOptions baseOptions = BaseOptions(
    //               baseUrl: "https://nilipie.ml",
    //               receiveDataWhenStatusError: true,
    //               headers: <String, dynamic>{
    //                 'x-access-token': newToken,
    //               },
    //             );

    //             Dio _dio = Dio(baseOptions);
    //             _logger.i(
    //               "Special request :\nendpoint: /refresh_token\n",
    //             );
    //             final cloneReq = await _dio.request(
    //               err.requestOptions.path,
    //               options: opts,
    //               data: err.requestOptions.data,
    //               queryParameters: err.requestOptions.queryParameters,
    //             );
    //             dio.interceptors.requestLock.unlock();
    //             dio.interceptors.errorLock.unlock();
    //             dio.interceptors.responseLock.unlock();

    //             return handler.resolve(cloneReq);
    //           } else {
    //             return handler.reject(err);
    //           }
    //         } catch (e) {
    //           return handler.reject(err);
    //         }
    //       } else {
    //         return handler.next(err);
    //       }
    //     },
    //   ),
    // );
    return dio;
  }
}
