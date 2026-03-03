import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_to_go/core/network/dio_provider.dart';
import 'package:good_to_go/shared/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

class AuthRepository {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '614878332012-o8makqc18vkkflg5e8od71q09d6lm3q1.apps.googleusercontent.com',
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  AuthRepository(this._dio);

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      // print('Debug: Google Sign-In successful. User: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // print('Debug: Access Token: ${googleAuth.accessToken}');
      // print('Debug: ID Token: ${googleAuth.idToken}');

      final String? tokenToSend = googleAuth.idToken ?? googleAuth.accessToken;

      if (tokenToSend == null) {
        throw Exception('Google Sign-In failed: No ID Token or Access Token');
      }

      final response = await _dio.post(
        'auth/google',
        data: {'token': tokenToSend},
      );

      final token = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await _storage.write(key: 'access_token', value: token);
      await _storage.write(key: 'refresh_token', value: refreshToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {
          'username': email, // OAuth2PasswordRequestForm uses username
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final token = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await _storage.write(key: 'access_token', value: token);
      await _storage.write(key: 'refresh_token', value: refreshToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await _dio.post(
        'auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': 'renter', // Default for now
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return null;

      final response = await _dio.get(
        'auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
