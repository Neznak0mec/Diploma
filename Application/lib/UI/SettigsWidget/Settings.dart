// This file contains the code for the settings page of the app
// use input to save in configuration file api url
// use checkbox to save in configuration file if the user wants to see audio founed in internet

import 'package:flutter/material.dart';
import '../../Api.dart';
import '../../Settings.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  final MyHomePageState parent;

  const SettingsPage({required this.parent, super.key});

  @override
  RadioPageState createState() => RadioPageState(parent: parent);
}

class RadioPageState extends State<SettingsPage> {
  final MyHomePageState parent;
  final TextEditingController _controller = TextEditingController();
  bool _internetAudio = false;

  RadioPageState({required this.parent});

  @override
  void initState() {
    super.initState();

    _controller.text = SettingsService.API_URL;
    _internetAudio = SettingsService.INTERNET_AUDIO;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Tекущий URL сервера',
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    //check if the url is valid with uising ping
                    if (await Api.checkServer(_controller.text)) {
                      //save the url in configuration file
                      SettingsService.setApiUrl(_controller.text);
                      Api.baseUrl = _controller.text;
                    } else {
                      //show error message
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Ошибка"),
                            content: const Text("Сервер не найден"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text("Сохранить"),
                ),
              ],
            ),
            const Divider(
              height: 5,
              color: Colors.black,
            ),
            Row(
              children: [
                Checkbox(
                  value: _internetAudio,
                  onChanged: (bool? value) {
                    setState(() {
                      _internetAudio = value!;
                    });
                    SettingsService.setInternetAudio(value!);
                  },
                ),
                const Text("Показывать аудио из интернета"),
              ],
            ),
            const Divider(
              height: 5,
              color: Colors.black,
            ),
            Row(
              children: [
                RadioRecordWidget(parent: parent),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RadioRecordWidget extends StatefulWidget {
  final MyHomePageState parent;

  const RadioRecordWidget({required this.parent, super.key});

  @override
  RadioRecordPageState createState() => RadioRecordPageState(parent: parent);
}

class RadioRecordPageState extends State<RadioRecordWidget> {
  final MyHomePageState parent;
  Map<String, bool> _radioRecording = {};

  RadioRecordPageState({required this.parent});

  @override
  void initState() {
    super.initState();
    _updateRadioRecording();
  }

  void _updateRadioRecording() async {
    var res = await Api.radioRecordingStats();
    setState(() {
      _radioRecording = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Text("Сейчас записывается ${_radioRecording.length} радиостанций")
        ]),
        Row(children: [
          ElevatedButton(
            onPressed: () async {
              await Api.stopAllRecordings();
              _updateRadioRecording();
            },
            child: const Text("Остановить все"),
          ),
          ElevatedButton(
            onPressed: () async {
              await Api.startAllRecordings();
              _updateRadioRecording();
            },
            child: const Text("Запустить все"),
          )
        ]),
        RadioRecordingCheckboxes(parent: parent),
      ],
    );
  }
}

//wideget to split radio recording
//create like this
//for (var i in _radioRecording.keys)
//           Row(
//
//             children: [
//               Checkbox(
//                 value: _radioRecording[i],
//                 onChanged: (bool? value) async {
//                   if (value!) {
//                     await Api.startRecording(i);
//                   } else {
//                     await Api.stopRecording(i);
//                   }
//                   _updateRadioRecording();
//                 },
//               ),
//               Text(i),
//             ],
//           ),
//split all into 2 columns
//use column to split all into 2 columns

class RadioRecordingCheckboxes extends StatefulWidget {
  final MyHomePageState parent;

  const RadioRecordingCheckboxes({required this.parent, super.key});

  @override
  RadioRecordingCheckboxesState createState() =>
      RadioRecordingCheckboxesState(parent: parent);
}

class RadioRecordingCheckboxesState extends State<RadioRecordingCheckboxes> {
  final MyHomePageState parent;
  Map<String, bool> _radioRecording = {};

  RadioRecordingCheckboxesState({required this.parent});

  @override
  void initState() {
    super.initState();
    _updateRadioRecording();
  }

  void _updateRadioRecording() async {
    var res = await Api.radioRecordingStats();
    setState(() {
      _radioRecording = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    var leftColumn = <Widget>[];
    var rightColumn = <Widget>[];
    for (var i in _radioRecording.keys) {
      if (_radioRecording.keys.toList().indexOf(i) % 2 == 0) {
        leftColumn.add(
          Row(
            children: [
              Checkbox(
                value: _radioRecording[i],
                onChanged: (bool? value) async {
                  if (value!) {
                    await Api.startRecording(i);
                  } else {
                    await Api.stopRecording(i);
                  }
                  _updateRadioRecording();
                },
              ),
              Text(i),
            ],
          ),
        );
      } else {
        rightColumn.add(
          Row(
            children: [
              Checkbox(
                value: _radioRecording[i],
                onChanged: (bool? value) async {
                  if (value!) {
                    await Api.startRecording(i);
                  } else {
                    await Api.stopRecording(i);
                  }
                  _updateRadioRecording();
                },
              ),
              Text(i),
            ],
          ),
        );
      }
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: leftColumn,
            ),

            Column(
              children: rightColumn,
            ),
          ],
        ),
      ],
    );
  }
}
