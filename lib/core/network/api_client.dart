import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:ecommece_site_1688/core/network/api_endpoint.dart';
import 'package:ecommece_site_1688/core/network/error_handle.dart';
import 'package:ecommece_site_1688/core/network/response_handle.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: Duration(seconds: 10),
      sendTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  /// GET request
  Future<dynamic> getRequest({
    required String endpoints,
    Map<String, String>? headers,
  }) async {
    try {
      log("\n\n\n\nurl :${ApiEndpoints.baseUrl}/$endpoints \n\n\n\n");

      final response = await _dio.get(
        endpoints,
        options: Options(
          headers: headers ?? {"Content-Type": "application/json"},
        ),
      );

      logResponseBody(response);
      return ResposeHandle.handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        ErrorHandle.handleDioError(e);
      } else {
        log('Non-Dio error: $e');
      }
      rethrow;
    }
  }

  /// POST request
  static Future<dynamic> postRequest({
    required String endpoints,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    FormData? formData,
  }) async {
    try {
      log("\n\nurl :${ApiEndpoints.baseUrl}/$endpoints\n\n");
      final response = await _dio.post(
        endpoints,
        data: body ?? formData,
        options: Options(
          headers: headers ?? {"Content-Type": "application/json"},
        ),
      );
      logResponseBody(response);
      return ResposeHandle.handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        ErrorHandle.handleDioError(e);
      } else {
        log('Non-Dio error: $e');
      }
    }
  }

  /// PUT request
  static Future<dynamic> putRequest({
    Map<String, String>? headers,
    required String endpoints,
    required Map<String, dynamic> body,
  }) async {
    try {
      log("\n\nurl :${ApiEndpoints.baseUrl}/$endpoints\n\n");
      final response = await _dio.put(
        endpoints,
        data: body,
        options: Options(
          headers: headers ?? {"Content-Type": "application/json"},
        ),
      );
      return ResposeHandle.handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        ErrorHandle.handleDioError(e);
      } else {
        log('Non-Dio error: $e');
      }
    }
  }

  /// PATCH request
  static Future<dynamic> patchRequest({
    required String endpoints,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    FormData? formData,
  }) async {
    try {
      log("\n\nurl :${ApiEndpoints.baseUrl}/$endpoints\n\n");
      final response = await _dio.patch(
        endpoints,
        data: body ?? formData,
        options: Options(
          headers: headers ?? {"Content-Type": "application/json"},
        ),
      );

      return ResposeHandle.handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        ErrorHandle.handleDioError(e);
      } else {
        log('Non-Dio error: $e');
      }
    }
  }

  /// PATCH request
  static Future<dynamic> deleteRequest({
    required String endpoints,
    Map<String, String>? headers,
  }) async {
    try {
      log("\n\nurl :${ApiEndpoints.baseUrl}/$endpoints\n\n");
      final response = await _dio.delete(
        endpoints,
        options: Options(
          headers: headers ?? {"Content-Type": "application/json"},
        ),
      );

      debugPrint("delete Request Successful");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Data: ${response.data}");

      return ResposeHandle.handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        ErrorHandle.handleDioError(e);
      } else {
        log('Non-Dio error: $e');
      }
    }
  }

  // Helper method to log response body
  void logResponseBody(Response response) {
    try {
      log("""
  ╔═══════════════════════════════════════════════════════════
  ║ 📥 RAW RESPONSE BODY
  ║ Status: ${response.statusCode}
  ║ Status Message: ${response.statusMessage}
  ║ URL: ${response.realUri}
  ║ Headers: ${response.headers}
  ╠═══════════════════════════════════════════════════════════
  ${_formatResponseData(response.data)}
  ╚═══════════════════════════════════════════════════════════
  """);
    } catch (e) {
      log('⚠️ Error logging response body: $e');
    }
  }

  String _formatResponseData(dynamic data) {
    try {
      if (data == null) return '  <null response>';
      
      if (data is String) {
        // Try to pretty print if it's JSON string
        try {
          final jsonData = jsonDecode(data);
          final encoder = JsonEncoder.withIndent('  ');
          return encoder.convert(jsonData);
        } catch (_) {
          return '  $data';
        }
      } else if (data is Map || data is List) {
        // Pretty print JSON objects/lists
        final encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } else {
        return '  ${data.toString()}';
      }
    } catch (e) {
      return '  Error formatting response: $e';
    }
  }
}
