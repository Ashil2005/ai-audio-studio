import 'package:cloud_firestore/cloud_firestore.dart';

/// Standard Dart model for User Profile.
/// Removed 'freezed' to bypass build_runner issues in development.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String plan;
  final int monthlyAudioMinutesUsed;
  final int monthlyDebatesUsed;
  final DateTime? resetDate;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.plan = 'free',
    this.monthlyAudioMinutesUsed = 0,
    this.monthlyDebatesUsed = 0,
    this.resetDate,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      plan: json['plan'] as String? ?? 'free',
      monthlyAudioMinutesUsed: json['monthlyAudioMinutesUsed'] as int? ?? 0,
      monthlyDebatesUsed: json['monthlyDebatesUsed'] as int? ?? 0,
      resetDate: json['resetDate'] != null 
          ? DateTime.tryParse(json['resetDate'].toString()) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      plan: data['plan'] ?? 'free',
      monthlyAudioMinutesUsed: data['monthlyAudioMinutesUsed'] ?? 0,
      monthlyDebatesUsed: data['monthlyDebatesUsed'] ?? 0,
      resetDate: (data['resetDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toFirestoreMap(UserModel user) => {
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'plan': user.plan,
        'monthlyAudioMinutesUsed': user.monthlyAudioMinutesUsed,
        'monthlyDebatesUsed': user.monthlyDebatesUsed,
        'resetDate': user.resetDate != null
            ? Timestamp.fromDate(user.resetDate!)
            : null,
        'createdAt': user.createdAt != null
            ? Timestamp.fromDate(user.createdAt!)
            : FieldValue.serverTimestamp(),
      };

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? plan,
    int? monthlyAudioMinutesUsed,
    int? monthlyDebatesUsed,
    DateTime? resetDate,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      plan: plan ?? this.plan,
      monthlyAudioMinutesUsed: monthlyAudioMinutesUsed ?? this.monthlyAudioMinutesUsed,
      monthlyDebatesUsed: monthlyDebatesUsed ?? this.monthlyDebatesUsed,
      resetDate: resetDate ?? this.resetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
