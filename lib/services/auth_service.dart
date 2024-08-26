import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In importu
import 'dart:io';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn örneği

  User? get currentUser => _firebaseAuth.currentUser;

  String? get userID => currentUser?.uid;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Oturum açıldıktan sonra userID'yi başlatın
      final uid = currentUser?.uid;
      if (uid != null) {
        await _initializeUserSession(uid);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      await _setUserRole(uid, 'user');
      await _createUserDocument(uid, email);

      // Yeni kullanıcı oluşturulduktan sonra userID'yi başlatın
      await _initializeUserSession(uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut(); // Google oturumunu kapat
  }

  Future<String> getUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('role')) {
          final role = data['role'];
          if (role is String) {
            return role;
          } else {
            throw Exception('Role field is not a String.');
          }
        } else {
          throw Exception('Role field is missing in user document.');
        }
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return 'user'; // Default role
    }
  }

  Future<void> _setUserRole(String uid, String role) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({'role': role}, SetOptions(merge: true));
    } catch (e) {
      print('Error setting user role: $e');
    }
  }

  Future<void> _createUserDocument(String uid, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': '', // Initialize with default or empty value
        'biography': '',
        'websites': '',
        'photoURL': '',
        'userID': uid, // Ensure userID is included
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  Future<void> _initializeUserSession(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        // Oturum ile ilgili gerekli işlemleri başlatın (örneğin, kullanıcı verilerini yükleyin)
        print('User session initialized for UID: $uid');
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      print('Error initializing user session: $e');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('images/${currentUser!.uid}');
      final uploadTask = imageRef.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Image upload failed');
    }
  }

  Future<void> updateProfileWithImage(File imageFile,
      {String? displayName}) async {
    try {
      // Get current user
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Retrieve current photoURL
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final oldPhotoURL = userDoc.data()?['photoURL'] as String?;

        // Upload new image
        final photoURL = await uploadProfileImage(imageFile);

        // Update user profile
        await updateProfile(displayName: displayName, photoURL: photoURL);

        // Update user data in Firestore
        await updateUserData(name: displayName, photoURL: photoURL);

        // Delete old profile image if it exists
        if (oldPhotoURL != null && oldPhotoURL.isNotEmpty) {
          final oldImageRef = FirebaseStorage.instance.refFromURL(oldPhotoURL);
          await oldImageRef.delete();
        }
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      print('Error updating profile with image: $e');
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: displayName, photoURL: photoURL);
        await user.reload();
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<void> updateUserData({
    String? name,
    String? email,
    String? biography,
    String? website,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final userDocRef = _firestore.collection('users').doc(user.uid);
        await userDocRef.set({
          'name': name ?? user.displayName,
          'email': email ?? user.email,
          'biography': biography ?? '',
          'website': website ?? '',
          'photoURL': photoURL ?? '',
          'userID': user.uid, // Ensure userID is included
        }, SetOptions(merge: true));
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Google Sign-In akışını başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In failed');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase ile oturum aç
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth ile oturum aç
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      throw Exception('Google sign-in failed');
    }
  }

  // Hata işleme fonksiyonu
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return Exception('Geçersiz e-posta adresi.');
        case 'user-disabled':
          return Exception('Bu kullanıcı hesabı devre dışı bırakılmıştır.');
        case 'user-not-found':
          return Exception('Bu e-posta adresi ile bir kullanıcı bulunamadı.');
        case 'wrong-password':
          return Exception('Şifre yanlış.');
        case 'email-already-in-use':
          return Exception('Bu e-posta adresi zaten kullanılıyor.');
        default:
          return Exception('Bir hata oluştu: ${e.message}');
      }
    }
    return Exception('Bir hata oluştu: $e');
  }
}
