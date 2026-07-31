import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sync_provider.dart';
import '../repositories/cached_sync_storage_backend.dart';
import '../providers/repository_providers.dart';
import '../services/sync_service.dart';

/// Small AppBar icon showing the current sync state.
/// Only visible when the active backend is [CachedSyncStorageBackend].
class SyncStatusIcon extends ConsumerWidget {
  const SyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backendAsync = ref.watch(storageBackendProvider);
    final backend = backendAsync.valueOrNull;
    if (backend is! CachedSyncStorageBackend) return const SizedBox.shrink();

    final statusAsync = ref.watch(syncStatusProvider);
    final detail = statusAsync.valueOrNull ?? SyncStatusDetail(SyncStatus.idle);

    return switch (detail.status) {
      SyncStatus.syncing => const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      SyncStatus.error => IconButton(
          icon: const Icon(Icons.cloud_off, color: Colors.red),
          tooltip: detail.errorMessage ?? 'Sync-Fehler',
          onPressed: () async {
            final service = await ref.read(syncServiceProvider.future);
            service?.syncNow();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(detail.errorMessage ?? 'Sync fehlgeschlagen'),
                action: SnackBarAction(
                  label: 'Erneut versuchen',
                  onPressed: () async {
                    final s = await ref.read(syncServiceProvider.future);
                    s?.syncNow();
                  },
                ),
              ),
            );
          },
        ),
      SyncStatus.idle => const Icon(Icons.cloud_done, color: Colors.green),
    };
  }
}
