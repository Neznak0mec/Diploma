import 'package:abiba/Api.dart';
import 'package:abiba/UI/TranscriptionWidget/AudioTranscriptionWidget.dart';
import 'package:flutter/material.dart';
import '../../DataClasses/Audio.dart';
import 'package:intl/intl.dart';

import '../SnackBars/FlashMessageError.dart';


abstract class AudioWidget extends StatelessWidget {
  const AudioWidget({super.key});
}

class ShowAudioWidget extends AudioWidget {
  final MyAudio audio;
  final Function(Widget) updateMainWidget;

  const ShowAudioWidget(this.audio, this.updateMainWidget, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 120),
        decoration: BoxDecoration(
          color: audio.status == 1 ? Colors.blueAccent : Colors.redAccent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: GestureDetector(
          onTap: () async {
            if (audio.status == 0) {
              ScaffoldMessenger.of(context).showSnackBar(FlashMessageError("Аудио еще не обработано", context));
            }
            else {
              var transcription = await Api.getTranscription(audio.fileName);
              if (transcription == null) {
                ScaffoldMessenger.of(context).showSnackBar(FlashMessageError("Не удалось загрузить информацию", context) );
              } else {
                updateMainWidget(AudioTranscriptionWidget(transcription: transcription));
              }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                audio.radioName!,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateToString(audio.startRecording),
                    style:
                    const TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                  Text(
                    DateToString(audio.endRecording),
                    style:
                    const TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}



String DateToString(DateTime time) {
  DateFormat formatter = DateFormat('dd-MM-yyy HH:mm');
  return formatter.format(time);
}

