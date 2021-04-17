import 'package:flutter/foundation.dart';

class CheckNewDataProvider with ChangeNotifier {
  String _token;

  void setToken(String t) {
    _token = t;
  }
}
