import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ClassMe/auth_service.dart';


class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> signIn(String email, String password) async {
    User? user = await _authService.signInWithEmailAndPassword(email, password);

    if (user != null) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }
}
