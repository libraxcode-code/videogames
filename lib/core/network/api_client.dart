import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';

class ApiClient {
  final http.Client client;
  final Duration timeoutDuration;

  ApiClient({
    http.Client? client,
    this.timeoutDuration = const Duration(seconds: 15),
  }) : client = client ?? http.Client();

  Future<dynamic> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await client
          .get(uri, headers: headers)
          .timeout(timeoutDuration);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException(message: 'Request timeout');
    }
  }

  Future<dynamic> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await client
          .post(
            uri,
            headers: headers ?? {'Content-Type': 'application/json'},
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeoutDuration);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException(message: 'Request timeout');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw ServerException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
