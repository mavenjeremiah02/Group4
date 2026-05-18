import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/healthcare_models.dart';

class SessionService {
  static const _keepLoggedInKey = 'keep_me_logged_in';
  static const _previewRoleKey = 'preview_role';

  SharedPreferences? _prefs;
  bool? _available;

  Future<bool> get _isAvailable async {
    if (_available != null) {
      return _available!;
    }
    try {
      _prefs = await SharedPreferences.getInstance();
      _available = true;
    } on MissingPluginException catch (error) {
      _logUnavailable(error);
      _available = false;
    } on PlatformException catch (error) {
      _logUnavailable(error);
      _available = false;
    } catch (error) {
      _logUnavailable(error);
      _available = false;
    }
    return _available!;
  }

  Future<SharedPreferences?> _preferences() async {
    if (!await _isAvailable) {
      return null;
    }
    return _prefs ??= await SharedPreferences.getInstance();
  }

  void _logUnavailable(Object error) {
    if (kDebugMode) {
      debugPrint(
        'SessionService: shared_preferences unavailable ($error). '
        'Stop the app and run a full rebuild after adding the package.',
      );
    }
  }

  Future<bool> isKeepLoggedIn() async {
    final prefs = await _preferences();
    return prefs?.getBool(_keepLoggedInKey) ?? false;
  }

  Future<void> setKeepLoggedIn(bool value) async {
    final prefs = await _preferences();
    if (prefs == null) {
      return;
    }
    await prefs.setBool(_keepLoggedInKey, value);
    if (!value) {
      await prefs.remove(_previewRoleKey);
    }
  }

  Future<void> savePreviewRole(UserRole role) async {
    final prefs = await _preferences();
    if (prefs == null) {
      return;
    }
    await prefs.setString(_previewRoleKey, role.firestoreValue);
  }

  Future<void> clearPreviewRole() async {
    final prefs = await _preferences();
    if (prefs == null) {
      return;
    }
    await prefs.remove(_previewRoleKey);
  }

  Future<UserRole?> getPreviewRole() async {
    final prefs = await _preferences();
    final value = prefs?.getString(_previewRoleKey);
    if (value == null || value.isEmpty) {
      return null;
    }
    return UserRoleX.fromFirestoreValue(value);
  }

  Future<void> clear() async {
    final prefs = await _preferences();
    if (prefs == null) {
      return;
    }
    await prefs.remove(_keepLoggedInKey);
    await prefs.remove(_previewRoleKey);
  }
}
