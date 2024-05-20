import 'package:flutter/material.dart';
import '../../Api.dart';
import '../../DataClasses/Audio.dart';
import '../../main.dart';
import '../DefaultWidgets/ErrPage.dart';
import 'AudioWidget.dart';
import 'SelectRadioWidget.dart';

class AudioPage extends StatefulWidget {
  final MyHomePageState parent;

  const AudioPage({required this.parent, super.key});

  @override
  AudioPageState createState() => AudioPageState(parent: parent);
}

class AudioPageState extends State<AudioPage> {
  SortingParams params = SortingParams();
  Future<List<ShowAudioWidget>>? radiosFuture;
  String? dropdownValue;
  final MyHomePageState parent;

  AudioPageState({required this.parent});

  @override
  void initState() {
    super.initState();
    radiosFuture = getRadiosAsWidgets();
    dropdownValue ??= "all";
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
                        SelectRadioWidget(parent: this),
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
                          child: const Text('Начало записи'),
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
                          child: const Text('Конец записи'),
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
    for (var radio in radiosTemp) {
      radios.add(radio.name);
    }
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
