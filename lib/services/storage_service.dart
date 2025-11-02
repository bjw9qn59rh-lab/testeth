import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/time_entry.dart';

class StorageService {
  static const _fileName = 'eth_hours.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<TimeEntry>> load() async {
    try {
      final f = await _getFile();
      if (!await f.exists()) return [];
      final content = await f.readAsString();
      return listFromJson(content);
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<TimeEntry> entries) async {
    final f = await _getFile();
    await f.writeAsString(listToJson(entries));
  }
}
