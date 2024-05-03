import 'package:flutter/material.dart';
import '../../Api.dart';
import '../DefaultWidgets/ErrPage.dart';
import 'RadioForm.dart';
import 'RadioWidget.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  RadioPageState createState() => RadioPageState();
}

class RadioPageState extends State<RadioPage> {
  Future<List<ShowRadioWidget>>? radiosFuture;

  @override
  void initState() {
    super.initState();
    radiosFuture = getRadiosAsWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RadioWidget>>(
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
            radios += snapshot.data!.cast<RadioWidget>();
            radios.add(AddRadioForm(this));

            return MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.count(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      crossAxisSpacing: 40.0,
                      mainAxisSpacing: 40.0,
                      childAspectRatio: 5,
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

  Future<List<ShowRadioWidget>> getRadiosAsWidgets() async {
    List<ShowRadioWidget> widgets = [];
    var radios = await Api.getRadioList();
    for (var i in radios) {
      widgets.add(ShowRadioWidget(i, this));
    }
    return widgets;
  }

  void removeRadioStation(ShowRadioWidget radio) {
    Api.removeRadioStation(radio.radio);
    Future.delayed(const Duration(milliseconds: 100), () {
      updateGrid();
    });
  }

  void addRadioStation(name, url) {
    Api.addRadioStation(name, url);
    Future.delayed(const Duration(milliseconds: 100), () {
      updateGrid();
    });
  }
}
