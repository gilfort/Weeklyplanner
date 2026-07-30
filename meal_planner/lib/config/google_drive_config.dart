/// Web OAuth 2.0 Client ID used as Credential Manager audience on Android.
///
/// ⚠️ MUST be a **Web application** OAuth client in Google Cloud Console
/// (NOT Android). The Android OAuth client is still required in parallel for
/// SHA-1 / package-name verification, but Credential Manager needs the Web
/// client ID to exchange tokens.
///
/// To create it:
///   console.cloud.google.com → APIs & Services → Credentials
///   → Create Credentials → OAuth client ID
///   → Application type: "Web application"
///   → copy the Client ID (format: `<digits>-<hash>.apps.googleusercontent.com`)
///
/// Paste it below, or pass it at build time via
///   flutter run --dart-define=GOOGLE_DRIVE_SERVER_CLIENT_ID=`<id>`
const String kGoogleDriveServerClientId = String.fromEnvironment(
  'GOOGLE_DRIVE_SERVER_CLIENT_ID',
  defaultValue: '363144090383-ae79qhp5vhn8d78a67ma52o6n6lmr9u9.apps.googleusercontent.com',
);
