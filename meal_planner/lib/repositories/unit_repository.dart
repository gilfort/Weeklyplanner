import 'dart:convert';

import 'storage_backend.dart';

/// Persists the user's list of known units as a simple JSON string array.
class UnitRepository {
  static const fileName = 'units.json';
  static const defaultUnits = [
    'g', 'kg', 'ml', 'l', 'Stk', 'EL', 'TL',
    'Prise', 'Dose', 'Bund', 'Packung', 'Becher', 'Scheibe',
  ];

  final StorageBackend storage;
  UnitRepository({required this.storage});

  Future<List<String>> readAll() async {
    try {
      final content = await storage.read(fileName);
      if (content == null || content.trim().isEmpty) return List.of(defaultUnits);
      final List<dynamic> list = jsonDecode(content) as List<dynamic>;
      final units = list.cast<String>();
      return units.isEmpty ? List.of(defaultUnits) : units;
    } catch (_) {
      return List.of(defaultUnits);
    }
  }

  Future<void> writeAll(List<String> units) async {
    await storage.write(fileName, jsonEncode(units));
  }

  Future<void> addUnit(String unit) async {
    final units = await readAll();
    final trimmed = unit.trim();
    if (trimmed.isNotEmpty && !units.contains(trimmed)) {
      units.add(trimmed);
      await writeAll(units);
    }
  }

  Future<void> removeUnit(String unit) async {
    final units = await readAll();
    units.remove(unit);
    await writeAll(units);
  }
}
