import 'package:abiba/DataClasses/Audio.dart';
import 'package:abiba/UI/AudioWidgets/AudioWidget.dart';
import 'package:abiba/UI/DefaultWidgets/ErrPage.dart';
import 'package:abiba/main.dart';
import 'package:flutter/material.dart';
import '../../Api.dart';

class AudioPage extends StatefulWidget {
  final MyHomePageState parent;

  AudioPage({required this.parent, Key? key}) : super(key: key);

  @override
  AudioPageState createState() => AudioPageState(parent: parent);
}

class AudioPageState extends State<AudioPage> {
  SortingParams params = SortingParams();
  Future<List<ShowAudioWidget>>? radiosFuture;
  String dropdownValue = "all";
  final MyHomePageState parent;

  AudioPageState({required this.parent});

  @override
  void initState() {
    super.initState();
    radiosFuture = getRadiosAsWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioWidget>>(
      future: radiosFuture,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ErrPage(errorText: "Не удалось подключиться к серверу");
        } else {
          List<Widget> radios = snapshot.data!.cast<AudioWidget>();

          if (_calculateCrossAxisCount(context) < 1) {
            return ErrPage(
              errorText: "Слишком малый размер окна",
            );
          } else {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: FutureBuilder<List<String>>(
                                future: getRadios(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<String>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return DropdownButton<String>(
                                      value: dropdownValue,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? value) {
                                        if (value == "all") {
                                          params.radioName = null;
                                        } else {
                                          params.radioName = value;
                                        }
                                        setState(() {
                                          dropdownValue = value!;
                                        });
                                        updateGrid();
                                      },
                                      items: snapshot.data!
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              )),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  params.startRecording ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2050),
                            );
                            if (date != null) {
                              setState(() {
                                params.startRecording = date;
                              });
                              updateGrid();
                            }
                          },
                          child: Text('Начало записи'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  params.endRecording ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2050),
                            );
                            if (date != null) {
                              setState(() {
                                params.endRecording = date;
                              });
                              updateGrid();
                            }
                          },
                          child: Text('Конец записи'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GridView.count(
                          crossAxisCount: _calculateCrossAxisCount(context),
                          crossAxisSpacing: 40.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: 2,
                          children: radios,
                        ),
                      ),
                    ),
                  ],
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

  Future<List<String>> getRadios() async {
    var radiosTemp = await Api.getRadioList();
    List<String> radios = ['all'];
    radiosTemp.map((e) => radios.add(e.name));
    dropdownValue = radios.first;
    return radios;
  }

  _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemWidth = 400;
    const spacing = 20.0;
    final crossAxisCount =
        ((screenWidth - spacing) / (itemWidth + spacing)).floor();
    return crossAxisCount;
  }

  Future<List<ShowAudioWidget>> getRadiosAsWidgets() async {
    List<ShowAudioWidget> widgets = [];
    List<MyAudio> radios = [];
    if (params.radioName != null) {
      radios = await Api.getAudioList(params.radioName!);
    } else {
      radios = await Api.getAllAudioList();
    }

    if (params.startRecording != null) {
      radios = radios
          .where((element) =>
              element.startRecording.compareTo(params.startRecording!) >= 0)
          .toList();
    }

    if (params.endRecording != null) {
      radios = radios
          .where((element) =>
              element.endRecording.compareTo(params.endRecording!) <= 0)
          .toList();
    }

    for (var radio in radios) {
      widgets.add(ShowAudioWidget(radio, parent.updateMainWidget));
    }
    return widgets;
  }
}

class SortingParams {
  String? radioName;
  DateTime? startRecording;
  DateTime? endRecording;
}
