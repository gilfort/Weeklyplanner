// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_drive_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$googleAuthServiceHash() => r'bfcbe7d49fa5bee0cf2c57a47adf2c47de990511';

/// Singleton [GoogleAuthService] — holds the current signed-in account.
///
/// Copied from [googleAuthService].
@ProviderFor(googleAuthService)
final googleAuthServiceProvider = Provider<GoogleAuthService>.internal(
  googleAuthService,
  name: r'googleAuthServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$googleAuthServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoogleAuthServiceRef = ProviderRef<GoogleAuthService>;
String _$driveFolderHash() => r'8dc832b8b6a1f6363832a7bd9c258079dd7ab1f0';

/// See also [DriveFolder].
@ProviderFor(DriveFolder)
final driveFolderProvider =
    AsyncNotifierProvider<DriveFolder, DriveFolderConfig?>.internal(
      DriveFolder.new,
      name: r'driveFolderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$driveFolderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DriveFolder = AsyncNotifier<DriveFolderConfig?>;
String _$signInHash() => r'593a2450a7ce0df0ecef1c07b925e78df7d54b12';

/// Current Google sign-in state.  `null` → not signed in.
///
/// `build()` is intentionally idle — it does NOT touch the Google SDK. This
/// keeps `GoogleSignIn.instance.initialize()` and the Credential-Manager
/// lightweight-auth out of app startup unless the user has opted into Drive.
/// Callers must invoke [ensureInitialized] (typically from the
/// `storageBackend` provider or the Drive settings section) to kick off the
/// silent sign-in attempt.
///
/// Copied from [SignIn].
@ProviderFor(SignIn)
final signInProvider =
    AsyncNotifierProvider<SignIn, GoogleSignInAccount?>.internal(
      SignIn.new,
      name: r'signInProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signInHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignIn = AsyncNotifier<GoogleSignInAccount?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
