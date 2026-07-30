import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../config/google_drive_config.dart';

/// Wraps google_sign_in v7 (Credential Manager on Android) and exposes
/// a ready-to-use [drive.DriveApi] client for Google Drive operations.
class GoogleAuthService {
  static const List<String> _scopes = [drive.DriveApi.driveScope];

  GoogleSignInAccount? _currentAccount;
  bool _initialized = false;

  GoogleSignInAccount? get currentAccount => _currentAccount;
  bool get isSignedIn => _currentAccount != null;

  /// Initializes the SDK and attempts a silent sign-in if the user
  /// previously authenticated on this device. Throws [StateError] if the
  /// Web OAuth client ID has not been configured.
  Future<void> init() async {
    if (_initialized) return;
    if (kGoogleDriveServerClientId.isEmpty) {
      throw StateError(
        'Missing Web OAuth client ID. Create a "Web application" OAuth '
        'client in Google Cloud Console and set it in '
        'lib/config/google_drive_config.dart (or via --dart-define='
        'GOOGLE_DRIVE_SERVER_CLIENT_ID=...).',
      );
    }
    await GoogleSignIn.instance.initialize(
      serverClientId: kGoogleDriveServerClientId,
    );
    _initialized = true;
    try {
      _currentAccount =
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      debugPrint(
        'GoogleAuthService: lightweight auth result = '
        '${_currentAccount == null ? "null (no saved session)" : _currentAccount!.email}',
      );
    } on GoogleSignInException catch (e) {
      debugPrint(
        'GoogleAuthService: lightweight auth failed — '
        'code=${e.code} description=${e.description}',
      );
      _currentAccount = null;
    } catch (e) {
      debugPrint('GoogleAuthService: lightweight auth unexpected error: $e');
      _currentAccount = null;
    }
  }

  /// Interactive sign-in. Shows the Android Credential Manager bottom sheet.
  /// Throws [GoogleSignInException] on error — surfacing the code lets the
  /// UI tell the user whether this is a cancel, a config issue, or a network
  /// problem. Returns `null` only if the user explicitly cancels.
  Future<GoogleSignInAccount?> signIn() async {
    await init();
    try {
      _currentAccount =
          await GoogleSignIn.instance.authenticate(scopeHint: _scopes);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
    if (_currentAccount != null) {
      // Pre-authorize the Drive scope so subsequent API calls don't prompt.
      await _ensureAuthorization(_currentAccount!);
    }
    return _currentAccount;
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    _currentAccount = null;
  }

  Future<GoogleSignInClientAuthorization?> _ensureAuthorization(
    GoogleSignInAccount account,
  ) async {
    final client = account.authorizationClient;
    var authz = await client.authorizationForScopes(_scopes);
    authz ??= await client.authorizeScopes(_scopes);
    return authz;
  }

  /// Returns a [drive.DriveApi] with a freshly authorized access token.
  /// Throws if the user is not signed in or authorization fails.
  Future<drive.DriveApi> driveApi() async {
    final account = _currentAccount;
    if (account == null) {
      throw StateError('Not signed in to Google');
    }
    final authz = await _ensureAuthorization(account);
    if (authz == null) {
      throw StateError('Drive authorization was denied');
    }
    final headers = {
      'Authorization': 'Bearer ${authz.accessToken}',
      'X-Goog-AuthUser': '0',
    };
    return drive.DriveApi(_AuthClient(headers));
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
