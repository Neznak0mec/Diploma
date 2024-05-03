import 'package:abiba/UI/FingerPrintWidgets/AddFingerPrintWidget.dart';
import 'package:flutter/material.dart';
import '../../Api.dart';
import '../DefaultWidgets/ErrPage.dart';
import 'FingerPrintWidget.dart';

class FingerPrintPage extends StatefulWidget {
  const FingerPrintPage({super.key});

  @override
  FingerPrintState createState() => FingerPrintState();
}

class FingerPrintState extends State<FingerPrintPage> {
  Future<List<FingerPrintWidget>>? radiosFuture;

  @override
  void initState() {
    super.initState();
    radiosFuture = getRadiosAsWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FingerPrintWidget>>(
      future: radiosFuture,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ErrPage(
            errorText: "Не удалось подключиться к серверу",
          );
        } else {
          if (_calculateCrossAxisCount(context) < 1) {
            return ErrPage(
              errorText: "Слишком малый размер окна",
            );
          } else {
            List<Widget> radios = [];

            radios += snapshot.data!.cast<FingerPrintWidget>();
            radios.add(AddFingerPrintWidget(parent: this));

            return MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.count(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      crossAxisSpacing: 40.0,
                      mainAxisSpacing: 40.0,
                      childAspectRatio: 2,
                      children: radios),
                ),
              ),
            );
          }
        }
      },
    );
  }

  void updateGrid() {
    setState(() {
      radiosFuture = getRadiosAsWidgets();
    });
  }

  _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemWidth = 400;
    const spacing = 20.0;
    final crossAxisCount =
        ((screenWidth - spacing) / (itemWidth + spacing)).floor();
    return crossAxisCount;
  }

  Future<List<FingerPrintWidget>> getRadiosAsWidgets() async {
    List<FingerPrintWidget> widgets = [];
    var radios = await Api.getFingerprintsList();
    for (var i in radios) {
      widgets.add(FingerPrintWidget(i));
    }
    return widgets;
  }
}
