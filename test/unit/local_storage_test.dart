import 'dart:convert';
import 'package:audio_studio/models/library_item.dart';
import 'package:audio_studio/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageService storageService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storageService = LocalStorageService();
  });

  group('LocalStorageService Tests', () {
    final testItem = LibraryItem(
      id: '1',
      title: 'Test Summary',
      type: LibraryItemType.summary,
      content: 'This is a test summary content.',
      createdAt: DateTime.now(),
    );

    test('Save and retrieve item', () async {
      await storageService.saveItem(testItem);
      final items = await storageService.getItems();
      
      expect(items.length, 1);
      expect(items.first.id, '1');
      expect(items.first.title, 'Test Summary');
      expect(items.first.content, testItem.content);
    });

    test('Multiple saves should append/update', () async {
      await storageService.saveItem(testItem);
      
      final item2 = LibraryItem(
        id: '2',
        title: 'Debate',
        type: LibraryItemType.debate,
        content: 'Debate content',
        createdAt: DateTime.now(),
      );
      
      await storageService.saveItem(item2);
      final items = await storageService.getItems();
      
      expect(items.length, 2);
      expect(items.any((i) => i.id == '2'), true);
    });

    test('Delete item', () async {
      await storageService.saveItem(testItem);
      await storageService.deleteItem('1');
      final items = await storageService.getItems();
      
      expect(items, isEmpty);
    });

    test('Clear all', () async {
      await storageService.saveItem(testItem);
      await storageService.clearAll();
      final items = await storageService.getItems();
      
      expect(items, isEmpty);
    });

    test('Handle corrupted JSON gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('library_items', ['invalid json', '{ "id": "valid" }']);
      
      final items = await storageService.getItems();
      // Should ideally return valid items or empty if all fail
      // Our current implementation catches all and returns []
      expect(items, isEmpty); 
    });
  });
}
