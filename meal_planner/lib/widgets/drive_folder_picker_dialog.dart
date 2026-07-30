import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../repositories/google_drive_storage_backend.dart';

/// Picked folder returned by [DriveFolderPickerDialog].
class PickedDriveFolder {
  final String id;
  final String name;
  const PickedDriveFolder({required this.id, required this.name});
}

/// Modal folder picker that navigates the user's Google Drive.
/// Shows the first folder named `MealPlanner` (if any) at root as a highlight.
class DriveFolderPickerDialog extends StatefulWidget {
  final drive.DriveApi api;

  const DriveFolderPickerDialog({super.key, required this.api});

  @override
  State<DriveFolderPickerDialog> createState() =>
      _DriveFolderPickerDialogState();

  /// Convenience launcher.
  static Future<PickedDriveFolder?> show(
    BuildContext context, {
    required drive.DriveApi api,
  }) {
    return showDialog<PickedDriveFolder>(
      context: context,
      builder: (_) => DriveFolderPickerDialog(api: api),
    );
  }
}

class _DriveFolderPickerDialogState extends State<DriveFolderPickerDialog> {
  /// Breadcrumb stack. First entry = Drive root.
  final List<_Crumb> _stack = [
    const _Crumb(id: 'root', name: 'Mein Drive'),
  ];

  late Future<List<drive.File>> _foldersFuture;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _foldersFuture = _load();
  }

  Future<List<drive.File>> _load() {
    return GoogleDriveStorageBackend.listFolders(
      api: widget.api,
      parentId: _stack.last.id,
    );
  }

  void _navigateInto(drive.File folder) {
    setState(() {
      _stack.add(_Crumb(id: folder.id!, name: folder.name ?? ''));
      _foldersFuture = _load();
      _error = null;
    });
  }

  void _navigateUp() {
    if (_stack.length <= 1) return;
    setState(() {
      _stack.removeLast();
      _foldersFuture = _load();
      _error = null;
    });
  }

  Future<void> _createFolder() async {
    final name = await _promptFolderName(context);
    if (name == null || name.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final created = await GoogleDriveStorageBackend.createFolder(
        api: widget.api,
        name: name.trim(),
        parentId: _stack.last.id,
      );
      if (!mounted) return;
      setState(() {
        _foldersFuture = _load();
        _busy = false;
      });
      _navigateInto(created);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Ordner konnte nicht erstellt werden: $e';
      });
    }
  }

  void _pickCurrent() {
    final current = _stack.last;
    Navigator.of(context).pop(
      PickedDriveFolder(id: current.id, name: current.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final atRoot = _stack.length == 1;
    final breadcrumb = _stack.map((c) => c.name).join(' / ');

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (!atRoot)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Zurück',
                      onPressed: _navigateUp,
                    ),
                  Expanded(
                    child: Text(
                      breadcrumb,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Wähle den Ordner, in dem die App ihre Daten speichern soll.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<drive.File>>(
                  future: _foldersFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'Fehler beim Laden: ${snap.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final folders = snap.data ?? const <drive.File>[];
                    if (folders.isEmpty) {
                      return const Center(
                        child: Text('Keine Unterordner hier.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: folders.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final f = folders[i];
                        return ListTile(
                          leading: const Icon(Icons.folder),
                          title: Text(f.name ?? '(unbenannt)'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _navigateInto(f),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _busy ? null : _createFolder,
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Neu'),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : _pickCurrent,
                    child: const Text('Diesen Ordner wählen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Crumb {
  final String id;
  final String name;
  const _Crumb({required this.id, required this.name});
}

Future<String?> _promptFolderName(BuildContext context) async {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Neuen Ordner erstellen'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Ordnername',
          hintText: 'MealPlanner',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(ctrl.text),
          child: const Text('Erstellen'),
        ),
      ],
    ),
  );
}
