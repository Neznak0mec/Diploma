// This file contains the code for the settings page of the app
// use input to save in configuration file api url
// use checkbox to save in configuration file if the user wants to see audio founed in internet

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import '../../Api.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  final MyHomePageState parent;

  SettingsPage({required this.parent, Key? key}) : super(key: key);

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
    if (GlobalConfiguration().getValue("api_url") == null) {
      GlobalConfiguration().add({
        "api_url": "",
      });
    }
    if (GlobalConfiguration().getValue("internet_audio") == null) {
      GlobalConfiguration().add({
        "internet_audio": true,
      });
    }

    _controller.text = GlobalConfiguration().getValue("api_url") as String;
    _internetAudio = GlobalConfiguration().getValue("internet_audio") as bool;
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
                      GlobalConfiguration().updateValue("api_url", _controller.text);
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
            Row(
              children: [
                Checkbox(
                  value: _internetAudio,
                  onChanged: (bool? value) {
                    setState(() {
                      _internetAudio = value!;
                    });
                    GlobalConfiguration().updateValue("internet_audio", value);
                  },
                ),
                const Text("Показывать аудио из интернета"),
              ],
            ),
          ],
        ),
      ),
    );
  }

}


