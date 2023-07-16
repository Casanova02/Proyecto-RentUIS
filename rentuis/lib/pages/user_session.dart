import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  String? userId;
  int? userRating;
  Future<void> signIn(String email, String password) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      final Map<String, dynamic>? userData =
      userDoc.data() as Map<String, dynamic>?;

      final userPassword = userData?['contraseña'];
      userId = userDoc.id;

      final userRating = userData?['rating'];
      if (userRating is int) {
        this.userRating = userRating;
      }

      if (userPassword != null && userPassword == password) {

      } else {

      }
    } else {

    }
  }



  void signOut() {

    userId = null;
  }
}