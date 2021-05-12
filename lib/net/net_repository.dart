import 'dart:collection';
import 'dart:convert' as convert;

import 'package:dance/bean/bean.dart';
import 'package:dance/model/home_model.dart';
import 'package:dance/model/question_model.dart';
import 'package:dance/model/square_model.dart';
import 'package:dance/model/tree_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'call_back.dart';
import 'net_path.dart';
import 'net_request.dart';

class NetRepository {
  NetRepository._privateConstructor();

  static NetRepository _instance = NetRepository._privateConstructor();

  factory NetRepository() => _instance;

  var _bannerList = <BannerItem>[
    BannerItem(
        0,
        '做个app',
        'https://www.wanandroid.com/blogimgs/50c115c2-cf6c-4802-aa7b-a4334de444cd.png',
        '')
  ];
  var _topPages = <ArticleItem>[];

  var _totalCount = 1;
  var _requestCount = 0;

  void onRefresh(HomeModel homeModel) {
    print('onRefresh....');
    _requestCount = 0;
    NetRequest.send(
        HomeBanner,
        Callback(
            (response) {
              try {
                if (response.statusCode == 200) {
                  var map =
                      convert.jsonDecode(response.body) as Map<String, dynamic>;
                  if (0 == map['errorCode']) {
                    var list = <BannerItem>[];
                    (map['data'] as List<dynamic>).forEach((element) {
                      var m = element as Map<String, dynamic>;
                      list.add(BannerItem.create(m));
                    });

                    _bannerList.clear();
                    _bannerList.addAll(list);
                  }
                }
              } catch (e) {
                print(e.toString());
              }
            },
            onError: (e) {},
            done: () {
              print('加载 banner done');
              _requestCount++;
              if (_requestCount >= 2) {
                _totalCount = _topPages.length + 1;
                homeModel.update();
              }
            }));

    NetRequest.send(
        ArticleTop,
        Callback((response) {
          try {
            if (response.statusCode == 200) {
              var map =
                  convert.jsonDecode(response.body) as Map<String, dynamic>;
              if (0 == map['errorCode']) {
                var list = <ArticleItem>[];
                (map['data'] as List<dynamic>).forEach((element) {
                  var m = element as Map<String, dynamic>;
                  list.add(ArticleItem.create(m));
                });

                _topPages.clear();
                _topPages.addAll(list);
              }
            }
          } catch (e) {
            print(e.toString());
          }
        }, done: () {
          print('加载 top page done');
          _requestCount++;
          if (_requestCount >= 2) {
            _totalCount = _topPages.length + 1;
            homeModel.update();
          }
        }));
  }

  void collect(int index) {
    //todo 发起更新收藏请求，之后再同步确认状态
  }

  List<BannerItem> get banner => _bannerList;

  List<ArticleItem> get topPages => _topPages;

  int get totalCount => _totalCount;

  //===================================
  //问答
  //===================================
  var _questionList = <QuestionItem>[];

  List<QuestionItem> get questions => _questionList;

  var _currentQuestionPage = 0;
  var _loadMoreQuestionEnable = true;

  int get currentQuestionPage => _currentQuestionPage;

  bool get loadMoreQuestionEnable => _loadMoreQuestionEnable;

  void refreshQuestion({QuestionModel model}) {
    _loadMoreQuestionEnable = false;
    _currentQuestionPage = 0;
    this.loadQuestion(model: model, page: 0);
  }

  void loadMoreQuestion({QuestionModel model}) {
    this.loadQuestion(model: model, page: _currentQuestionPage + 1);
  }

  void loadQuestion({QuestionModel model, int page = 0}) {
    print('load question');
    NetRequest.send(
        getQuestion(page),
        Callback((response) {
          if (response.statusCode == 200) {
            var map = convert.jsonDecode(response.body) as Map<String, dynamic>;
            if (0 == map['errorCode']) {
              Map<String, dynamic> data = map['data'] as Map<String, dynamic>;
              _currentQuestionPage = data['curPage'];
              var list = <QuestionItem>[];
              (data['datas'] as List<dynamic>).forEach((element) {
                var m = element as Map<String, dynamic>;
                list.add(QuestionItem.create(m));
              });

              if (_currentQuestionPage == 0) {
                _questionList.clear();
              }
              _questionList.addAll(list);

              _loadMoreQuestionEnable = _questionList.length < data['total'];
            }
          }
        }, done: () {
          model?.requestDone();
        }));
  }

  //===================================
  //体系标题
  //===================================
  String _treeKeys = 'treeKeys';
  List<String> _headers = <String>[];
  HashMap<String, List<TreeChild>> _treeMap = HashMap();

  void loadHeaders(TreeModel model) {
    if (_headers.isEmpty) {
      Future.delayed(Duration(seconds: 2), () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String treeStr = prefs.getString(_treeKeys);
        print('sp >> \n$treeStr');
        if (treeStr != null && treeStr.isNotEmpty) {
          List<dynamic> data = convert.jsonDecode(treeStr) as List<dynamic>;
          decodeTreeMap(data);
        }

        if (_headers.isEmpty) {
          //网络请求
          NetRequest.send(
              Tree,
              Callback((response) async {
                if (response.statusCode == 200) {
                  var map =
                      convert.jsonDecode(response.body) as Map<String, dynamic>;
                  if (0 == map['errorCode']) {
                    print('response >>>> \n\t\t ${map['data']}');

                    var data = map['data'] as List<dynamic>;
                    decodeTreeMap(data);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(_treeKeys, convert.jsonEncode(map['data']));
                  }
                }
              }, done: () {
                model.update();
              }));
        } else {
          model.update();
        }
      });
    }
  }

  List<String> getHeaders(TreeModel model) {
    if (_headers.isEmpty) {
      Future(() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String treeStr = prefs.getString(_treeKeys);
        print('sp >> \n$treeStr');
        if (treeStr != null && treeStr.isNotEmpty) {
          List<dynamic> data = convert.jsonDecode(treeStr) as List<dynamic>;
          decodeTreeMap(data);
        }

        if (_headers.isEmpty) {
          //网络请求
          NetRequest.send(
              Tree,
              Callback((response) async {
                if (response.statusCode == 200) {
                  var map =
                      convert.jsonDecode(response.body) as Map<String, dynamic>;
                  if (0 == map['errorCode']) {
                    print('response >>>> \n\t\t ${map['data']}');

                    var data = map['data'] as List<dynamic>;
                    decodeTreeMap(data);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(_treeKeys, convert.jsonEncode(map['data']));
                  }
                }
              }, done: () {
                model.update();
              }));
        } else {
          model.update();
        }
      });
    }
    return _headers;
  }

  void decodeTreeMap(List<dynamic> data) {
    print('========= decodeTreeMap =========');
    _headers.clear();
    _treeMap.clear();
    data.forEach((element) {
      var item = element as Map<String, dynamic>;

      var name = item['name'];
      _headers.add(name);

      var children = item['children'] as List<dynamic>;
      var list = <TreeChild>[];

      children.forEach((e) {
        var child = e as Map<String, dynamic>;
        list.add(TreeChild(child['id'], child['name']));
      });

      _treeMap[name] = list;
    });
    print('header:${_headers.length}');
    print('========= decodeTreeMap =========');
  }

  List<TreeChild> getChildren(String name) {
    var list = _treeMap[name];
    if (list == null) {
      list = <TreeChild>[];
    }
    return list;
  }

  int get headerSize => _headers.length;

  //==================================
  //广场
  //==================================

  var _squarePage = 0;

  List<SquareItem> _squareList = <SquareItem>[];

  List<SquareItem> get squareList => _squareList;

  bool get squareLoadMoreEnable => _squarePage < 5;

  int get squareCurrentPage => _squarePage;

  void loadSquare(SquareModel model) {
    if (_squarePage < 5) {
      //限制5页，100条数据
      _requestSquare(_squarePage + 1, model);
    }
  }

  void refreshSquare(SquareModel model) {
    _squarePage = 0;
    _requestSquare(0, model);
  }

  void removeSquareData() {
    if (_squarePage > 0 && _squareList.length > 20) {
      var list = _squareList.sublist(0, 20);
      _squareList.clear();
      _squareList.addAll(list);
      _squarePage = 1;
      print('square delete data,size:${_squareList.length}');
    }
  }

  void _requestSquare(int page, SquareModel model) {
    print('request squate $page');
    NetRequest.send(
        getSquare(page),
        Callback((response) {
          if (response.statusCode == 200) {
            var map = convert.jsonDecode(response.body) as Map<String, dynamic>;
            if (0 == map['errorCode']) {
              var data = map['data'] as Map<String, dynamic>;
              int curPage = data['curPage'];

              _squarePage = curPage > 0 ? curPage - 1 : 0;
              var list = data['datas'] as List<dynamic>;
              var temp = <SquareItem>[];
              list.forEach((element) {
                var m = element as Map<String, dynamic>;
                temp.add(SquareItem.create(m));
              });
              if (curPage == 1) {
                _squareList.clear();
              }
              _squareList.addAll(temp);
            }
          }
        }, done: () {
          model.update();
        }));
  }
}
