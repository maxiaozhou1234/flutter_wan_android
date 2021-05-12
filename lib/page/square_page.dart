import 'package:dance/model/square_model.dart';
import 'package:dance/page/web_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

class SquarePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SquareState();
  }
}

class _SquareState extends State {
  Color lightGrey = Color.fromARGB(255, 235, 235, 235);
  var pageIndex = 1;

  RefreshController _refreshController = RefreshController();
  var data = <String>[];

//  @override
//  void initState() {
//    super.initState();
//    for (var i = 0; i < 20; i++) {
//      data.add("item $i");
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SquareModel(),
      builder: (context, child) {
        return Selector<SquareModel, SquareModel>(
          shouldRebuild: (pre, next) {
            return true;
          },
          selector: (context, provider) => provider,
          builder: (context, model, child) {
            if (model.currentPage < 1) {
              _refreshController.refreshCompleted(resetFooterState: true);
            } else {
              _refreshController.loadComplete();
            }
            if (!model.loadMoreEnable) {
              _refreshController.loadNoData();
            }

            return Scaffold(
              body: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () => model.onRefresh(),
                onLoading: () => model.onLoadMore(),
                header: BezierHeader(
                  //WaterDropHeader(),
                  child: Center(
                    child: Text(
                      '刷新中...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                controller: _refreshController,
                footer: CustomFooter(
                  builder: (context, mode) {
                    String str;
                    if (mode == LoadStatus.idle) {
                      str = '加载更多';
                    } else if (mode == LoadStatus.failed) {
                      str = '加载失败，点击重试';
                    } else if (mode == LoadStatus.loading) {
                      str = '加载中...';
                    } else if (mode == LoadStatus.canLoading) {
                      str = '释放加载更多';
                    } else {
                      str = '没有更多数据';
                    }
                    Widget body;
                    if (str.isEmpty) {
                      body = CupertinoActivityIndicator();
                    } else {
                      body = Text(str);
                    }
                    return Container(
                      height: 55,
                      child: Center(
                        child: body,
                      ),
                    );
                  },
                ),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    var item = model.squareList[index];
                    return Container(
                        color: index % 2 == 0 ? Colors.transparent : lightGrey,
                        height: 55,
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            GestureDetector(
                              child: Icon(
                                item.collect
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 28,
                              ),
                              onTap: () {
                                Toast.show("like $index", context);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12, right: 12),
                                  child: Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebPage(
                                        title: '广场',
                                        url: item.link,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ));
                  },
                  itemCount: model.squareList.length,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onRefresh() async {
    pageIndex = 0;
    await Future.delayed(Duration(seconds: 5));
    data.clear();
    for (var i = 0; i < 20; i++) {
      data.add("item $i");
    }
    setState(() {});
    _refreshController.resetNoData();
    _refreshController.refreshCompleted();
  }

  void _onLoadMore() async {
    pageIndex = pageIndex + 1;
    await Future.delayed(Duration(seconds: 3));
    for (var i = 0; i < 10; i++) {
      data.add("item $pageIndex - $i");
    }
    setState(() {});
    _refreshController.loadComplete();
    if (pageIndex >= 4) {
      _refreshController.loadNoData();
    }
  }
}
