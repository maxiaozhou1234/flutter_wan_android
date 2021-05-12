import 'package:dance/bean/bean.dart';
import 'package:dance/net/net_repository.dart';
import 'package:flutter/material.dart';

class SquareModel with ChangeNotifier {
  var repository = NetRepository();

  SquareModel() {
    if (repository.squareList.isEmpty) {
      Future.delayed(
          Duration(seconds: 2), () => repository.refreshSquare(this));
    }
  }

  void update() {
    notifyListeners();
  }

  bool get loadMoreEnable => repository.squareLoadMoreEnable;

  List<SquareItem> get squareList => repository.squareList;

  int get currentPage => repository.squareCurrentPage;

  void onRefresh() {
    repository.refreshSquare(this);
  }

  void onLoadMore() {
    repository.loadSquare(this);
  }

  @override
  void dispose() {
    print("square dispose");
    //仅保留20条数据
    repository.removeSquareData();
    super.dispose();
  }
}
