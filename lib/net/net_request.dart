import 'dart:convert';

import 'package:http/http.dart' as http;

import 'call_back.dart';

class NetRequest {
  static http.BaseClient _client;
  static String _baseUrl;

  static void init(String base) {
    if (base.endsWith("/")) {
      _baseUrl = base.substring(0, base.length - 1);
    } else {
      _baseUrl = base;
    }
    _client = http.Client();
  }

  static http.BaseClient getClient() => _client;

  static void send(String path, Callback callback,
      {Map<String, String> params, Map<String, String> headers}) async {
    String url;
    String _params = "";
    if (params != null && params.isNotEmpty) {
      if (!path.endsWith("?")) {
        _params = "?";
      }
      params.forEach((k, v) {
        _params += "$k=${Uri.encodeQueryComponent(v)}";
      });
    }

    if (path.toLowerCase().startsWith("http")) {
      url = "$path$_params";
    } else {
      url = "$_baseUrl$path$_params";
    }

    Uri uri = Uri.parse(url);
    print(uri.path);
//    await _client.get(uri, headers: headers);
    await _client.get(uri, headers: headers).then((response) {
      callback.onSuccess(response);
    }).catchError((onError) {
      print(onError);
      callback.onError?.call(onError);
    });
    callback.done?.call();
  }

  static Future<http.Response> post(String path, Object body,
      {Map<String, String> headers, Encoding encoding = utf8}) async {
    String url = "$_baseUrl$path";
    Uri uri = Uri.parse(url);
    return await _client.post(uri,
        headers: headers, body: body, encoding: encoding);
  }
}
