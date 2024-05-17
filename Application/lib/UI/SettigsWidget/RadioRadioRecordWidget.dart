

import 'package:flutter/material.dart';

import '../../Api.dart';
import '../../main.dart';
import '../SnackBars/FlashMessageSuccess.dart';

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
              var snackBar = FlashMessageSuccess("Все радиостанции будут остановлены при завершении записи последнего сегмента", context);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              _updateRadioRecording();
            },
            child: const Text("Остановить все"),
          ),
          ElevatedButton(
            onPressed: () async {
              await Api.startAllRecordings();
              var snackBar = FlashMessageSuccess("Все радиостанции будут остановлены при завершении записи последнего сегмента", context);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                  var snackBar;
                  if (value!) {
                    await Api.startRecording(i);
                    snackBar = FlashMessageSuccess("Запись $i начата", context);
                  } else {
                    snackBar = FlashMessageSuccess("Запись $i будет остановлена при завершении записи последнего сегмента", context);
                    await Api.stopRecording(i);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                  FlashMessageSuccess snackBar;
                  if (value!) {
                    snackBar = FlashMessageSuccess("Запись $i начата", context);
                    await Api.startRecording(i);
                  } else {
                    snackBar = FlashMessageSuccess("Запись $i будет остановлена при завершении записи последнего сегмента", context);
                    await Api.stopRecording(i);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
