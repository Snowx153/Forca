import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = _buildUri(path, queryParameters);
    final response = await _client
        .get(_withHeaders(uri, headers), headers: _headers(headers))
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = _buildUri(path);
    final response = await _client
        .post(
          _withHeaders(uri, headers),
          headers: _headers(headers),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = _buildUri(path);
    final response = await _client
        .put(
          _withHeaders(uri, headers),
          headers: _headers(headers),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = _buildUri(path);
    final response = await _client
        .patch(
          _withHeaders(uri, headers),
          headers: _headers(headers),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = _buildUri(path);
    final response = await _client
        .delete(
          _withHeaders(uri, headers),
          headers: _headers(headers),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${ApiConfig.baseUrl}$cleanPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
    });
  }

  Uri _withHeaders(Uri uri, Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return uri;
    return uri;
  }

  Map<String, String> _headers(Map<String, String>? headers) {
    final baseHeaders = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (headers != null) {
      baseHeaders.addAll(headers);
    }

    return baseHeaders;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    final errorMessage = _extractErrorMessage(decoded);

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      body: decoded,
    );
  }

  String _extractErrorMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('message')) {
        return decoded['message'].toString();
      }

      if (decoded.containsKey('error')) {
        return decoded['error'].toString();
      }

      final validationErrors = <String>[];
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is List) {
          validationErrors.addAll(value.map((e) => e.toString()));
        } else if (value is String) {
          validationErrors.add(value);
        }
      }

      if (validationErrors.isNotEmpty) {
        return validationErrors.join(', ');
      }
    }

    return 'Une erreur réseau ou serveur s\'est produite.';
  }
}

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    required this.body,
  });

  final int statusCode;
  final String message;
  final Map<String, dynamic>? body;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
