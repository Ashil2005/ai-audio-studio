import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/library_item.dart';
import '../core/utils/logger.dart';

class LocalStorageService {
  static const String _libraryKey = 'library_items';
  static const int _contentThreshold = 10000;

  Future<void> saveItem(LibraryItem item) async {
    final items = await getItems();
    
    LibraryItem itemToSave = item;
    
    // Check for large content
    if (item.content.length > _contentThreshold && item.contentPath == null) {
      try {
        final path = await _saveContentToFile(item.id, item.content);
        itemToSave = LibraryItem(
          id: item.id,
          title: item.title,
          type: item.type,
          content: '${item.content.substring(0, 500)}...', // Store preview only
          contentPath: path,
          createdAt: item.createdAt,
          metadata: item.metadata,
        );
        AppLogger.log("Saved large content to file: $path");
      } catch (e) {
        AppLogger.error("Failed to save large content to file", e);
        // Fallback: save anyway to SharedPreferences if file fails
      }
    }

    final index = items.indexWhere((element) => element.id == itemToSave.id);
    if (index != -1) {
      items[index] = itemToSave;
    } else {
      items.insert(0, itemToSave);
    }
    await _saveAll(items);
  }

  Future<String> _saveContentToFile(String id, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lib_$id.txt');
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> readFullContent(LibraryItem item) async {
    if (item.contentPath == null) return item.content;
    
    try {
      final file = File(item.contentPath!);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        AppLogger.error("Content file not found at ${item.contentPath}");
        return item.content; // Return preview as fallback
      }
    } catch (e) {
      AppLogger.error("Error reading content file", e);
      return item.content;
    }
  }

  Future<List<LibraryItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedItems = prefs.getStringList(_libraryKey);
    if (encodedItems == null) return [];

    try {
      return encodedItems
          .map((e) => LibraryItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error("Failed to decode library items", e);
      return [];
    }
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems();
    final itemToDelete = items.firstWhere((i) => i.id == id, orElse: () => LibraryItem(id: '', title: '', type: LibraryItemType.summary, content: '', createdAt: DateTime.now()));
    
    if (itemToDelete.contentPath != null) {
      try {
        final file = File(itemToDelete.contentPath!);
        if (await file.exists()) await file.delete();
      } catch (e) {
        AppLogger.error("Failed to delete content file", e);
      }
    }

    items.removeWhere((item) => item.id == id);
    await _saveAll(items);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_libraryKey);
    // Note: This doesn't clear the files in app dir, maybe should?
  }

  Future<void> _saveAll(List<LibraryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_libraryKey, encoded);
  }
}
