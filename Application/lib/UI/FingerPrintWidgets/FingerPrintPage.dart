import 'package:abiba/DataClasses/Audio.dart';
import 'package:flutter/material.dart';
import '../../Api.dart';
import '../DefaultWidgets/ErrPage.dart';
import 'AddFingerPrintWidget.dart';
import 'FingerPrintWidget.dart';

class FingerPrintPage extends StatefulWidget {
  const FingerPrintPage({super.key});

  @override
  FingerPrintState createState() => FingerPrintState();
}

class FingerPrintState extends State<FingerPrintPage> {
  Future<List<FingerPrintWidget>>? fingerprintFuture;
  List<MyAudio> _fingerprints = [];

  String _radioName = "";
  List<String> _radioNames = [];
  bool _jingles = false;

  @override
  void initState() {
    super.initState();
    loadRadioList();
  }

  Future<void> loadRadioList() async {
    final radioNames = (await Api.getRadioList()).map((e) => e.name).toList();
    var fingerprints = getFingerprintAsWidgets();
    var fingerprintsList = await Api.getFingerprintsList();
    setState(() {
      _radioNames = radioNames;
      fingerprintFuture = fingerprints;
      _fingerprints = fingerprintsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<FingerPrintWidget>>(
        future: fingerprintFuture,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
              List<Widget> radios = [
                AddFingerPrintWidget(parent: this),
                ...snapshot.data!.cast<FingerPrintWidget>(),
              ];

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _jingles,
                          onChanged: (bool? value) {
                            setState(() {
                              _jingles = value!;
                            });
                            updateGrid();
                          },
                        ),
                        const Text('Джинл'),
                        const Spacer(),
                        if (_jingles)
                          DropdownButton<String>(
                            value: _radioNames[0],
                            hint: const Text('Радиостанция'),
                            items: _radioNames.map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _radioName = newValue!;
                              });
                              updateGrid();
                            },
                          )
                      ],
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _calculateCrossAxisCount(context),
                          crossAxisSpacing: 20.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: 2,
                        ),
                        itemCount: radios.length,
                        itemBuilder: (context, index) {
                          return radios[index];
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }

  void updateGrid() {
    setState(() {
      fingerprintFuture = getFingerprintAsWidgets();
    });
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemWidth = 400;
    const spacing = 20.0;
    final crossAxisCount =
        ((screenWidth - spacing) / (itemWidth + spacing)).floor();
    return crossAxisCount;
  }

  Future<List<FingerPrintWidget>> getFingerprintAsWidgets() async {
    List<FingerPrintWidget> widgets = [];
    for (var i in _fingerprints) {
      if (_jingles && (i.status == 20 || i.status == 21)) {
        if (_radioName == "" ) {
          widgets.add(FingerPrintWidget(i));
        }
        else if (i.radioName == _radioName) {
          widgets.add(FingerPrintWidget(i));
        }
      }
      else if (!_jingles){
        widgets.add(FingerPrintWidget(i));
      }
    }
    return widgets;
  }
}
