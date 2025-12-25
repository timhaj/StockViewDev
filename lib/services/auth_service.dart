import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static const String _usersBoxName = 'users';
  static const String _currentUserKey = 'currentUser';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(_usersBoxName);
  }

  // Get users box
  static Box<User> get _usersBox => Hive.box<User>(_usersBoxName);

  // Hash password
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  static Future<bool> register(String name, String email, String password) async {
    try {
      // Check if user already exists
      if (_usersBox.values.any((user) => user.email == email)) {
        return false; // User already exists
      }

      final user = User(
        name: name,
        email: email,
        passwordHash: _hashPassword(password),
      );

      await _usersBox.add(user);
      await _setCurrentUser(email);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Login user
  static Future<bool> login(String email, String password) async {
    try {
      final passwordHash = _hashPassword(password);
      final user = _usersBox.values.firstWhere(
        (user) => user.email == email && user.passwordHash == passwordHash,
        orElse: () => throw Exception('User not found'),
      );

      await _setCurrentUser(email);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout user
  static Future<void> logout() async {
    final box = await Hive.openBox('session');
    await box.delete(_currentUserKey);
  }

  // Get current logged-in user
  static Future<User?> getCurrentUser() async {
    try {
      final box = await Hive.openBox('session');
      final email = box.get(_currentUserKey);
      if (email == null) return null;

      return _usersBox.values.firstWhere(
        (user) => user.email == email,
        orElse: () => throw Exception('User not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Set current user (for session)
  static Future<void> _setCurrentUser(String email) async {
    final box = await Hive.openBox('session');
    await box.put(_currentUserKey, email);
  }

  // Add stock to watchlist
  static Future<void> addToWatchlist(String ticker) async {
    final user = await getCurrentUser();
    if (user != null) {
      user.addToWatchlist(ticker);
    }
  }

  // Remove stock from watchlist
  static Future<void> removeFromWatchlist(String ticker) async {
    final user = await getCurrentUser();
    if (user != null) {
      user.removeFromWatchlist(ticker);
    }
  }

  // Check if stock is in watchlist
  static Future<bool> isInWatchlist(String ticker) async {
    final user = await getCurrentUser();
    return user?.isInWatchlist(ticker) ?? false;
  }

  // Get user's watchlist
  static Future<List<String>> getWatchlist() async {
    final user = await getCurrentUser();
    return user?.watchlist ?? [];
  }
}