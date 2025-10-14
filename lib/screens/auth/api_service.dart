import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.baseUrl;
  String? _accessToken;
  String? _refreshToken;

  // Initialize service with stored tokens
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  // Store tokens
  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Clear tokens
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storeTokens(data['access'], _refreshToken!);
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }

    return false;
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, String>? queryParams,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      Uri uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      var response = await http.get(uri, headers: _headers);

      // Handle token expiry
      if (response.statusCode == 401 && await _refreshAccessToken()) {
        response = await http.get(uri, headers: _headers);
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>.error('Network error: ${e.toString()}');
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
      String endpoint,
      Map<String, dynamic> data, {
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final fullUrl = '$_baseUrl$endpoint';
      print('🌐 Making POST request to: $fullUrl');
      print('📤 Request data: $data');
      print('🔑 Headers: $_headers');

      var response = await http.post(
        Uri.parse(fullUrl),
        headers: _headers,
        body: json.encode(data),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      // Handle token expiry
      if (response.statusCode == 401 && await _refreshAccessToken()) {
        print('🔄 Retrying with new token...');
        response = await http.post(
          Uri.parse(fullUrl),
          headers: _headers,
          body: json.encode(data),
        );
        print('📡 Retry response status: ${response.statusCode}');
        print('📥 Retry response body: ${response.body}');
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('💥 Network error in POST: $e');
      return ApiResponse<T>.error('Network error: ${e.toString()}');
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
      String endpoint,
      Map<String, dynamic> data, {
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      var response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      // Handle token expiry
      if (response.statusCode == 401 && await _refreshAccessToken()) {
        response = await http.put(
          Uri.parse('$_baseUrl$endpoint'),
          headers: _headers,
          body: json.encode(data),
        );
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>.error('Network error: ${e.toString()}');
    }
  }

  // Generic DELETE request
  Future<ApiResponse<void>> delete(String endpoint) async {
    try {
      var response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
      );

      // Handle token expiry
      if (response.statusCode == 401 && await _refreshAccessToken()) {
        response = await http.delete(
          Uri.parse('$_baseUrl$endpoint'),
          headers: _headers,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<void>.success(null);
      } else {
        return ApiResponse<void>.error('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse<void>.error('Network error: ${e.toString()}');
    }
  }

  // Handle response parsing
  ApiResponse<T> _handleResponse<T>(
      http.Response response,
      T Function(Map<String, dynamic>)? fromJson,
      ) {
    try {
      print('🔍 Parsing response...');
      print('📊 Status code: ${response.statusCode}');
      print('📋 Raw body: ${response.body}');

      final responseBody = json.decode(response.body);
      print('📦 Parsed JSON: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Request successful!');
        if (fromJson != null && responseBody is Map<String, dynamic>) {
          final result = fromJson(responseBody);
          print('🎯 Parsed result: $result');
          return ApiResponse<T>.success(result);
        }
        print('🎯 Returning raw data');
        return ApiResponse<T>.success(responseBody as T);
      } else {
        print('❌ Request failed with status: ${response.statusCode}');
        String errorMessage = 'Request failed';
        if (responseBody is Map<String, dynamic>) {
          // Handle field-specific errors
          final fieldErrors = <String>[];
          responseBody.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              fieldErrors.add('$key: ${value[0]}');
            } else if (value is String) {
              fieldErrors.add(value);
            }
          });

          if (fieldErrors.isNotEmpty) {
            errorMessage = fieldErrors.join(', ');
          } else {
            errorMessage = responseBody['message'] ??
                responseBody['error'] ??
                responseBody['detail'] ??
                'Request failed with status ${response.statusCode}';
          }
          print('📝 Extracted error message: $errorMessage');
        }
        print('💥 Returning error: $errorMessage');
        return ApiResponse<T>.error(errorMessage);
      }
    } catch (e) {
      print('💥 Failed to parse response: $e');
      print('📋 Raw response body: ${response.body}');
      return ApiResponse<T>.error('Failed to parse response: ${e.toString()}');
    }
  }

  // File upload method
  Future<ApiResponse<T>> uploadFile<T>(
      String endpoint,
      File file,
      String fieldName, {
        Map<String, String>? additionalFields,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));

      // Add headers
      request.headers.addAll(_headers);
      request.headers.remove('Content-Type'); // Remove to let http set it

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ));

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>.error('Upload failed: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _accessToken != null;
}

// API Response wrapper class
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResponse.error(this.error)
      : data = null,
        isSuccess = false;
}