import 'package:flutter/material.dart';

import '../model/item_model.dart';

class SearchProvider extends ChangeNotifier {
  bool _isSearching = false;
  List<Product> _searchResults = [];

  bool get isSearching => _isSearching;
  List<Product> get searchResults => _searchResults;

  void setIsSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  void setSearchResults(List<Product> results) {
    _searchResults = results;
    notifyListeners();
  }
}
