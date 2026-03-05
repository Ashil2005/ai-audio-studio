import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';

/// Generic Firestore service.
/// In Stage 2+, expand with book/podcast/debate collections.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Users ────────────────────────────────────────────────────────────────────

  Future<void> setUserProfile(UserModel user) async {
    await _db
        .collection(AppConfig.usersCollection)
        .doc(user.uid)
        .set(UserModel.toFirestoreMap(user), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc =
        await _db.collection(AppConfig.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _db
        .collection(AppConfig.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ─── Generic Helpers (used by Stage 2+ repositories) ─────────────────────────

  Future<DocumentReference> addDocument(
      String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) {
    return _db.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) {
    return _db.collection(collection).doc(docId).delete();
  }

  Stream<QuerySnapshot> watchCollection(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = true,
  }) {
    Query query = _db.collection(collection);
    if (whereField != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots();
  }
}
