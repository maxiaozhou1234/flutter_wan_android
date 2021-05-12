import 'package:cached_network_image/cached_network_image.dart';
import 'package:dance/bean/bean.dart';
import 'package:dance/model/home_model.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'web_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State {
  var bg = [
    Colors.green,
    Colors.blue,
    Colors.deepPurpleAccent,
    Colors.redAccent,
    Colors.amber,
    Colors.black38
  ];

  @override
  Widget build(BuildContext context) {
    print("build home");

    return ChangeNotifierProvider<HomeModel>(
      create: (_) {
        var model = HomeModel();
        print('create model');
        model.load();
        return model;
      },
      child: Selector<HomeModel, HomeModel>(
        shouldRebuild: (pre, next) => next.isRequestDone,
        selector: (context, provider) => provider,
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => Future.delayed(
                Duration(seconds: 2), () => provider.onRefresh()),
            color: Colors.red,
            backgroundColor: Colors.white,
            displacement: 20,
            child: ListView.separated(
                itemCount: provider.totalCount,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildBanner();
                  } else {
                    return _buildItem(context, provider, index - 1);
                  }
                },
                separatorBuilder: (context, index) {
                  if (index == 0) {
                    return SizedBox(
                      height: 1,
                    );
                  } else
                    return Divider(
                      height: 1,
                      color: Colors.grey,
                      indent: 20,
                      endIndent: 20,
                    );
                }),
          );
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Consumer<HomeModel>(builder: (context, model, _) {
      return Padding(
        padding: EdgeInsets.all(0),
        child: AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: Swiper(
            interval: Duration(seconds: 5),
            circular: true,
            autoStart: true,
            indicator: CircleSwiperIndicator(
                itemActiveColor: Colors.blueAccent, itemColor: Colors.grey),
            indicatorAlignment: AlignmentDirectional.bottomCenter,
            children: (model.banners).map((banner) {
              return InkWell(
//                child: Image.network(banner.imagePath),
                child: CachedNetworkImage(
                  imageUrl: banner.imagePath,
                  //CircularProgressIndicator(),
                  placeholder: (context, url) => Center(
                    child: Image.asset('images/ic_android.png'),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),

                onTap: () {
//                  Toast.show('on tap ${banner.url}', context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebPage(
                        title: banner.title,
                        url: banner.url,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildItem(BuildContext context, HomeModel provider, int index) {
    return Selector<HomeModel, ArticleItem>(
      selector: (context, provider) => provider.topPages[index],
      builder: (context, item, child) {
        print('build item ${item.title}');
        double height;
        if (item.desc.isEmpty) {
          height = 100.0;
        } else {
          height = 160.0;
        }
        return GestureDetector(
          behavior: HitTestBehavior.translucent, //响应空白处
          onTap: () {
//            Toast.show(item.author, context); //TODO 点击事件
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebPage(
                  title: item.author,
                  url: item.link,
                ),
              ),
            );
          },
          child: Container(
            height: height, //160.0,
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(
                        item.superChapterName,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      backgroundColor: bg[index % bg.length],
                    ),
                  ],
                ),
                SizedBox(
                  width: 50,
                  height: 2,
                  child: Container(color: Colors.teal),
                ),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 6, right: 6, top: 10),
                      child: Text(
                        item.desc,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    )),
                Row(
                  children: [
                    GestureDetector(
                      child: Icon(
                        item.collect ? Icons.favorite : Icons.favorite_border,
                        size: 26,
                      ),
                      onTap: () => provider.collect(index),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(item.author),
                    SizedBox(
                      width: 10,
                    ),
                    Text(item.updateTime)
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
