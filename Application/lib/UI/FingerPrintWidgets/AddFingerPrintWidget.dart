import 'package:abiba/Api.dart';
import 'package:abiba/UI/FingerPrintWidgets/FingerPrintPage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

//finger print widget. Contains 2 inputs for name and file picker for audio file. Then with using api send file to server
class AddFingerPrintWidget extends StatefulWidget {
  const AddFingerPrintWidget({super.key, required this.parent});

  final FingerPrintState parent;

  @override
  _AddFingerPrintWidgetState createState() => _AddFingerPrintWidgetState(parent: parent);
}

class _AddFingerPrintWidgetState extends State<AddFingerPrintWidget> {
  final TextEditingController _nameController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? _filePath;
  String? _fileName;

  final FingerPrintState parent;

  _AddFingerPrintWidgetState({required this.parent});

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
      var res = await Api.sendAudioToServer(_nameController.text, _filePath!);
      if (res != 200){
        //todo err message
        return;
      }
      parent.updateGrid();
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
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
