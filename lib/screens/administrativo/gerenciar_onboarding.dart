import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/screens/administrativo/onboarding_form.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GerenciarOnboarding extends StatefulWidget {
  static const routeName = '/gerenciar-onboarding';
  @override
  _GerenciarOnboardingState createState() => _GerenciarOnboardingState();
}

class _GerenciarOnboardingState extends State<GerenciarOnboarding> {
  late AuthProvider _authStore;

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    super.didChangeDependencies();
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
      'Altere onboarding atual de Brasil e Portugal abaixo',
    );
  }

  Widget _buildFormBrasil() {
    return OnboardingForm(
      labelText: 'Onboarding Brasil #: *',
      initialValue: 0,
      onboardingChanged: (value) {},
    );
  }

  Widget _buildFormPt() {
    return OnboardingForm(
      labelText: 'Onboarding Portugal #: *',
      initialValue: 0,
      onboardingChanged: (value) {},
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
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildDrawer() {
    MediaQuery.of(context).size.width < 1200 ? MyDrawer() : null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_authStore.isAuth) {
      return LoginScreen(
        showLoginMessage: true,
      );
    }

    return Scaffold(
      appBar: MyAppBar(),
      drawer: _buildDrawer(),
      body: _buildUi(),
    );
  }
}
