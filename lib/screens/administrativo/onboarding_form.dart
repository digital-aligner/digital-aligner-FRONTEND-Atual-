import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingForm extends StatefulWidget {
  final int initialValue;
  final Function(int) onboardingChanged;
  final String labelText;

  const OnboardingForm({
    required this.initialValue,
    required this.onboardingChanged,
    required this.labelText,
  });

  @override
  _OnboardingFormState createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final _onboardingController = TextEditingController();

  @override
  void initState() {
    _onboardingController.text = widget.initialValue.toString();
    super.initState();
  }

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }

  bool isTextValid() {
    if (_onboardingController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Widget _buildOnboardingForm() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (int.parse(_onboardingController.text) > 0) {
                  _onboardingController.text =
                      (int.parse(_onboardingController.text) - 1).toString();
                }
                widget.onboardingChanged(int.parse(_onboardingController.text));
              },
              icon: const Icon(Icons.minimize),
            ),
            Expanded(
              child: TextFormField(
                enabled: true,
                controller: _onboardingController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  //To hide cpf length num
                  counterText: '',
                  labelText: widget.labelText,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _onboardingController.text =
                    (int.parse(_onboardingController.text) + 1).toString();
                widget.onboardingChanged(int.parse(_onboardingController.text));
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildOnboardingForm(),
    );
  }
}
