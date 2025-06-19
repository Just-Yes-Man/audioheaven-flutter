import 'package:flutter/material.dart';


class MyAppState extends ChangeNotifier {
  String _token = "";
  String _username = "";
  String _error = "";
  int _selectedIndex = 0;

  // Getters
  String get token => _token;
  String get username => _username;
  String get error => _error;
  int get selectedIndex => _selectedIndex;

  // Setters con notifyListeners
  set token(String value) {
    _token = value;
    notifyListeners();
  }

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set error(String value) {
    _error = value;
    notifyListeners();
  }

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  // Métodos útiles
  void login(String username, String token) {
    _username = username;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _username = "";
    _token = "";
    notifyListeners();
  }
}
