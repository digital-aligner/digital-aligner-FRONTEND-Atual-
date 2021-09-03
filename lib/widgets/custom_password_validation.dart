import 'package:flutter/material.dart';

import 'custom_password_check_requirements.dart';

class CustomPasswordValidatedFields extends StatefulWidget {
  /// Password `validation` is given at the bottom which can be `modified` accordingly.
  /// Full package can be modified easily
  /// on saved callback
  void Function(String?)? onSaved;

  final double fieldAndValidationSpacing;

  /// Input decoration of Text field by default it is OutlineInputBorder
  final InputDecoration? inputDecoration;

  /// textEditingController for the field
  final TextEditingController? textEditingController;

  /// textInputAction for the field. By default its set to [done]
  final TextInputAction? textInputAction;

  /// onEditComplete callBack for the field
  final void Function()? onEditComplete;

  /// onFieldSubmitted callBack for the field
  final String Function(String)? onFieldSubmitted;

  /// focusNode for the field
  final FocusNode? focusNode;

  /// cursorColor
  final Color? cursorColor;

  /// textStyle of the Text in field
  final TextStyle? textStyle;

  /// Password requirements attributes
  /// iconData for the icons when requirement is completed
  final IconData? activeIcon;

  /// iconData for the icons when the requirement is incomplete/inActive
  final IconData? inActiveIcon;

  /// color of the text when requirement is completed
  final Color? activeRequirementColor;

  /// color of the text when the requirement is not completed/inActive
  final Color? inActiveRequirementColor;

  /// Constructor
  CustomPasswordValidatedFields({
    Key? key,
    this.onSaved,
    this.fieldAndValidationSpacing = 10,

    /// [default inputDecoration]
    this.inputDecoration = const InputDecoration(
        hintText: "Enter password",
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder()),
    this.textEditingController,

    /// [default textInputAction]
    this.textInputAction = TextInputAction.done,
    this.onEditComplete,
    this.onFieldSubmitted,
    this.focusNode,
    this.cursorColor,
    this.textStyle,

    /// Password requirements initialization
    /// [default inActiveIcon]
    this.inActiveIcon = Icons.check_circle_outline_rounded,

    /// [default activeIcon]
    this.activeIcon = Icons.check_circle_rounded,

    /// [default inActive Color]
    this.inActiveRequirementColor = Colors.grey,

    /// [default active color]
    this.activeRequirementColor = Colors.blue,
  }) : super(key: key);

  @override
  _CustomPasswordValidatedFieldsState createState() =>
      _CustomPasswordValidatedFieldsState();
}

class _CustomPasswordValidatedFieldsState
    extends State<CustomPasswordValidatedFields> {
  String _pass = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// [Password TextFormField]
          /// Use `Form` to validate the field easily

          TextFormField(
            onSaved: widget.onSaved,
            textInputAction: widget.textInputAction,
            controller: widget.textEditingController,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: widget.inputDecoration,
            onEditingComplete: widget.onEditComplete,
            onFieldSubmitted: widget.onFieldSubmitted,
            focusNode: widget.focusNode,
            cursorColor: widget.cursorColor,
            style: widget.textStyle,
            onChanged: (value) {
              setState(() {
                _pass = value;
                print(_pass);
              });
            },
            validator: passwordValidation,
          ),
          SizedBox(height: widget.fieldAndValidationSpacing),

          /// [default requirements]
          /// `1 Upper case` requirement
          CustomPassCheckRequirements(
            passCheck: _pass.contains(RegExp(r'[A-Z]')),
            requirementText: "1 maiúsculo [A-Z]",
            activeColor: widget.activeRequirementColor,
            inActiveColor: widget.inActiveRequirementColor,
            inActiveIcon: widget.inActiveIcon,
            activeIcon: widget.activeIcon,
          ),

          /// `1 lowercase` requirement
          CustomPassCheckRequirements(
            passCheck: _pass.contains(RegExp(r'[a-z]')),
            requirementText: "1 minúsculo [a-z]",
            activeColor: widget.activeRequirementColor,
            inActiveColor: widget.inActiveRequirementColor,
            inActiveIcon: widget.inActiveIcon,
            activeIcon: widget.activeIcon,
          ),

          /// `1 numeric value` requirement
          CustomPassCheckRequirements(
            passCheck: _pass.contains(RegExp(r'[0-9]')),
            requirementText: "1 valor numérico [0-9]",
            activeColor: widget.activeRequirementColor,
            inActiveColor: widget.inActiveRequirementColor,
            inActiveIcon: widget.inActiveIcon,
            activeIcon: widget.activeIcon,
          ),

          /// `1 special character` requirement
          CustomPassCheckRequirements(
            passCheck: _pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
            requirementText: "1 caractere especial [#, \$, % etc..]",
            activeColor: widget.activeRequirementColor,
            inActiveColor: widget.inActiveRequirementColor,
            inActiveIcon: widget.inActiveIcon,
            activeIcon: widget.activeIcon,
          ),

          /// `6 character length` requirement
          CustomPassCheckRequirements(
            passCheck: _pass.length >= 6,
            requirementText: "6 caracteres",
            activeColor: widget.activeRequirementColor,
            inActiveColor: widget.inActiveRequirementColor,
            inActiveIcon: widget.inActiveIcon,
            activeIcon: widget.activeIcon,
          ),
        ],
      ),
    );
  }

  /// [password validation]
  /// 1 Uppercase
  /// 1 lowercase
  /// 1 numeric value
  /// 1 special character
  /// 6 length password

  /// In case you want to `modify` the requirements change the `RegExp` given below
  String? passwordValidation(String? value) {
    bool passValid =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$')

            /// [RegExp]
            .hasMatch(value!);
    if (value.isEmpty) {
      return "A senha não pode estar vazia!";
    } else if (!passValid) {
      return "Verifique os requisitos!";
    }
    return null;
  }
}
