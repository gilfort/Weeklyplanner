import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/google_drive_provider.dart';
import '../providers/storage_mode_provider.dart';
import '../providers/storage_path_provider.dart';
import '../repositories/google_drive_storage_backend.dart';
import '../theme.dart';
import '../widgets/drive_folder_picker_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _pathCtrl = TextEditingController();
  bool _saved = false;
  bool _initialized = false;
  String? _error;

  @override
  void dispose() {
    _pathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pathAsync = ref.watch(storagePathProvider);
    if (!_initialized) {
      pathAsync.whenData((value) {
        if (!_initialized) {
          _pathCtrl.text = value ?? '';
          _initialized = true;
        }
      });
    }

    final mode = ref.watch(currentStorageModeProvider).valueOrNull ??
        StorageMode.local;

    final driveAvailable = !kIsWeb && Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RuledPaperBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Speicherort',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (kIsWeb) ...[
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Im Browser werden Daten im lokalen Speicher '
                      '(localStorage) abgelegt. Google-Drive-Sync ist '
                      'nur in der nativen App verfügbar.',
                    ),
                  ),
                ],
              ),
            ] else ...[
              if (driveAvailable) _ModeSelector(mode: mode),
              const SizedBox(height: 20),
              if (mode == StorageMode.googleDrive && driveAvailable)
                const _GoogleDriveSection()
              else if (Platform.isAndroid)
                const _AndroidLocalInfo()
              else
                _LocalFolderSection(
                  pathCtrl: _pathCtrl,
                  initialized: _initialized,
                  error: _error,
                  saved: _saved,
                  onPick: _pickFolder,
                  onSave: _save,
                  onReset: _resetToDefault,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Speicherordner auswählen',
    );
    if (result != null && mounted) {
      setState(() {
        _pathCtrl.text = result;
        _error = null;
        _saved = false;
      });
    }
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _pathCtrl.clear();
      _error = null;
      _saved = false;
    });
    await ref.read(storagePathProvider.notifier).setPath(null);
    if (mounted) setState(() => _saved = true);
  }

  Future<void> _save() async {
    final path = _pathCtrl.text.trim();
    setState(() {
      _error = null;
      _saved = false;
    });

    if (path.isNotEmpty && !kIsWeb) {
      try {
        final dir = Directory(path);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final testFile = File('${dir.path}/.meal_planner_test');
        await testFile.writeAsString('ok');
        await testFile.delete();
      } catch (e) {
        if (mounted) {
          setState(() => _error =
              'Ordner konnte nicht erstellt/beschrieben werden: $e');
        }
        return;
      }
    }

    await ref
        .read(storagePathProvider.notifier)
        .setPath(path.isEmpty ? null : path);
    if (mounted) setState(() => _saved = true);
  }
}

class _ModeSelector extends ConsumerWidget {
  final StorageMode mode;
  const _ModeSelector({required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void select(StorageMode? v) {
      if (v == null || v == mode) return;
      ref.read(currentStorageModeProvider.notifier).setMode(v);
    }

    return RadioGroup<StorageMode>(
      groupValue: mode,
      onChanged: select,
      child: const Column(
        children: [
          RadioListTile<StorageMode>(
            value: StorageMode.local,
            secondary: Icon(Icons.folder),
            title: Text('Lokaler Ordner'),
            subtitle: Text('Daten auf diesem Gerät'),
          ),
          Divider(height: 1),
          RadioListTile<StorageMode>(
            value: StorageMode.googleDrive,
            secondary: Icon(Icons.cloud),
            title: Text('Google Drive'),
            subtitle: Text('Sync über Google-Konto'),
          ),
        ],
      ),
    );
  }
}

class _AndroidLocalInfo extends StatelessWidget {
  const _AndroidLocalInfo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Daten werden im internen App-Speicher abgelegt. '
                'Kein Sync zwischen Geräten.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Wenn du deine Rezepte und Wochenpläne zwischen Geräten teilen '
          'möchtest, wechsle oben auf „Google Drive".',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LocalFolderSection extends StatelessWidget {
  final TextEditingController pathCtrl;
  final bool initialized;
  final String? error;
  final bool saved;
  final VoidCallback onPick;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const _LocalFolderSection({
    required this.pathCtrl,
    required this.initialized,
    required this.error,
    required this.saved,
    required this.onPick,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wähle einen Ordner oder gib den Pfad manuell ein. '
          'Leer lassen für den Standard-App-Ordner.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: pathCtrl,
          enabled: initialized,
          decoration: InputDecoration(
            labelText: 'Ordnerpfad',
            hintText: '(Standard-App-Ordner)',
            suffixIcon: !initialized
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: 'Ordner auswählen',
                    onPressed: onPick,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save),
                label: const Text('Speichern'),
              ),
            ),
            if (pathCtrl.text.isNotEmpty) ...[
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: onReset,
                child: const Text('Zurücksetzen'),
              ),
            ],
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              ],
            ),
          ),
        if (saved)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pfad gespeichert. Alle Daten werden nun aus dem '
                    'neuen Ordner geladen.',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GoogleDriveSection extends ConsumerStatefulWidget {
  const _GoogleDriveSection();

  @override
  ConsumerState<_GoogleDriveSection> createState() =>
      _GoogleDriveSectionState();
}

class _GoogleDriveSectionState extends ConsumerState<_GoogleDriveSection> {
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Kick off the silent sign-in attempt as soon as the Drive section is
    // shown. Safe if already initialized (ensureInitialized is idempotent).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(signInProvider.notifier).ensureInitialized();
    });
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    GoogleSignInAccount? account;
    try {
      account = await ref.read(signInProvider.notifier).signIn();
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _humanizeSignInError(e);
      });
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Unerwarteter Fehler bei der Anmeldung: $e';
      });
      return;
    }

    if (!mounted) return;
    if (account == null) {
      setState(() {
        _busy = false;
        _error = 'Anmeldung abgebrochen.';
      });
      return;
    }

    // After sign-in, pick or create the MealPlanner folder automatically.
    try {
      final api =
          await ref.read(googleAuthServiceProvider).driveApi();
      final folder =
          await GoogleDriveStorageBackend.findOrCreateMealPlannerFolder(api);
      await ref
          .read(driveFolderProvider.notifier)
          .setFolder(folder.id!, folder.name ?? 'MealPlanner');
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Drive-Ordner konnte nicht eingerichtet '
            'werden: $e');
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  String _humanizeSignInError(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Anmeldung abgebrochen.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'OAuth-Client falsch konfiguriert. Prüfe in der Google '
            'Cloud Console: Package-Name = com.example.meal_planner, '
            'SHA-1 = Debug-Keystore-SHA1 (via ./gradlew signingReport). '
            'Original: ${e.description ?? e.code.name}';
      case GoogleSignInExceptionCode.interrupted:
        return 'Anmeldung unterbrochen (Netzwerk?). Bitte erneut versuchen.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google Play Services fehlen/veraltet. Bitte aktualisieren. '
            'Original: ${e.description ?? e.code.name}';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Android Credential Manager nicht verfügbar auf diesem Gerät.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Anderes Konto als zuvor angemeldet — bitte abmelden und '
            'erneut anmelden.';
      case GoogleSignInExceptionCode.unknownError:
        return 'Unbekannter Fehler: ${e.description ?? ""} '
            '(Code: ${e.code.name})';
    }
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    await ref.read(signInProvider.notifier).signOut();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _changeFolder() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = await ref.read(googleAuthServiceProvider).driveApi();
      if (!mounted) return;
      final picked = await DriveFolderPickerDialog.show(context, api: api);
      if (picked != null) {
        await ref
            .read(driveFolderProvider.notifier)
            .setFolder(picked.id, picked.name);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Fehler: $e');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(signInProvider);
    final folderAsync = ref.watch(driveFolderProvider);
    final theme = Theme.of(context);

    return accountAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text('Fehler: $e'),
      data: (account) {
        if (account == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Melde dich mit deinem Google-Konto an, um die App-Daten '
                'automatisch mit einem Drive-Ordner zu synchronisieren. '
                'Kein Passwort nötig – Android fragt dich einmal nach '
                'dem Konto.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: const Icon(Icons.login),
                label: const Text('Mit Google anmelden'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          );
        }

        final folder = folderAsync.valueOrNull;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Angemeldet als ${account.email}',
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.folder, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    folder == null
                        ? 'Kein Ordner ausgewählt'
                        : 'Sync-Ordner: ${folder.folderName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : _changeFolder,
                  child: const Text('Ändern'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Die App nutzt (oder legt an) einen Ordner „MealPlanner" auf '
              'deinem Drive. Bestehende Daten in diesem Ordner bleiben '
              'erhalten und werden beim nächsten Start geladen.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Abmelden'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: theme.colorScheme.error)),
            ],
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        );
      },
    );
  }
}
