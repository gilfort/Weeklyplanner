import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/repository_providers.dart';
import '../providers/storage_config_provider.dart';
import '../repositories/saf_storage_backend.dart';
import '../theme.dart';
import '../widgets/webdav_config_form.dart';

/// Shown once on first launch to let the user pick a storage folder.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  String? _selectedPath; // Desktop: file-system path
  Uri? _selectedSafUri; // Android: SAF tree URI
  StorageConfig? _selectedWebDav; // WebDAV config (password held separately)
  String? _selectedWebDavPassword;
  String? _error;

  bool get _hasSelection =>
      _selectedPath != null ||
      _selectedSafUri != null ||
      _selectedWebDav != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 72, color: PaperTheme.ink),
                  const SizedBox(height: 16),
                  Text(
                    'Willkommen!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wo sollen deine Rezepte und Pläne\ngespeichert werden?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (!kIsWeb) ...[
                    if (!kIsWeb && Platform.isAndroid) ...[
                      FilledButton.icon(
                        onPressed: _pickSafFolder,
                        icon: const Icon(Icons.cloud_outlined),
                        label: const Text('Cloud-Ordner wählen'),
                      ),
                    ] else ...[
                      FilledButton.icon(
                        onPressed: _pickFolder,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Ordner auswählen'),
                      ),
                    ],
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _configureWebDav,
                      icon: const Icon(Icons.cloud_sync_outlined),
                      label: const Text('WebDAV einrichten'),
                    ),
                    if (_hasSelection) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: PaperTheme.ruled),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _selectedWebDav != null
                                  ? Icons.cloud_sync_outlined
                                  : _selectedSafUri != null
                                      ? Icons.cloud_done_outlined
                                      : Icons.folder,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedWebDav?.webdavUrl ??
                                  _selectedSafUri?.toString() ??
                                  _selectedPath!,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(color: PaperTheme.error)),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      Platform.isAndroid
                          ? 'Tipp: Wähle deinen Cloud-Ordner (Google Drive, OneDrive, ...) um auf mehreren Geräten zu synchronisieren.'
                          : 'Tipp: Wähle einen Cloud-Ordner (OneDrive, Google Drive, ...) um auf mehreren Geräten zu synchronisieren.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: PaperTheme.checked,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => _finish(null),
                        child: const Text('Standard verwenden'),
                      ),
                      if (_hasSelection) ...[
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () => _finish(
                            _selectedWebDav ??
                                (_selectedSafUri != null
                                    ? StorageConfig(
                                        type: StorageType.saf,
                                        safUri: _selectedSafUri.toString(),
                                      )
                                    : StorageConfig(
                                        type: StorageType.filesystem,
                                        path: _selectedPath,
                                      )),
                          ),
                          child: const Text('Loslegen'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickSafFolder() async {
    setState(() => _error = null);
    try {
      final uriString = await SafStorageBackend.openDocumentTree();
      if (uriString != null && mounted) {
        setState(() {
          _selectedSafUri = Uri.parse(uriString);
          _selectedPath = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Ordner konnte nicht geöffnet werden: $e');
    }
  }

  Future<void> _pickFolder() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Speicherordner auswählen',
    );

    if (result != null && mounted) {
      try {
        final dir = Directory(result);
        if (!await dir.exists()) await dir.create(recursive: true);
        final testFile = File('${dir.path}/.meal_planner_test');
        await testFile.writeAsString('ok');
        await testFile.delete();
        setState(() {
          _selectedPath = result;
          _selectedSafUri = null;
          _error = null;
        });
      } catch (e) {
        setState(() => _error = 'Ordner nicht beschreibbar: $e');
      }
    }
  }

  Future<void> _configureWebDav() async {
    setState(() => _error = null);
    final result = await showModalBottomSheet<WebDavFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: WebDavConfigForm(
          submitLabel: 'Übernehmen',
          onSubmit: (r) => Navigator.of(ctx).pop(r),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedWebDav = result.config;
        _selectedWebDavPassword = result.password;
        _selectedSafUri = null;
        _selectedPath = null;
      });
    }
  }

  Future<void> _finish(StorageConfig? config) async {
    final cfg = config ?? const StorageConfig(type: StorageType.local);
    if (cfg.type == StorageType.webdav && _selectedWebDavPassword != null) {
      await ref
          .read(webdavCredentialsServiceProvider)
          .save(cfg, _selectedWebDavPassword!);
    }
    await ref.read(storageConfigNotifierProvider.notifier).setConfig(cfg);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setup_done', true);
    if (mounted) context.go('/plan');
  }
}
