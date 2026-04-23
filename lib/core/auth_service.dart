import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:4000/api',
    connectTimeout: const Duration(seconds: 10),
  ));

  String? _accessToken;
  Map<String, dynamic>? _user;

  String? get token => _accessToken;
  Map<String, dynamic>? get currentUser => _user;

  // ── Load Saved Token ─────────────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      _user = jsonDecode(userStr);
    }
  }

  // ── Save token to local storage ──────────────────────────────────────────────
  Future<void> _saveSession(String accessToken, Map<String, dynamic> user) async {
    _accessToken = accessToken;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('current_user', jsonEncode(user));
  }

  // ── Real Login ──────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post('/v1/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        await _saveSession(res.data['accessToken'], res.data['user']);
        return true;
      }
      return false;
    } catch (e) {
      print('[AuthService] Login Error: $e');
      return false;
    }
  }

  // ── Register Step 1: Send OTP ────────────────────────────────────────────────
  /// Returns pendingId on success, or null on failure.
  /// [errorMessage] will be non-null if there's an error to display.
  Future<({String? pendingId, String? errorMessage})> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/v1/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        final pendingId = res.data['pendingId'] as String?;
        return (pendingId: pendingId, errorMessage: null);
      }
      return (pendingId: null, errorMessage: 'Registration failed. Please try again.');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registration failed. Please try again.';
      return (pendingId: null, errorMessage: msg.toString());
    } catch (e) {
      print('[AuthService] Register Error: $e');
      return (pendingId: null, errorMessage: 'An unexpected error occurred.');
    }
  }

  // ── Register Step 2: Verify OTP ──────────────────────────────────────────────
  Future<({bool success, String? errorMessage})> verifyEmail({
    required String pendingId,
    required String code,
  }) async {
    try {
      final res = await _dio.post('/v1/auth/verify-email', data: {
        'pendingId': pendingId,
        'code': code,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        await _saveSession(res.data['accessToken'], res.data['user']);
        return (success: true, errorMessage: null);
      }
      return (success: false, errorMessage: 'Verification failed. Please try again.');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Invalid or expired OTP.';
      return (success: false, errorMessage: msg.toString());
    } catch (e) {
      print('[AuthService] VerifyEmail Error: $e');
      return (success: false, errorMessage: 'An unexpected error occurred.');
    }
  }

  // ── Resend OTP ───────────────────────────────────────────────────────────────
  Future<({String? pendingId, String? errorMessage})> resendCode(String email) async {
    try {
      final res = await _dio.post('/v1/auth/resend-code', data: {'email': email});
      if (res.statusCode == 200 || res.statusCode == 201) {
        return (pendingId: res.data['pendingId'] as String?, errorMessage: null);
      }
      return (pendingId: null, errorMessage: 'Failed to resend code.');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to resend code.';
      return (pendingId: null, errorMessage: msg.toString());
    } catch (e) {
      return (pendingId: null, errorMessage: 'An unexpected error occurred.');
    }
  }

  // ── Save session from Google OAuth (called with tokens from URL) ─────────────
  Future<void> loginWithTokens(String accessToken) async {
    try {
      // Fetch user profile with the provided token
      final res = await _dio.get(
        '/v1/users/profile',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (res.statusCode == 200) {
        await _saveSession(accessToken, res.data);
      }
    } catch (e) {
      print('[AuthService] loginWithTokens Error: $e');
      // At minimum save the token even if profile fetch fails
      _accessToken = accessToken;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
    }
  }

  // ── Google OAuth URL ─────────────────────────────────────────────────────────
  String get googleAuthUrl => 'http://localhost:4000/api/v1/auth/google';

  // ── Logout ───────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('current_user');
  }
}
