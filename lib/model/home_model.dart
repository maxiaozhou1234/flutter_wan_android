import 'package:dance/bean/bean.dart';
import 'package:dance/net/net_repository.dart';
import 'package:flutter/material.dart';

class HomeModel with ChangeNotifier {
  var _repository = NetRepository();

  var _requestFlag = false;

  void load(){
    if (_repository.totalCount <= 1) {
      Future.delayed(
          Duration(milliseconds: 1500), () => _repository.onRefresh(this));
    }
  }

  void collect(int index) {
    var item = _repository.topPages[index];
    item.collect = !item.collect;
    _repository.topPages[index] = item.clone();
    notifyListeners();

    //todo 发起更新收藏请求，之后再同步确认状态
    _repository.collect(index);
  }

  //ui 更新布局
  void onRefresh() {
    _requestFlag = false;
    _repository.onRefresh(this);
  }

  //网络请求完毕，刷新
  void update() {
    print('======== update ========');
    _requestFlag = true;
    notifyListeners();
  }

  List<BannerItem> get banners => _repository.banner;

  List<ArticleItem> get topPages => _repository.topPages;

  bool get isRequestDone => _requestFlag;

  int get totalCount => _repository.totalCount;
}
