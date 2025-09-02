// TODO Implement this library.

import 'package:flutter/foundation.dart';

// You'll likely have a User model. Define a simple one here or import your existing one.
class User {
  final String id;
  final String name;
  final String email;
  // Add other relevant user fields: token, phone_no, etc.
  // For example:
  // final String? phoneNumber;
  // final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    // this.phoneNumber,
    // this.profileImageUrl,
  });

  // Optional: Factory constructor to create a User from a Map (e.g., API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '', // Ensure ID is a string, handle null
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? 'No email',
      // phoneNumber: json['phone_no'],
      // profileImageUrl: json['profile_image_url'],
    );
  }

  // Optional: toJson method if you need to convert User object back to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      // 'phone_no': phoneNumber,
      // 'profile_image_url': profileImageUrl,
    };
  }
}

class AuthState with ChangeNotifier {
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _currentUser != null && _authToken != null;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Example Login Method
  // In a real app, this would involve an API call
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // **** Replace this with your actual API call and response handling ****
      // For example:
      // final response = await ApiService.login(email, password);
      // if (response.isSuccessful) {
      //   final userData = response.body['data']; // Or however your API structures it
      //   final token = response.body['token'];
      //   _currentUser = User.fromJson(userData);
      //   _authToken = token;
      // } else {
      //   throw Exception('Failed to login: ${response.errorMessage}');
      // }

      // Dummy data for now:
      if (email == "test@example.com" && password == "password") {
        _currentUser = User(id: "1", name: "Test User", email: email);
        _authToken = "dummy_auth_token_string";
        print("User logged in: ${_currentUser?.name}");
      } else {
        throw Exception("Invalid credentials");
      }
    } catch (e) {
      print("Login error: $e");
      _currentUser = null;
      _authToken = null;
      // Rethrow to allow UI to handle the error message
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Example Sign Up Method
  Future<void> signUp(String name, String email, String password) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // **** Replace with actual API call ****
      // For example:
      // final response = await ApiService.signUp(name, email, password);
      // if (response.isSuccessful) {
      //    // Typically, you might auto-login the user or ask them to verify email
      //    // For now, we'll just set a dummy user and token
      //   _currentUser = User(id: "new_user_id", name: name, email: email);
      //   _authToken = "new_dummy_auth_token";
      // } else {
      //   throw Exception('Failed to sign up: ${response.errorMessage}');
      // }

      // Dummy logic:
      _currentUser = User(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, email: email);
      _authToken = "dummy_signup_token";
      print("User signed up and logged in: ${_currentUser?.name}");

    } catch (e) {
      print("SignUp error: $e");
      _currentUser = null;
      _authToken = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  void logout() {
    _currentUser = null;
    _authToken = null;
    _isLoading = false; // Reset loading state on logout
    print("User logged out");
    notifyListeners();
    // In a real app, you might also want to:
    // - Clear any stored tokens (e.g., from SharedPreferences)
    // - Call an API endpoint to invalidate the session/token on the server
  }

// You can add more methods here, like:
// - fetchUserProfile()
// - updateToken(String newToken)
// - checkInitialAuthStatus() (e.g., on app start, check SharedPreferences for a token)
}
