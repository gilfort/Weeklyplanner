import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/repository_providers.dart';
import '../providers/storage_config_provider.dart';
import '../repositories/saf_storage_backend.dart';
import '../theme.dart';
import '../widgets/sync_status_icon.dart';
import '../widgets/webdav_config_form.dart';

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
    final configAsync = ref.watch(storageConfigNotifierProvider);
    if (!_initialized) {
      configAsync.whenData((config) {
        if (!_initialized) {
          _pathCtrl.text = config.path ?? '';
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
        actions: const [SyncStatusIcon()],
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
                  Icon(Icons.info_outline,
                      size: 20,
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
            ] else if (!kIsWeb && Platform.isAndroid) ...[
              _buildAndroidStorageSection(configAsync.valueOrNull),
              const SizedBox(height: 24),
              _buildWebDavStorageSection(configAsync.valueOrNull),
            ] else ...[
              _buildDesktopStorageSection(),
              const SizedBox(height: 24),
              _buildWebDavStorageSection(configAsync.valueOrNull),
            ],
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
                        'Gespeichert. Daten werden nun aus dem neuen Ordner geladen.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidStorageSection(StorageConfig? current) {
    final isSaf = current?.type == StorageType.saf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSaf
              ? 'Aktuell: Cloud-Ordner (${current!.safUri})'
              : 'Aktuell: Lokaler App-Ordner (Standard)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _changeSafFolder(current),
          icon: const Icon(Icons.cloud_outlined),
          label: const Text('Cloud-Ordner wählen'),
        ),
        const SizedBox(height: 8),
        if (isSaf)
          OutlinedButton(
            onPressed: () => _confirmAndSetConfig(
              const StorageConfig(type: StorageType.local),
            ),
            child: const Text('Auf lokalen Speicher wechseln'),
          ),
      ],
    );
  }

  Widget _buildWebDavStorageSection(StorageConfig? current) {
    final isWebDav = current?.type == StorageType.webdav;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WebDAV',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        if (isWebDav)
          Text(
            'Aktuell: ${current!.webdavUrl} (${current.webdavUsername})',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Text(
            'OneDrive, Nextcloud oder selbst gehosteten WebDAV-Server '
            'verbinden.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _configureWebDav(current),
          icon: const Icon(Icons.cloud_sync_outlined),
          label: Text(isWebDav ? 'WebDAV bearbeiten' : 'WebDAV einrichten'),
        ),
        if (isWebDav) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _switchAwayFromWebDav(current!),
            child: const Text('Auf lokalen Speicher wechseln'),
          ),
        ],
      ],
    );
  }

  Future<void> _configureWebDav(StorageConfig? current) async {
    setState(() {
      _error = null;
      _saved = false;
    });
    final isEditing = current?.type == StorageType.webdav;
    final initialPassword = isEditing
        ? await ref
            .read(webdavCredentialsServiceProvider)
            .read(current!)
        : null;
    if (!mounted) return;
    final result = await showModalBottomSheet<WebDavFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: WebDavConfigForm(
          initial: isEditing ? current : null,
          initialPassword: initialPassword,
          submitLabel: 'Speichern',
          onSubmit: (r) => Navigator.of(ctx).pop(r),
        ),
      ),
    );
    if (result == null || !mounted) return;

    final confirmed = isEditing ? true : await _showChangeWarningDialog();
    if (!confirmed) return;

    final svc = ref.read(webdavCredentialsServiceProvider);
    // Old credential cleanup if URL/username changed.
    if (isEditing &&
        (current!.webdavUrl != result.config.webdavUrl ||
            current.webdavUsername != result.config.webdavUsername)) {
      await svc.delete(current);
    }
    await svc.save(result.config, result.password);
    await _setConfig(result.config);
  }

  Future<void> _switchAwayFromWebDav(StorageConfig oldConfig) async {
    final confirmed = await _showChangeWarningDialog();
    if (!confirmed) return;
    await ref.read(webdavCredentialsServiceProvider).delete(oldConfig);
    await _setConfig(const StorageConfig(type: StorageType.local));
  }

  Widget _buildDesktopStorageSection() {
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
                    onPressed: _pickDesktopFolder,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _saveDesktopPath,
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
      ],
    );
  }

  Future<void> _changeSafFolder(StorageConfig? current) async {
    setState(() => _error = null);
    final confirmed = await _showChangeWarningDialog();
    if (!confirmed) return;

    try {
      final uri = await SafStorageBackend.openDocumentTree();
      if (uri != null && mounted) {
        await _setConfig(StorageConfig(
          type: StorageType.saf,
          safUri: uri,
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Ordner konnte nicht geöffnet werden: $e');
    }
  }

  Future<void> _pickDesktopFolder() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Speicherordner auswählen',
    );
    if (result != null && mounted) {
      setState(() {
        _pathCtrl.text = result;
        _saved = false;
      });
    }
  }

  Future<void> _saveDesktopPath() async {
    final path = _pathCtrl.text.trim();
    setState(() {
      _error = null;
      _saved = false;
    });

    if (path.isNotEmpty) {
      final confirmed = await _showChangeWarningDialog();
      if (!confirmed) return;

      try {
        final dir = Directory(path);
        if (!await dir.exists()) await dir.create(recursive: true);
        final testFile = File('${dir.path}/.meal_planner_test');
        await testFile.writeAsString('ok');
        await testFile.delete();
      } catch (e) {
        if (mounted) {
          setState(() => _error = 'Ordner konnte nicht erstellt/beschrieben werden: $e');
        }
        return;
      }
    }

    await _setConfig(path.isEmpty
        ? const StorageConfig(type: StorageType.local)
        : StorageConfig(type: StorageType.filesystem, path: path));
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _pathCtrl.clear();
      _error = null;
      _saved = false;
    });
    await _setConfig(const StorageConfig(type: StorageType.local));
  }

  Future<void> _confirmAndSetConfig(StorageConfig config) async {
    final confirmed = await _showChangeWarningDialog();
    if (!confirmed) return;
    await _setConfig(config);
  }

  Future<void> _setConfig(StorageConfig config) async {
    await ref.read(storageConfigNotifierProvider.notifier).setConfig(config);
    if (mounted) setState(() => _saved = true);
  }

  /// Shows a dialog warning the user that data won't be copied.
  /// Returns true if the user confirms.
  Future<bool> _showChangeWarningDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Speicherort wechseln?'),
        content: const Text(
          'Daten im alten Ordner bleiben erhalten, werden aber nicht in den '
          'neuen Ordner kopiert. Die App lädt Daten aus dem neuen Ordner.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Wechseln'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
