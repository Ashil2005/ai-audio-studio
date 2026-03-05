import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/library_item.dart';
import '../services/local_storage_service.dart';

final localStorageServiceProvider = Provider((ref) => LocalStorageService());

final libraryProvider = StateNotifierProvider<LibraryController, List<LibraryItem>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LibraryController(storage);
});

class LibraryController extends StateNotifier<List<LibraryItem>> {
  final LocalStorageService _storage;
  final _uuid = const Uuid();

  LibraryController(this._storage) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    final items = await _storage.getItems();
    state = items;
  }

  Future<void> addItem({
    required String title,
    required LibraryItemType type,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final newItem = LibraryItem(
      id: _uuid.v4(),
      title: title,
      type: type,
      content: content,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    await _storage.saveItem(newItem);
    // Reload items to ensure we have the correct hybrid state (contentPath etc)
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _storage.deleteItem(id);
    state = state.where((item) => item.id != id).toList();
  }

  Future<void> clearAll() async {
    await _storage.clearAll();
    state = [];
  }
}
