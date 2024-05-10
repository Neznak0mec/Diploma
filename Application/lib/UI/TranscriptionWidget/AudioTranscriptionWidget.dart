import 'package:abiba/Api.dart';
import 'package:abiba/DataClasses/Transcription.dart';
import 'package:flutter/material.dart';

import 'AudioPlayer.dart';

class AudioTranscriptionWidget extends StatelessWidget {
  final Transcription transcription;

  const AudioTranscriptionWidget({super.key, required this.transcription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Стенограмма'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildTimingText(),
                  ),
                ),
                const VerticalDivider(color: Colors.grey),
                // Серая линия для разделения зон
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildSchedule(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildAudioPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    String filename = transcription.fileName;
    String url = Api.getFileUrl(filename);

    return AudioPlayerPage(audioUrl: url);
  }

  Widget _buildTimingText() {
    List<Column> segments = [];
    for (var segment in transcription.segments) {
      List<ListTile> subSegments = [];
      for (var sub in segment.textSegments) {
        subSegments.add(ListTile(
          title: Text(sub.text),
          subtitle: Text(
              'Начало: ${((sub.start ?? 0) / 60).floor()}:${(sub.start ?? 0) % 60}, Конец: ${((sub.end ?? 0) / 60).floor()}:${(sub.end ?? 0) % 60}'),
        ));
      }

      segments.add(Column(
        children: [
          Text(
            segment.trackName == "Not Found"
                ? "Трек не найден"
                : segment.trackName,
            textScaler: const TextScaler.linear(2),
          ),
          ...subSegments
        ],
      ));
    }

    return ListView(children: [
      ListTile(
        title: const Text("Полный текст"),
        subtitle: Text(transcription.segments.map((e) => e.text).join(" ")),
      ),
      ...segments
    ]);
  }

  Widget _buildSchedule() {
    List<Event> events = [];

    for (var i in transcription.news) {
      events.add(Event(start: i.start, end: i.end, name: "Новости"));
    }

    for (var i in transcription.jingles) {
      events.add(Event(start: i, end: i, name: "Джинглы"));
    }

    events.sort((a, b) => (a.start ??= 0).compareTo(b.start ??= 0));

    return ListView(
      children: [
        const ListTile(
          title: Text("Расписание"),
        ),
        ...List.generate(events.length, (index) {
          final item = events[index];

          var timeText =
              "Начало: ${((item.start ?? 0) / 60).floor()}:${(item.start ?? 0) % 60}, Конец: ${((item.end ?? 0) / 60).floor()}:${(item.end ?? 0) % 60}";

          return ListTile(
            title: Text(item.name!),
            subtitle: Text(timeText),
          );
        }),
      ],
    );
  }
}

class Event {
  int? start;
  int? end;
  String? name;

  Event({required this.start, required this.end, required this.name});
}
