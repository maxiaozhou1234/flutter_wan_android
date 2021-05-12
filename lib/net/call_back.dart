import 'package:http/http.dart';

typedef OnSuccess = void Function(Response response);
typedef OnError = void Function(Exception error);
typedef Done = void Function();

class Callback {
  final OnSuccess onSuccess;
  OnError onError;
  Done done;

  Callback(this.onSuccess, {OnError onError, Done done}) {
    this.onError = onError;
    this.done = done;
  }
}
