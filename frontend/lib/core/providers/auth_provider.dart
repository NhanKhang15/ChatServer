import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../constants.dart';
import 'api_client.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final apiClient = ref.watch(apiClientProvider);
    _apiClient = apiClient;
    _initializeAuth();
    return AuthState();
  }

  late ApiClient _apiClient;

  Future<void> _initializeAuth() async {
    final token = await _apiClient.getToken();
    if (token != null) {
      try {
        final response = await _apiClient.dio.get(AppConstants.meEndpoint);
        final user = User.fromJson(response.data);
        state = AuthState(
          user: user,
          token: token,
          isAuthenticated: true,
        );
      } catch (e) {
        await _apiClient.removeToken();
        state = AuthState();
      }
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.post(
        AppConstants.registerEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      final user = User.fromJson(response.data['user']);

      await _apiClient.saveToken(token);

      state = AuthState(
        user: user,
        token: token,
        isAuthenticated: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['error'] ?? 'Registration failed',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      final token = response.data['token'];
      final user = User.fromJson(response.data['user']);

      await _apiClient.saveToken(token);

      state = AuthState(
        user: user,
        token: token,
        isAuthenticated: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['error'] ?? 'Login failed',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> logout() async {
    await _apiClient.removeToken();
    state = AuthState();
  }
}
