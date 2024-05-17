// This file contains the code for the settings page of the app
// use input to save in configuration file api url
// use checkbox to save in configuration file if the user wants to see audio founed in internet

import 'package:flutter/material.dart';
import '../../Api.dart';
import '../../Settings.dart';
import '../../main.dart';
import '../SnackBars/FlashMessageSuccess.dart';
import 'RadioRadioRecordWidget.dart';

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
                      var snackBar = FlashMessageSuccess("Сервер установлен", context);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

