import 'package:flutter/material.dart';

class Favorites with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  void addFavorite(Map<String, dynamic> device) {
    _favorites.add(device);
    notifyListeners();
  }
}
