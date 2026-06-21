import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../shared/models/user_role.dart';

/// Clean abstraction for persisting user session between app restarts.
///
/// Uses [SharedPreferences] instead of flutter_secure_storage to avoid
/// platform-configuration issues on Android debug builds.
///
/// Only non-sensitive data (tokens, profile) is stored — no secrets
/// like database passwords, Supabase keys, or ID numbers.
class SessionStorage {
  static const _keySession = 'bus_session_v1';
  static const _keySelectedRole = 'bus_selected_role_v1';

  SessionStorage._();

  static Future<SessionStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionStorage._().._prefs = prefs;
  }

  late final SharedPreferences _prefs;

  // ---- full session ----

  /// Save the current user session to local storage.
  Future<void> saveSession(UserSession session) async {
    final json = session.toJson();
    await _prefs.setString(_keySession, jsonEncode(json));
  }

  /// Load a previously saved session, if any.
  UserSession? loadSession() {
    final raw = _prefs.getString(_keySession);
    if (raw == null) return null;
    try {
      return UserSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupted data — clear and return null.
      _prefs.remove(_keySession);
      return null;
    }
  }

  /// Clear all saved session data (used on sign-out).
  Future<void> clearSession() async {
    await _prefs.remove(_keySession);
    await _prefs.remove(_keySelectedRole);
  }

  // ---- selected role (multi-role users) ----

  Future<void> saveSelectedRole(UserRole role) async {
    await _prefs.setString(_keySelectedRole, role.claim);
  }

  UserRole? loadSelectedRole() {
    final raw = _prefs.getString(_keySelectedRole);
    if (raw == null) return null;
    return UserRole.fromClaim(raw);
  }
}
