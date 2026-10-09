import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nutrition_model.dart';

/// Service to manage user profiles in Cloud Firestore at `users/{firebaseAuthUid}`.
class UserProfileService {
  final FirebaseFirestore _firestore;

  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Creates a user profile document at `users/{uid}`.
  ///
  /// Uses [FieldValue.serverTimestamp()] for `createdAt` and `updatedAt`.
  /// Preserves existing fields if the document already exists.
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? name,
  }) async {
    final docRef = _usersRef.doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final data = <String, dynamic>{
        'uid': uid,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'dietPreference': 'Vegetarian',
        'role': 'user',
      };
      if (name != null && name.trim().isNotEmpty) {
        data['name'] = name.trim();
      }
      await docRef.set(data);
    } else {
      final existingData = snapshot.data() ?? {};
      final updates = <String, dynamic>{};
      if (!existingData.containsKey('email') || existingData['email'] == null) {
        updates['email'] = email.trim();
      }
      if (name != null &&
          name.trim().isNotEmpty &&
          (!existingData.containsKey('name') ||
              existingData['name'] == null ||
              (existingData['name'] as String).isEmpty)) {
        updates['name'] = name.trim();
      }
      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await docRef.set(updates, SetOptions(merge: true));
      }
    }
  }

  /// Retrieves the user profile document for [uid].
  Future<UserProfile?> getUserProfile(String uid) async {
    final snapshot = await _usersRef.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return UserProfile.fromMap(snapshot.data()!, uid: uid);
  }

  /// Observes changes to the user profile document for [uid].
  Stream<UserProfile?> streamUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserProfile.fromMap(snapshot.data()!, uid: uid);
    });
  }

  /// Updates an authenticated user's profile.
  ///
  /// Merges data to avoid overwriting existing fields unnecessarily.
  /// Protected fields like [uid], [createdAt], and [role] are excluded.
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final updateData = Map<String, dynamic>.from(data);
    updateData.remove('uid');
    updateData.remove('createdAt');
    updateData.remove('role');
    updateData['updatedAt'] = FieldValue.serverTimestamp();

    await _usersRef.doc(uid).set(updateData, SetOptions(merge: true));
  }
}
