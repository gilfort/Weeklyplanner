import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:webdav_client/webdav_client.dart' as webdav;

import 'storage_backend.dart';

/// Thrown for WebDAV-specific failures (auth, network, server errors).
class WebDavException implements Exception {
  final String message;
  final int? statusCode;
  WebDavException(this.message, {this.statusCode});

  @override
  String toString() =>
      'WebDavException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

/// Storage backend backed by a WebDAV server.
///
/// Compatible with: OneDrive (`https://d.docs.live.net/<CID>/`),
/// Nextcloud (`https://<host>/remote.php/dav/files/<user>/`),
/// self-hosted Filen WebDAV server, and any RFC 4918 compliant server.
class WebDavStorageBackend extends SyncableStorageBackend {
  final String baseUrl;
  final String username;
  final String password;
  final String pathPrefix;

  late final webdav.Client _client;
  bool _prefixEnsured = false;

  WebDavStorageBackend({
    required this.baseUrl,
    required this.username,
    required this.password,
    this.pathPrefix = '/MealPlanner',
  }) {
    _client = webdav.newClient(
      baseUrl,
      user: username,
      password: password,
      debug: false,
    );
    _client.setHeaders({'accept-charset': 'utf-8'});
    _client.setConnectTimeout(10000);
    _client.setSendTimeout(15000);
    _client.setReceiveTimeout(15000);
  }

  String _path(String key) {
    final prefix = pathPrefix.endsWith('/')
        ? pathPrefix.substring(0, pathPrefix.length - 1)
        : pathPrefix;
    final cleanKey = key.startsWith('/') ? key.substring(1) : key;
    return '$prefix/$cleanKey';
  }

  Future<void> _ensurePrefix() async {
    if (_prefixEnsured) return;
    try {
      await _client.mkdirAll(pathPrefix);
    } catch (_) {
      // Folder may already exist; mkdirAll on existing folder may throw
      // depending on server. Best-effort: subsequent ops will surface real errors.
    }
    _prefixEnsured = true;
  }

  /// Tests the connection and credentials. Throws [WebDavException] on failure.
  Future<void> ping() async {
    await _wrap(() => _client.ping(), 'Ping');
  }

  @override
  Future<String?> read(String key) async {
    return _wrap<String?>(() async {
      try {
        final bytes = await _client.read(_path(key));
        if (bytes.isEmpty) return null;
        return utf8.decode(bytes);
      } catch (e) {
        if (_isNotFound(e)) return null;
        rethrow;
      }
    }, 'Read $key');
  }

  @override
  Future<void> write(String key, String value) async {
    await _ensurePrefix();
    await _wrap(() async {
      final data = Uint8List.fromList(utf8.encode(value));
      await _client.write(_path(key), data);
    }, 'Write $key');
  }

  @override
  Future<List<String>> listKeys() async {
    return _wrap<List<String>>(() async {
      try {
        final entries = await _client.readDir(pathPrefix);
        return entries
            .where((f) => f.isDir != true)
            .map((f) => f.name ?? '')
            .where((n) => n.endsWith('.json') && !n.endsWith('.backup'))
            .toList();
      } catch (e) {
        if (_isNotFound(e)) return <String>[];
        rethrow;
      }
    }, 'List');
  }

  @override
  Future<DateTime?> getLastModified(String key) async {
    return _wrap<DateTime?>(() async {
      try {
        final props = await _client.readProps(_path(key));
        return props.mTime;
      } catch (e) {
        if (_isNotFound(e)) return null;
        rethrow;
      }
    }, 'Stat $key');
  }

  /// Wraps a WebDAV operation, normalising network/auth errors to
  /// [WebDavException] with a recognisable message.
  Future<T> _wrap<T>(Future<T> Function() op, String label) async {
    try {
      return await op();
    } on WebDavException {
      rethrow;
    } on SocketException catch (e) {
      throw WebDavException('Netzwerkfehler ($label): ${e.message}');
    } catch (e) {
      final code = _extractStatusCode(e);
      if (code == 401 || code == 403) {
        throw WebDavException('Authentifizierung fehlgeschlagen ($label)',
            statusCode: code);
      }
      throw WebDavException('$label fehlgeschlagen: $e', statusCode: code);
    }
  }

  bool _isNotFound(Object e) => _extractStatusCode(e) == 404;

  /// Best-effort extraction of HTTP status code from a thrown error.
  /// webdav_client wraps dio exceptions; their string form contains
  /// `statusCode:` or `[<code>]`.
  int? _extractStatusCode(Object e) {
    final s = e.toString();
    final patterns = <RegExp>[
      RegExp(r'statusCode[: ]+(\d{3})'),
      RegExp(r'\[(\d{3})\]'),
      RegExp(r'HTTP (\d{3})'),
      RegExp(r'(\d{3})\s'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(s);
      if (m != null) {
        final code = int.tryParse(m.group(1)!);
        if (code != null && code >= 100 && code < 600) return code;
      }
    }
    return null;
  }
}
