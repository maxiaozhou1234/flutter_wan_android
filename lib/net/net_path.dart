//服务器地址
const String Host = "https://www.wanandroid.com";
//banner
const String HomeBanner = "/banner/json";
//首页置顶文章
const String ArticleTop = "/article/top/json";

// 首页列表，需要传入 页码
//const String HomeList = "/article/list/0/json";
String getHomeList(int pageIndex) {
  return "/article/list/$pageIndex/json";
}

//问答，传入页码
String getQuestion(int pageIndex) {
  return "/wenda/list/$pageIndex/json";
}

//广场，传入页码
String getSquare(int pageIndex) {
  return "/user_article/list/$pageIndex/json";
}

//分类导航
const String Tree = '/tree/json';
