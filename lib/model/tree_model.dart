import 'package:dance/bean/bean.dart';
import 'package:dance/net/net_repository.dart';
import 'package:flutter/material.dart';

class TreeModel with ChangeNotifier {
  var repository = NetRepository();

  var _currentHeader = '';

  void update() {
    print('tree model update');
    notifyListeners();
  }

  void load() {
    repository.loadHeaders(this);
  }

  List<String> get headList => repository.getHeaders(this);

  int get length => repository.headerSize;

  List<TreeChild> getChildren() {
    if (_currentHeader.isEmpty && length > 0) {
      _currentHeader = headList[0];
    }

    return repository.getChildren(_currentHeader);
  }

  void setCurrentHeader(String header) {
    _currentHeader = header;
    notifyListeners();
  }

  String get currentHeader => _currentHeader;
}
