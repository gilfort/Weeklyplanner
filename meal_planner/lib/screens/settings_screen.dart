import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/storage_path_provider.dart';
import '../theme.dart';

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
    // Populate controller once the async value arrives.
    final pathAsync = ref.watch(storagePathProvider);
    if (!_initialized) {
      pathAsync.whenData((value) {
        if (!_initialized) {
          _pathCtrl.text = value ?? '';
          _initialized = true;
        }
      });
    }

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
          const SizedBox(height: 4),
          if (kIsWeb) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 20,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Im Browser werden Daten im lokalen Speicher '
                    '(localStorage) abgelegt. Ein eigener Ordnerpfad '
                    'ist nur in der nativen App (Android/Windows/Linux) '
                    'möglich.',
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Wähle einen Ordner oder gib den Pfad manuell ein. '
              'Leer lassen für den Standard-App-Ordner.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pathCtrl,
              enabled: _initialized,
              decoration: InputDecoration(
                labelText: 'Ordnerpfad',
                hintText: '(Standard-App-Ordner)',
                suffixIcon: !_initialized
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
                        onPressed: _pickFolder,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Speichern'),
                  ),
                ),
                if (_pathCtrl.text.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _resetToDefault,
                    child: const Text('Zurücksetzen'),
                  ),
                ],
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                  ],
                ),
              ),
            if (_saved)
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
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Syncthing-Einrichtung',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const _SyncthingGuide(),
        ],
      ),
      ),
    );
  }

  Future<void> _pickFolder() async {
    // On Android, request permission first so the picker can access storage.
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() => _error =
              'Speicherberechtigung wurde verweigert. '
              'Bitte in den Android-Einstellungen erlauben.');
        }
        return;
      }
    }

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

    // Validate and create directory if a custom path is set (native only).
    if (path.isNotEmpty && !kIsWeb) {
      // On Android, request storage permission for external paths.
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          if (mounted) {
            setState(() => _error =
                'Speicherberechtigung wurde verweigert. '
                'Bitte in den Android-Einstellungen erlauben.');
          }
          return;
        }
      }

      try {
        final dir = Directory(path);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        // Quick write-test to verify we actually have access.
        final testFile = File('${dir.path}/.meal_planner_test');
        await testFile.writeAsString('ok');
        await testFile.delete();
      } catch (e) {
        if (mounted) {
          setState(() => _error = 'Ordner konnte nicht erstellt/beschrieben '
              'werden: $e');
        }
        return;
      }
    }

    await ref.read(storagePathProvider.notifier).setPath(
          path.isEmpty ? null : path,
        );
    if (mounted) setState(() => _saved = true);
  }
}

class _SyncthingGuide extends StatelessWidget {
  const _SyncthingGuide();

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Syncthing auf beiden Geräten installieren (F-Droid oder Play Store).',
      'Geräte koppeln: Einstellungen → Gerät hinzufügen → QR-Code scannen.',
      'Auf Gerät A einen Ordner anlegen, z.\u202fB. /storage/emulated/0/MealPlanner.',
      'Ordner in Syncthing freigeben: Ordner hinzufügen → Pfad eingeben → '
          'mit Gerät B teilen.',
      'Auf Gerät B den freigegebenen Ordner annehmen und denselben Pfad wählen.',
      'In dieser App unter Einstellungen den Ordnerpfad auf beiden Geräten '
          'auf denselben Syncthing-Ordner setzen.',
      'Konfliktstrategie: Syncthing erstellt bei Konflikten '
          '.sync-conflict-Dateien. Die App nutzt immer die neueste '
          'Hauptdatei — Konflikte manuell prüfen.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(child: Text(steps[i])),
              ],
            ),
          ),
      ],
    );
  }
}
