import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage_config_provider.g.dart';

enum StorageType { local, filesystem, saf, webdav }

class StorageConfig {
  final StorageType type;
  final String? path; // for filesystem (Desktop)
  final String? safUri; // for saf (Android) — content:// URI as String
  // for webdav:
  final String? webdavUrl;
  final String? webdavUsername;
  final String? webdavPathPrefix;

  const StorageConfig({
    required this.type,
    this.path,
    this.safUri,
    this.webdavUrl,
    this.webdavUsername,
    this.webdavPathPrefix,
  });

  factory StorageConfig.fromJson(Map<String, dynamic> json) {
    return StorageConfig(
      type: StorageType.values.byName(json['type'] as String),
      path: json['path'] as String?,
      safUri: json['safUri'] as String?,
      webdavUrl: json['webdavUrl'] as String?,
      webdavUsername: json['webdavUsername'] as String?,
      webdavPathPrefix: json['webdavPathPrefix'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (path != null) 'path': path,
        if (safUri != null) 'safUri': safUri,
        if (webdavUrl != null) 'webdavUrl': webdavUrl,
        if (webdavUsername != null) 'webdavUsername': webdavUsername,
        if (webdavPathPrefix != null) 'webdavPathPrefix': webdavPathPrefix,
      };
}

@Riverpod(keepAlive: true)
class StorageConfigNotifier extends _$StorageConfigNotifier {
  static const _prefKey = 'storage_config';
  static const _legacyPathKey = 'storage_path';

  @override
  Future<StorageConfig> build() async {
    final prefs = await SharedPreferences.getInstance();

    // Migration from old storage_path key
    if (prefs.containsKey(_legacyPathKey)) {
      final legacy = prefs.getString(_legacyPathKey);
      final config = (legacy == null || legacy.isEmpty)
          ? const StorageConfig(type: StorageType.local)
          : StorageConfig(type: StorageType.filesystem, path: legacy);
      await prefs.setString(_prefKey, jsonEncode(config.toJson()));
      await prefs.remove(_legacyPathKey);
      return config;
    }

    final raw = prefs.getString(_prefKey);
    if (raw == null) return const StorageConfig(type: StorageType.local);
    return StorageConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> setConfig(StorageConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(config.toJson()));
    state = AsyncData(config);
  }
}
