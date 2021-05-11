import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermosScreen extends StatefulWidget {
  @override
  _TermosScreenState createState() => _TermosScreenState();
}

class _TermosScreenState extends State<TermosScreen> {
  String termos = '';
  double height = 0;
  @override
  void didChangeDependencies() async {
    termos = await rootBundle.loadString('assets/texts/termos.txt');
    setState(() {});

    double width = MediaQuery.of(context).size.width;

    if (width < 400) {
      height = 4500;
    } else if (width < 800) {
      height = 3500;
    } else if (width < 1300) {
      height = 2150;
    } else {
      height = 1800;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: Scrollbar(
        thickness: 15,
        isAlwaysShown: true,
        showTrackOnHover: true,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 30, 20),
            height: height,
            child: Column(
              children: [
                Text(termos),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
