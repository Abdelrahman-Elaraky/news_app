import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalAuthService {
  static const _userKey = 'users';
  static const _currentUserKey = 'current_user';
  static const _sessionExpiryKey = 'session_expiry';
  static const _lastActivityKey = 'last_activity';
  static const _rememberMeKey = 'remember_me';

  final Uuid _uuid = const Uuid();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  String _generateSalt() => _uuid.v4();

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    final prefs = await _prefs;
    final users = await _getUsers(prefs);

    if (users.any((user) => user['email'] == userData['email'])) {
      return false;
    }

    final salt = _generateSalt();
    final hashedPassword = _hashPassword(userData['password'], salt);

    userData['id'] = _uuid.v4();
    userData['password'] = hashedPassword;
    userData['salt'] = salt;

    users.add(userData);
    await prefs.setString(_userKey, jsonEncode(users));
    return true;
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    final prefs = await _prefs;
    final users = await _getUsers(prefs);

    final user = users.firstWhere(
      (u) => u['email'] == email,
      orElse: () => {},
    );

    if (user.isEmpty) return false;

    final salt = user['salt'] ?? '';
    final hashedPassword = _hashPassword(password, salt);

    if (user['password'] != hashedPassword) return false;

    // Save current user session
    await prefs.setString(_currentUserKey, jsonEncode(user));

    // Set session expiry to 24 hours from now
    final expiryTimestamp = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    await prefs.setInt(_sessionExpiryKey, expiryTimestamp);

    // Save last activity timestamp as now
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);

    // Save rememberMe flag
    await prefs.setBool(_rememberMeKey, rememberMe);

    return true;
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_currentUserKey);
    await prefs.remove(_sessionExpiryKey);
    await prefs.remove(_lastActivityKey);
    await prefs.remove(_rememberMeKey);
  }

  Future<bool> isUserExists(String email) async {
    final prefs = await _prefs;
    final users = await _getUsers(prefs);
    return users.any((user) => user['email'] == email);
  }

  Future<bool> updateProfile(Map<String, dynamic> newUserData) async {
    final prefs = await _prefs;
    final users = await _getUsers(prefs);
    final currentUser = await _getCurrentUser(prefs);

    if (currentUser == null) return false;

    final index = users.indexWhere((u) => u['id'] == currentUser['id']);
    if (index == -1) return false;

    newUserData['id'] = currentUser['id'];
    newUserData['password'] = currentUser['password'];
    newUserData['salt'] = currentUser['salt'];

    users[index] = newUserData;

    await prefs.setString(_userKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, jsonEncode(newUserData));
    return true;
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    final prefs = await _prefs;
    final users = await _getUsers(prefs);
    final currentUser = await _getCurrentUser(prefs);

    if (currentUser == null) return false;

    final index = users.indexWhere((u) => u['id'] == currentUser['id']);
    if (index == -1) return false;

    final salt = currentUser['salt'] ?? '';

    if (_hashPassword(oldPass, salt) != currentUser['password']) return false;

    final newHashedPassword = _hashPassword(newPass, salt);
    users[index]['password'] = newHashedPassword;

    await prefs.setString(_userKey, jsonEncode(users));

    currentUser['password'] = newHashedPassword;
    await prefs.setString(_currentUserKey, jsonEncode(currentUser));

    return true;
  }

  Future<List<Map<String, dynamic>>> _getUsers(SharedPreferences prefs) async {
    final jsonString = prefs.getString(_userKey);
    if (jsonString == null) return [];
    final decoded = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  Future<Map<String, dynamic>?> _getCurrentUser(SharedPreferences prefs) async {
    final jsonString = prefs.getString(_currentUserKey);
    if (jsonString == null) return null;
    final decoded = json.decode(jsonString);
    return Map<String, dynamic>.from(decoded);
  }

  /// Public method to get the current logged-in user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await _prefs;
    return _getCurrentUser(prefs);
  }

  /// Checks if the session is still valid (not expired and last activity within timeout)
  Future<bool> isSessionValid() async {
    final prefs = await _prefs;
    final expiry = prefs.getInt(_sessionExpiryKey);
    final lastActivity = prefs.getInt(_lastActivityKey);

    if (expiry == null || lastActivity == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > expiry) return false;

    // Optional: If you want to expire session based on inactivity (e.g., 30 mins)
    // final inactivityTimeout = Duration(minutes: 30).inMilliseconds;
    // if (now - lastActivity > inactivityTimeout) return false;

    return true;
  }

  /// Update last activity timestamp to current time
  Future<void> updateLastActivity() async {
    final prefs = await _prefs;
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if "Remember Me" was enabled at login
  Future<bool> isRememberMe() async {
    final prefs = await _prefs;
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}
