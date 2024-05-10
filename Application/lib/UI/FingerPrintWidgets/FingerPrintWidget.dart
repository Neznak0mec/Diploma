import 'package:abiba/Api.dart';
import 'package:abiba/DataClasses/Audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class FingerPrintWidget extends StatefulWidget {
  final MyAudio audio;

  const FingerPrintWidget(this.audio, {super.key});

  @override
  _FingerPrintWidgetState createState() => _FingerPrintWidgetState();
}

class _FingerPrintWidgetState extends State<FingerPrintWidget> {
  AudioPlayer audioPlayer = AudioPlayer();

  void playAudio() async {
    await audioPlayer.play(UrlSource(Api.getFingerprintUrl(widget.audio.fileName))); // Replace 'URL' with your audio file URL
  }

  void pauseAudio() async {
    await audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120, maxHeight: 120),
      decoration: BoxDecoration(
        color: widget.audio.status == 11 ? Colors.blueAccent : Colors.redAccent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.audio.fileName,
            style: const TextStyle(
                fontSize: 16.0, fontWeight: FontWeight.bold),
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
            ],
          ),
        ],
      ),
    );
  }
}