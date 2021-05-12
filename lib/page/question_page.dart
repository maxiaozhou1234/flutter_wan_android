import 'package:dance/model/question_model.dart';
import 'package:dance/page/web_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class QuestionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuestionState();
  }
}

class _QuestionState extends State {
  Color itemHeaderColor = Color.fromARGB(255, 0, 191, 255);
  Color lightGrey = Color.fromARGB(255, 196, 196, 196);
  Color snow = Color.fromARGB(255, 240, 248, 255);

  bool _firstInit = true;
  bool _isRefresh = false;

  RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //todo 刷新
    return ChangeNotifierProvider(
        create: (_) {
          var model = QuestionModel();
          Future.delayed(Duration(seconds: 2), () => model.load());
          return model;
        },
        child: Selector<QuestionModel, QuestionModel>(
          selector: (context, provider) => provider,
          shouldRebuild: (pre, next) => true,
          builder: (context, model, index) {
            var data = model.questions;

            if (_isRefresh) {
              _isRefresh = false;
              _refreshController.refreshCompleted(resetFooterState: true);
            } else {
              _refreshController.loadComplete();
            }
            if (!model.loadMoreEnable) {
              _refreshController.loadNoData();
            }

            if (data.isEmpty) {
              //空，加载
              if (_firstInit) {
                _firstInit = false;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Padding(padding: EdgeInsets.only(top: 6)),
                      Text(
                        '数据加载中...',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      )
                    ],
                  ),
                );
              } else {
                //加载失败，提示重新加载
                return Center(
                  child: TextButton(
                    child: Text(
                      '重新加载',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => model.refresh(),
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(2.0),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black12)),
                  ),
                );
              }
            } else {
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: model.loadMoreEnable,
                onRefresh: () => Future.delayed(Duration(seconds: 2), () {
                  _isRefresh = true;
                  model.refresh();
                }),
                onLoading: () => model.loadNext(),
                footer: CustomFooter(
                  builder: (context, mode) {
                    String str;
                    if (mode == LoadStatus.idle) {
                      str = '加载更多';
                    } else if (mode == LoadStatus.failed) {
                      str = '加载失败，点击重试';
                    } else if (mode == LoadStatus.loading) {
                      str = '加载中';
                    } else if (mode == LoadStatus.canLoading) {
                      str = '释放加载更多';
                    } else {
                      str = '已经到底啦';
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
                    var item = data[index];
                    return Container(
                      margin: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: GestureDetector(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: snow,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12)),
                              border: Border.all(color: lightGrey)),
                          child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          color: Colors.blue,
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 4, left: 8, right: 8, bottom: 8),
                                      child: Text(
                                        item.desc,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      )),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(right: 8, bottom: 8),
                                      child: Text(
                                        '${item.author} | ${item.niceDate}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebPage(
                                        title: '问答',
                                        url: item.link,
                                      )));
                        },
                      ),
                    );
                  },
                  itemCount: model.size,
                ),
              );
            }
          },
        ));
  }
}
