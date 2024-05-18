import 'package:abiba/Api.dart';
import 'package:abiba/DataClasses/Radio.dart';
import 'package:abiba/UI/FingerPrintWidgets/FingerPrintPage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../SnackBars/FlashMessageError.dart';

class AddFingerPrintWidget extends StatefulWidget {
  const AddFingerPrintWidget({super.key, required this.parent});

  final FingerPrintState parent;

  @override
  _AddFingerPrintWidgetState createState() =>
      _AddFingerPrintWidgetState(parent: parent);
}

class _AddFingerPrintWidgetState extends State<AddFingerPrintWidget> {
  final TextEditingController _nameController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? _filePath;
  String? _fileName;
  List<MyRadio> _radioList = [];

  bool isJingle = false;
  String? selectedRadio;

  final FingerPrintState parent;

  _AddFingerPrintWidgetState({required this.parent});

  @override
  void initState() {
    super.initState();
    loadRadioList();
  }

  Future<void> loadRadioList() async {
    // Load radio list asynchronously here
    List<MyRadio> radioList = await Api.getRadioList();
    setState(() {
      _radioList = radioList;
    });
  }

  void playAudio() async {
    if (_filePath != null) {
      await audioPlayer.play(DeviceFileSource(_filePath!));
    }
  }

  void pauseAudio() async {
    await audioPlayer.pause();
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _filePath = result.files.first.path;
      _fileName = result.files.first.name;
    });
  }

  void sendFile() async {
    if (_fileName != null) {
      if (isJingle) {
        if (selectedRadio == null) {
          var bar = FlashMessageError("Выберите радиостанцию", context);
          ScaffoldMessenger.of(context).showSnackBar(bar);
          return;
        }
        var res = await Api.sendJingleToServer(
            _nameController.text, _filePath!, selectedRadio!);
        if (res != 200) {
          var bar = FlashMessageError("Ошибка при отправке файла", context);
          ScaffoldMessenger.of(context).showSnackBar(bar);
          return;
        }
        parent.updateGrid();
      } else {
        var res = await Api.sendAudioToServer(_nameController.text, _filePath!);
        if (res != 200) {
          var bar = FlashMessageError("Ошибка при отправке файла", context);
          ScaffoldMessenger.of(context).showSnackBar(bar);
          return;
        }
        parent.updateGrid();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 500, maxHeight: 550),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      height: 500,
      width: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Имя",
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: isJingle,
                onChanged: (bool? value) {
                  setState(() {
                    isJingle = value!;
                  });
                },
              ),
              const Text('Джинл'),
              const Spacer(), // Spacer to push DropdownButton to the right
              if (isJingle) // Dropdown is only visible when the checkbox is checked
                DropdownButton<String>(
                  value: selectedRadio,
                  hint: const Text('Радиостанция'),
                  items: _radioList.map<DropdownMenuItem<String>>(
                    (MyRadio value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Text(value.name),
                      );
                    },
                  ).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRadio = newValue;
                    });
                  },
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: playAudio,
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: pauseAudio,
              ),
              IconButton(
                icon: const Icon(Icons.file_upload),
                onPressed: pickFile,
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendFile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
