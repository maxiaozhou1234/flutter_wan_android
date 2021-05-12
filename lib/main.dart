import 'dart:convert' as convert;

import 'package:dance/menu_draw.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'net/call_back.dart';
import 'net/net_path.dart';
import 'net/net_request.dart';
import 'page/category_page.dart';
import 'page/home_page.dart';
import 'page/question_page.dart';
import 'page/square_page.dart';
import 'page/web_page.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
//      MultiProvider(
//      providers: [
//        Provider.value(value: HomeModel()),
//      ],
//      child: MaterialApp(
//        title: 'Flutter Demo',
//        theme: ThemeData(
//          primarySwatch: Colors.blue,
//        ),
//        home: MainPage(),
//      ),
//    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const tabs = ["首页", "问答", "广场", "分区"];

  int _indexNum = 0;

  String title = tabs[0];

  List _pages = [
    HomePage(),
    QuestionPage(),
    SquarePage(),
    CategoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    NetRequest.init(Host);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDraw(redirect),
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {
              Toast.show("搜索", context);

//              rNetRequest.send(HomeBanner).then((response) {
//                print(response.statusCode);
//                print(response.body);
//              }).catchError((onError) {
//                print(onError);
//              });
              NetRequest.send(
                  HomeBanner,
                  Callback((response) {
                    var map = convert.jsonDecode(response.body)
                        as Map<String, dynamic>;
                    var type = map['data'].runtimeType;

                    print(response.body);
                    print(type);
                  }, onError: (e) {
                    print(e);
                  }));
            },
          )
        ],
      ),
      body: _pages[_indexNum],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "首页",
              activeIcon: Icon(Icons.home_outlined)),
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer),
              label: "问答",
              activeIcon: Icon(Icons.question_answer_outlined)),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "广场",
              activeIcon: Icon(Icons.people_outline)),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_comment),
              label: "分区",
              activeIcon: Icon(Icons.add_comment_outlined)),
        ],
        iconSize: 24,
        currentIndex: _indexNum,
//        选中后，底部BottomNavigationBar内容的颜色(选中时，默认为主题色)
//      （仅当type: BottomNavigationBarType.fixed,时生效）
        fixedColor: Colors.lightBlueAccent,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          if (_indexNum != index) {
            setState(() {
              _indexNum = index;
              title = tabs[index];
            });
          }
        },
      ),
    );
  }

  Widget _getPagesWidget(int index) {
    List<Widget> widgetList = [
      Center(
        child: Text("首页"),
      ),
      Center(
        child: Text("问答"),
      ),
      Center(
        child: Text("广场"),
      ),
      Center(
        child: Text("分区"),
      ),
    ];
    return Offstage(
      offstage: _indexNum != index,
      child: widgetList[index],
    );
  }

  void redirect(String link, List subtitle) {
    if (link == null) return;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => WebPage(title: subtitle[0])));
  }
}
