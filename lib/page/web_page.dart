import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

//暂时用来显示侧边栏。占位
class WebPage extends StatelessWidget {
  WebPage({Key key, this.title, this.url}) : super(key: key);

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (url == null || url.isEmpty) {
      body = Center(
        child: Text(this.title),
      );
    } else {
      body = WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: this.url,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: body,
    );
  }
}
