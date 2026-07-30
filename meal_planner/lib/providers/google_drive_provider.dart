import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/google_auth_service.dart';

part 'google_drive_provider.g.dart';

/// Singleton [GoogleAuthService] — holds the current signed-in account.
@Riverpod(keepAlive: true)
GoogleAuthService googleAuthService(GoogleAuthServiceRef ref) {
  return GoogleAuthService();
}

/// The chosen Drive folder used as the sync target.
class DriveFolderConfig {
  final String folderId;
  final String folderName;
  const DriveFolderConfig({required this.folderId, required this.folderName});
}

@Riverpod(keepAlive: true)
class DriveFolder extends _$DriveFolder {
  static const _idKey = 'drive_folder_id';
  static const _nameKey = 'drive_folder_name';

  @override
  Future<DriveFolderConfig?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_idKey);
    final name = prefs.getString(_nameKey);
    if (id == null || name == null) return null;
    return DriveFolderConfig(folderId: id, folderName: name);
  }

  Future<void> setFolder(String folderId, String folderName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKey, folderId);
    await prefs.setString(_nameKey, folderName);
    state =
        AsyncData(DriveFolderConfig(folderId: folderId, folderName: folderName));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idKey);
    await prefs.remove(_nameKey);
    state = const AsyncData(null);
  }
}

/// Current Google sign-in state.  `null` → not signed in.
///
/// `build()` is intentionally idle — it does NOT touch the Google SDK. This
/// keeps `GoogleSignIn.instance.initialize()` and the Credential-Manager
/// lightweight-auth out of app startup unless the user has opted into Drive.
/// Callers must invoke [ensureInitialized] (typically from the
/// `storageBackend` provider or the Drive settings section) to kick off the
/// silent sign-in attempt.
@Riverpod(keepAlive: true)
class SignIn extends _$SignIn {
  bool _initStarted = false;

  @override
  Future<GoogleSignInAccount?> build() async {
    // No Google SDK access here — return null until ensureInitialized() runs.
    return null;
  }

  /// Initializes the Google SDK and attempts a silent (lightweight) sign-in.
  /// Idempotent: calling multiple times is safe; only the first call does work.
  Future<void> ensureInitialized() async {
    if (_initStarted) return;
    _initStarted = true;
    final svc = ref.read(googleAuthServiceProvider);
    try {
      await svc.init();
      state = AsyncData(svc.currentAccount);
    } catch (e, st) {
      _initStarted = false; // allow retry on next trigger
      state = AsyncError(e, st);
    }
  }

  /// Returns the signed-in account or throws to let the UI display the error.
  Future<GoogleSignInAccount?> signIn() async {
    state = const AsyncLoading();
    final svc = ref.read(googleAuthServiceProvider);
    try {
      final account = await svc.signIn();
      _initStarted = true;
      state = AsyncData(account);
      return account;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    final svc = ref.read(googleAuthServiceProvider);
    await svc.signOut();
    // Forget the persisted folder too — it belonged to that account.
    await ref.read(driveFolderProvider.notifier).clear();
    state = const AsyncData(null);
  }
}
