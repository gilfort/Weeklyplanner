import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as drive;

import '../services/google_auth_service.dart';
import 'storage_backend.dart';

/// Storage backend that reads/writes JSON files inside a single
/// user-chosen Google Drive folder, using the `drive` OAuth scope.
class GoogleDriveStorageBackend implements StorageBackend {
  final GoogleAuthService auth;
  final String folderId;

  GoogleDriveStorageBackend({required this.auth, required this.folderId});

  static String _escapeQ(String s) => s.replaceAll("'", r"\'");

  Future<String?> _findFileId(drive.DriveApi api, String key) async {
    final res = await api.files.list(
      q: "'$folderId' in parents and name = '${_escapeQ(key)}' "
          "and trashed = false",
      $fields: 'files(id)',
      spaces: 'drive',
      pageSize: 1,
    );
    final files = res.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }

  @override
  Future<String?> read(String key) async {
    final api = await auth.driveApi();
    final fileId = await _findFileId(api, key);
    if (fileId == null) return null;
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    final content = utf8.decode(bytes);
    return content.trim().isEmpty ? null : content;
  }

  @override
  Future<void> write(String key, String value) async {
    final api = await auth.driveApi();
    final bytes = utf8.encode(value);
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: 'application/json',
    );
    final existing = await _findFileId(api, key);
    if (existing == null) {
      await api.files.create(
        drive.File()
          ..name = key
          ..parents = [folderId]
          ..mimeType = 'application/json',
        uploadMedia: media,
      );
    } else {
      await api.files.update(
        drive.File(),
        existing,
        uploadMedia: media,
      );
    }
  }

  // ---- Static helpers used by the folder picker and initial setup. ----

  /// Lists subfolders inside [parentId] (default: `'root'` = My Drive root).
  static Future<List<drive.File>> listFolders({
    required drive.DriveApi api,
    String parentId = 'root',
  }) async {
    final folders = <drive.File>[];
    String? pageToken;
    do {
      final res = await api.files.list(
        q: "mimeType = 'application/vnd.google-apps.folder' and "
            "'$parentId' in parents and trashed = false",
        $fields: 'nextPageToken,files(id,name)',
        spaces: 'drive',
        orderBy: 'name',
        pageSize: 100,
        pageToken: pageToken,
      );
      folders.addAll(res.files ?? const []);
      pageToken = res.nextPageToken;
    } while (pageToken != null);
    return folders;
  }

  /// Returns the first folder matching [name] at `'root'`, or null.
  static Future<drive.File?> findFolderByNameAtRoot({
    required drive.DriveApi api,
    required String name,
  }) async {
    final res = await api.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and "
          "name = '${_escapeQ(name)}' and 'root' in parents "
          "and trashed = false",
      $fields: 'files(id,name)',
      spaces: 'drive',
      pageSize: 1,
    );
    final files = res.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  /// Creates a new folder. Returns the created file (id + name populated).
  static Future<drive.File> createFolder({
    required drive.DriveApi api,
    required String name,
    String parentId = 'root',
  }) async {
    final file = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [parentId];
    return api.files.create(file);
  }

  /// Finds or creates a `MealPlanner` folder at the Drive root.
  /// Honours the user's request: if one already exists, re-use it.
  static Future<drive.File> findOrCreateMealPlannerFolder(
    drive.DriveApi api,
  ) async {
    final existing = await findFolderByNameAtRoot(api: api, name: 'MealPlanner');
    if (existing != null) return existing;
    return createFolder(api: api, name: 'MealPlanner');
  }
}
