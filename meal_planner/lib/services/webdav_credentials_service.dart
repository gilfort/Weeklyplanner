import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../providers/storage_config_provider.dart';

/// Stores WebDAV passwords in Android Keystore-backed secure storage.
///
/// Key derivation: `webdav_pw_${sha256(url + '|' + username)[0..16]}`.
/// Stable across pathPrefix changes; rotates if URL or username changes
/// (so an old credential becomes orphaned — callers should `delete` the
/// previous config before saving a new one).
class WebDavCredentialsService {
  static const _prefix = 'webdav_pw_';

  final FlutterSecureStorage _storage;

  WebDavCredentialsService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  String _keyFor(String url, String username) {
    final digest = sha256.convert(utf8.encode('$url|$username'));
    return '$_prefix${digest.toString().substring(0, 16)}';
  }

  String? _keyForConfig(StorageConfig config) {
    final url = config.webdavUrl;
    final user = config.webdavUsername;
    if (url == null || user == null) return null;
    return _keyFor(url, user);
  }

  Future<void> save(StorageConfig config, String password) async {
    final key = _keyForConfig(config);
    if (key == null) {
      throw ArgumentError('StorageConfig missing webdavUrl/webdavUsername');
    }
    await _storage.write(key: key, value: password);
  }

  Future<String?> read(StorageConfig config) async {
    final key = _keyForConfig(config);
    if (key == null) return null;
    return _storage.read(key: key);
  }

  Future<void> delete(StorageConfig config) async {
    final key = _keyForConfig(config);
    if (key == null) return;
    await _storage.delete(key: key);
  }
}
