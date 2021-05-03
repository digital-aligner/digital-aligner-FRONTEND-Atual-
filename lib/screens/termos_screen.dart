import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermosScreen extends StatefulWidget {
  @override
  _TermosScreenState createState() => _TermosScreenState();
}

class _TermosScreenState extends State<TermosScreen> {
  String termos = '';
  @override
  void didChangeDependencies() async {
    termos = await rootBundle.loadString('assets/texts/termos.txt');
    setState(() {});

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: Container(
        child: Text(termos),
      ),
    );
  }
}
