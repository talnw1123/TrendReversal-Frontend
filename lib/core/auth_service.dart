import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001/api',
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

  // ── Real Login ──────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post('/v1/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        _accessToken = res.data['accessToken'];
        _user = res.data['user'];

        // Save to prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('current_user', jsonEncode(_user));
        return true;
      }
      return false;
    } catch (e) {
      print('[AuthService] Login Error: $e');
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('current_user');
  }
}
