class Common {
  static RegExp regExp = RegExp(r"</?\w+>?");
}

class BannerItem {
  final int id;
  final String title;
  final String imagePath;
  final String url;

  BannerItem(this.id, this.title, this.imagePath, this.url);

  static BannerItem create(Map<String, dynamic> map) {
    return BannerItem(map['id'], map['title'], map['imagePath'], map['url']);
  }
}

class ArticleItem {
  final int id;
  final String title;
  final int type;
  final String link;
  final String author;
  bool collect;
  final String desc;
  final String updateTime; //更新时间
  final String superChapterName; //一级类别

  ArticleItem(this.id, this.title, this.link, this.type, this.collect,
      this.author, this.desc, this.superChapterName, this.updateTime);

  static ArticleItem create(Map<String, dynamic> map) {
    String title = map['title'];
    String author = map['author'];
    if (author.isEmpty) {
      author = map['shareUser'];
    }
    String desc = (map['desc'] as String).replaceAll(Common.regExp, '');
    return ArticleItem(map['id'], title, map['link'], map['type'],
        map['collect'], author, desc, map['superChapterName'], map['niceDate']);
  }

  ArticleItem clone() {
    return ArticleItem(id, title, link, type, collect, author, desc,
        superChapterName, updateTime);
  }
}

class QuestionItem {
  final int id;
  final String title;
  final String author;
  final String desc;
  final bool collect;
  final String link;
  final String niceDate;

  QuestionItem(this.id, this.title, this.author, this.desc, this.collect,
      this.link, this.niceDate);

  static QuestionItem create(Map<String, dynamic> map) {
    String desc = (map['desc'] as String).replaceAll(Common.regExp, '');
    return QuestionItem(map['id'], map['title'], map['author'], desc,
        map['collect'], map['link'], map['niceDate']);
  }
}

class TreeChild {
  final int id;
  final String name;

  TreeChild(this.id, this.name);
}

class SquareItem {
  final String title;
  final String link;
  final String niceDate;
  bool collect = false;

  SquareItem(this.title, this.link, this.niceDate, this.collect);

  static SquareItem create(Map<String, dynamic> map) {
    return SquareItem(
        map['title'], map['link'], map['niceDate'], map['collect']);
  }
}
