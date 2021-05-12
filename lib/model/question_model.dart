import 'package:dance/bean/bean.dart';
import 'package:dance/net/net_repository.dart';
import 'package:flutter/material.dart';

class QuestionModel with ChangeNotifier {
  var repository = NetRepository();

  void load() {
    if (size == 0) {
      repository.refreshQuestion(model: this);
    }
  }

  void requestDone() {
    print('question request done...');
    notifyListeners();
  }

  void refresh() {
    repository.refreshQuestion(model: this);
  }

  void loadNext() {
    repository.loadMoreQuestion(model: this);
  }

  int get size => repository.questions.length;

  bool get loadMoreEnable => repository.loadMoreQuestionEnable;

  List<QuestionItem> get questions => repository.questions;
}
