import 'package:dance/model/tree_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CategoryState();
  }
}

//flutter_staggered_grid_view
class _CategoryState extends State {
  bool _needRebuild = true;

  @override
  Widget build(BuildContext context) {
    print('build category');

    return ChangeNotifierProvider(
      create: (_) {
        var model = TreeModel();
        model.load();
        return model;
      },
      child: Selector<TreeModel, TreeModel>(
//        shouldRebuild: (pre, next) {
//          print("pre:${pre.length}, next:${next.length},_needRebuild:$_needRebuild");
//          return _needRebuild;
//        },
        shouldRebuild: (pre, next) => _needRebuild,
        selector: (context, provider) => provider,
        builder: (context, model, child) {
          if (model.length == 0) {
            _needRebuild = true;
            return _getLoading();
          } else {
            if (_needRebuild) {
              _needRebuild = false;
            }
            return _getCategory(model);
          }
        },
      ),
    );
  }

  Widget _getLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
          ),
          Text('数据加载中'),
        ],
      ),
    );
  }

  Widget _getCategory(TreeModel model) {
    return Consumer<TreeModel>(
      builder: (context, model, child) {
        print('build consumer dynamic (${model.currentHeader})');
        return Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                child: child,
              ),
              VerticalDivider(width: 1, color: Colors.grey),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio: 2.0),
                    itemBuilder: (context, index) {
                      var list = model.getChildren();
                      return Container(
                        color: Colors.green,
                        child: Center(
                          child: Text(
                            list[index].name,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                    itemCount: model.getChildren().length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: ListView.separated(
        itemBuilder: (context, index) {
          print('build list header');
          return GestureDetector(
            child: Container(
              height: 60,
              child: Center(
                child: Text(
                  model.headList[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            onTap: () {
              model.setCurrentHeader(model.headList[index]);
//              setState(() {
//                _mainCategoryIndex = model.headList[index];
//              });
            },
          );
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey),
        itemCount: model.length,
      ),
    );
  }
}
