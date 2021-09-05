import 'package:flutter/material.dart';

class CustomElevatedButton1 extends StatelessWidget {
  const CustomElevatedButton1({
    Key? key,
    @required this.child,
    this.color,
    this.minimumSize = const Size(350, 50),
    this.onPressed,
  }) : super(key: key);

  final Widget? child;
  final Color? color;
  final Size? minimumSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: ElevatedButton.styleFrom(
          minimumSize: minimumSize,
        ),
      ),
    );
  }
}
