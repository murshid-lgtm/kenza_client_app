import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_config.dart';

class BootstrapState {
  final bool hasSession;
  final bool requiresPinUnlock;
  final bool requiresPinSetup;
  final String? email;

  const BootstrapState({
    required this.hasSession,
    required this.requiresPinUnlock,
    required this.requiresPinSetup,
    this.email,
  });
}

class PendingRegistration {
  final String fullName;
  final String email;
  final String mobile;
  final String password;

  const PendingRegistration({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.password,
  });
}

enum OtpFlow { signup, forgotPin }

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _pinHashKey = 'kenza_pin_hash';
  static const String _pinEmailKey = 'kenza_pin_email';
  static const String _pinReadyKey = 'kenza_pin_ready';
  static const String _lastEmailKey = 'kenza_last_email';
  static const String _profileNameKey = 'kenza_profile_name';
  static const String _profileMobileKey = 'kenza_profile_mobile';

  SupabaseClient get _client => Supabase.instance.client;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<BootstrapState> bootstrap() async {
    final session = _client.auth.currentSession;
    final email = session?.user.email ?? await _storage.read(key: _lastEmailKey);
    if (session == null || email == null || email.isEmpty) {
      return const BootstrapState(
        hasSession: false,
        requiresPinUnlock: false,
        requiresPinSetup: false,
      );
    }
    final hasPin = await hasPinForEmail(email);
    return BootstrapState(
      hasSession: true,
      requiresPinUnlock: hasPin,
      requiresPinSetup: !hasPin,
      email: email,
    );
  }

  Future<void> rememberProfile({required String email, String? fullName, String? mobile}) async {
    await _storage.write(key: _lastEmailKey, value: email);
    if (fullName != null && fullName.isNotEmpty) {
      await _storage.write(key: _profileNameKey, value: fullName);
    }
    if (mobile != null && mobile.isNotEmpty) {
      await _storage.write(key: _profileMobileKey, value: mobile);
    }
  }

  Future<String?> rememberedEmail() => _storage.read(key: _lastEmailKey);
  Future<String?> rememberedName() => _storage.read(key: _profileNameKey);
  Future<String?> rememberedMobile() => _storage.read(key: _profileMobileKey);

  Future<bool> hasPinForEmail(String email) async {
    final pinReady = await _storage.read(key: _pinReadyKey);
    final storedEmail = await _storage.read(key: _pinEmailKey);
    final hash = await _storage.read(key: _pinHashKey);
    return pinReady == '1' && storedEmail == email.trim().toLowerCase() && hash != null && hash.isNotEmpty;
  }

  Future<void> setPin({required String email, required String pin}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final digest = sha256.convert(utf8.encode('$normalizedEmail::$pin::kenza')).toString();
    await _storage.write(key: _pinHashKey, value: digest);
    await _storage.write(key: _pinEmailKey, value: normalizedEmail);
    await _storage.write(key: _pinReadyKey, value: '1');
    await _storage.write(key: _lastEmailKey, value: normalizedEmail);
  }

  Future<bool> verifyPin({required String email, required String pin}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final storedEmail = await _storage.read(key: _pinEmailKey);
    final storedHash = await _storage.read(key: _pinHashKey);
    if (storedEmail != normalizedEmail || storedHash == null) return false;
    final digest = sha256.convert(utf8.encode('$normalizedEmail::$pin::kenza')).toString();
    return digest == storedHash;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinEmailKey);
    await _storage.delete(key: _pinReadyKey);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> signInWithPassword({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Login failed. Please try again.');
    }
    await _ensureProfileAfterAuth(
      email: user.email ?? email,
      userId: user.id,
      provider: 'email',
    );
  }

  Future<void> signUpWithPasswordOtp(PendingRegistration data) async {
    await _client.auth.signUp(
      email: data.email.trim(),
      password: data.password,
      data: {
        'full_name': data.fullName,
        'mobile': data.mobile,
      },
      emailRedirectTo: kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
    );
    await rememberProfile(email: data.email, fullName: data.fullName, mobile: data.mobile);
  }

  Future<void> resendSignupOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
      shouldCreateUser: false,
    );
  }

  Future<void> sendForgotPinOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
      shouldCreateUser: false,
    );
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
    required OtpFlow flow,
    PendingRegistration? registration,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: flow == OtpFlow.forgotPin ? OtpType.email : OtpType.email,
    );
    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw Exception('Verification failed. Please try again.');
    }
    if (flow == OtpFlow.signup) {
      await _ensureProfileAfterAuth(
        email: user.email ?? email,
        userId: user.id,
        fullName: registration?.fullName,
        mobile: registration?.mobile,
        provider: 'email',
      );
    } else {
      await rememberProfile(email: email);
    }
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
    );
  }

  Future<void> ensureProfile({
    required String userId,
    required String email,
    String? fullName,
    String? mobile,
  }) async {
    final supabase = Supabase.instance.client;

    final existing = await supabase
        .from('app_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('app_profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName ?? '',
        'mobile': mobile ?? '',
        'role': 'customer',
      });
    }
  }

  final user = Supabase.instance.client.auth.currentUser;

  if (user != null) {
    await ensureProfile(
      userId: user.id,
      email: user.email ?? '',
    );
  }

  Future<void> completeGoogleSignInIfNeeded() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _ensureProfileAfterAuth(
      email: user.email ?? '',
      userId: user.id,
      fullName: user.userMetadata?['full_name']?.toString() ?? user.userMetadata?['name']?.toString(),
      mobile: user.userMetadata?['mobile']?.toString(),
      provider: 'google',
    );
  }

  String? get currentUserEmail => _client.auth.currentUser?.email;

  Future<void> _ensureProfileAfterAuth({
    required String email,
    required String userId,
    String? fullName,
    String? mobile,
    required String provider,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _client.auth.currentUser;
    final finalName = fullName ?? user?.userMetadata?['full_name']?.toString() ?? user?.userMetadata?['name']?.toString() ?? '';
    final finalMobile = mobile ?? user?.userMetadata?['mobile']?.toString() ?? '';

    await _client.from('app_profiles').upsert({
      'id': userId,
      'full_name': finalName,
      'email': normalizedEmail,
      'mobile': finalMobile,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _syncWordPress(
      email: normalizedEmail,
      fullName: finalName,
      mobile: finalMobile,
      provider: provider,
      providerUserId: userId,
    );

    await rememberProfile(
      email: normalizedEmail,
      fullName: finalName,
      mobile: finalMobile,
    );
  }

  Future<void> _syncWordPress({
    required String email,
    required String fullName,
    required String mobile,
    required String provider,
    required String providerUserId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/supabase-sync');
    final response = await http.post(
      uri,
      headers: ApiConfig.headers(),
      body: jsonEncode({
        'email': email,
        'full_name': fullName,
        'mobile': mobile,
        'provider': provider,
        'provider_user_id': providerUserId,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = response.body;
      throw Exception(body.isNotEmpty ? body : 'WordPress sync failed');
    }
  }

}
