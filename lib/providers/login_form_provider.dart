import 'package:flutter/foundation.dart';

class LoginFormProvider with ChangeNotifier {
  String? _email;
  String? _senha;
  bool _salvarLogin = false;

  String get email {
    return _email ?? '';
  }

  String get senha {
    return _senha ?? '';
  }

  bool get salvarLogin {
    return _salvarLogin;
  }

  void setEmail(String email) {
    _email = email;
  }

  void setSenha(String senha) {
    _senha = senha;
  }

  void setSalvarLogin(bool salvarLogin) {
    _salvarLogin = salvarLogin;
    notifyListeners();
  }

  bool validateInput() {
    if (_email != null && _senha != null) {
      return true;
    }
    return false;
  }
}
