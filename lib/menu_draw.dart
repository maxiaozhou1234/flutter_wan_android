import 'package:flutter/material.dart';

import 'page_router.dart';

class MenuDraw extends StatelessWidget {
  final Function redirect;

  const MenuDraw(this.redirect);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
          context: context,
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                  child: Column(
                children: [
                  Image.asset('images/ic_todo.png'),
                  Center(
                    child: Text(
                      'Marrow',
                      style:
                          TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    ),
                  )
                ],
              )),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("设置"),
                onTap: () {
                  Navigator.pop(context);
                  redirect(Settings, ['设置']);
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text("收藏"),
                onTap: () {
                  Navigator.pop(context);
                  redirect(Collection, ['收藏']);
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text("分享"),
                onTap: () {
                  Navigator.pop(context);
                  redirect(Shared, ['分享']);
                },
              )
            ],
          )),
    );
  }
}
