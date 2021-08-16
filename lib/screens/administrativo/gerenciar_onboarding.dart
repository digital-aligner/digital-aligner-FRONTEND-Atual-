import 'dart:convert';

import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/rotas_url.dart';
import 'package:digital_aligner_app/screens/administrativo/onboarding_form.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FetchState {
  idle,
  Fetching,
  Done,
  error,
}

class GerenciarOnboarding extends StatefulWidget {
  static const routeName = '/gerenciar-onboarding';
  @override
  _GerenciarOnboardingState createState() => _GerenciarOnboardingState();
}

class _GerenciarOnboardingState extends State<GerenciarOnboarding> {
  late AuthProvider _authStore;
  Map<String, dynamic> _onboardingData = {};
  FetchState _fetchState = FetchState.idle;

  //form variables
  int _onboardingBr = 0;
  int _onboardingPt = 0;

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    if (_fetchState == FetchState.idle) {
      _fetchOnboarding();
    }
    super.didChangeDependencies();
  }

  Future<void> _fetchOnboarding() async {
    setState(() {
      _fetchState = FetchState.Fetching;
    });
    try {
      var _response = await http.get(
        Uri.parse(RotasUrl.rotaOnboardingV1),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore.token}',
        },
      );
      Map<String, dynamic> data = json.decode(_response.body);

      if (data.containsKey('id')) {
        setState(() {
          _onboardingData = data;
          _onboardingBr = data['onboarding_br'];
          _onboardingPt = data['onboarding_pt'];
          _fetchState = FetchState.Done;
        });
      } else {
        throw 'Algo deu errado, tente novamente';
      }
    } catch (e) {
      setState(() {
        _fetchState = FetchState.error;
      });
      print(e);
    }
  }

  Future<void> _updateOnboarding() async {
    setState(() {
      _fetchState = FetchState.Fetching;
    });
    try {
      var _response = await http.put(
        Uri.parse(RotasUrl.rotaOnboardingV1),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore.token}',
        },
        body: json.encode({
          'onboarding_br': _onboardingBr,
          'onboarding_pt': _onboardingPt,
        }),
      );
      var data = json.decode(_response.body);

      if (data.containsKey('id')) {
        setState(() {
          _onboardingData = data;
          _onboardingBr = data['onboarding_br'];
          _onboardingPt = data['onboarding_pt'];
          _fetchState = FetchState.Done;
        });
        _showMsg(text: 'Onboarding atualizado!');
      } else {
        print(data);
        throw 'Algo deu errado, tente novamente';
      }
    } catch (e) {
      setState(() {
        _fetchState = FetchState.error;
      });
      print(e);
    }
  }

  void _showMsg({required String text}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 5),
      content: Text(text),
    ));
  }

  Widget _sendButton() {
    return ElevatedButton(
      onPressed: _fetchState == FetchState.Done
          ? () {
              _updateOnboarding();
            }
          : null,
      child: Text(
        'Atualizar',
        style: TextStyle(
          color: Theme.of(context).textTheme.button?.color,
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Center(
      child: Text(
        'Gerenciar Onboarding',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }

  Widget _buildOnboardingInfo() {
    return const Text(
      'Altere o onboarding atual de Brasil e Portugal abaixo. Novos cadastros usarão esses valores.',
    );
  }

  Widget _buildFormBrasil() {
    return OnboardingForm(
      labelText: 'Onboarding Brasil #: *',
      initialValue: _onboardingBr,
      onboardingChanged: (value) {
        _onboardingBr = value;
      },
    );
  }

  Widget _buildFormPt() {
    return OnboardingForm(
      labelText: 'Onboarding Portugal #: *',
      initialValue: _onboardingPt,
      onboardingChanged: (value) {
        _onboardingPt = value;
      },
    );
  }

  Widget _buildUi() {
    return RawScrollbar(
      radius: Radius.circular(10),
      thumbColor: Colors.grey,
      thickness: 15,
      isAlwaysShown: true,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40),
          height: 800,
          child: Column(
            children: [
              _buildHeadline(),
              const SizedBox(height: 40),
              _buildOnboardingInfo(),
              const SizedBox(height: 40),
              _buildFormBrasil(),
              const SizedBox(height: 40),
              _buildFormPt(),
              const SizedBox(height: 40),
              _sendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildDrawer() {
    if (MediaQuery.of(context).size.width < 1200) {
      return MyDrawer();
    }
  }

  Widget _handleUiStateBuild() {
    if (_fetchState == FetchState.Done) {
      return _buildUi();
    } else if (_fetchState == FetchState.error) {
      return Center(
          child: const Text('Erro ao buscar dados. Tente novamente.'));
    } else {
      return Center(child: const CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authStore.isAuth) {
      return LoginScreen(
        showLoginMessage: true,
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: MyAppBar(),
        drawer: _buildDrawer(),
        body: _handleUiStateBuild(),
      ),
    );
  }
}
