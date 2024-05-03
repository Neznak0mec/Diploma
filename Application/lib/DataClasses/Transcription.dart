
class RadioSegment {
  String trackName;
  int start;
  int end;
  String text;
  List<TextSegment> textSegments;

  RadioSegment(
      {required this.trackName, required this.start, required this.end, required this.text, required this.textSegments});

  static fromJson(e) {
    List<TextSegment> segments = [];
    for(var i in e['textSegments']) {
      segments.add(TextSegment.fromJson(i));
    }

    return RadioSegment(
        trackName: e['trackName'],
        start: e['startTime'],
        end: e['endTime'],
        text: e['text'],
        textSegments: segments
    );
  }
}

class TextSegment {
  int start;
  int end;
  String text;

  TextSegment({required this.start, required this.end, required this.text});

  static fromJson(e) {
    return TextSegment(
      start: e['start'],
      end: e['end'],
      text: e['text'],
    );
  }
}


class News {
  int? start;
  int? end;

  News({required this.start, required this.end});

  static fromJson(e) {
    return News(
        start: e['start'],
        end: e['end']
    );
  }
}


class Transcription {
  String radioName;
  String fileName;
  DateTime startTime;
  DateTime endTime;
  List<RadioSegment> segments;
  List<News> news;
  List<int> jingles;
  
  Transcription({required this.radioName, required this.fileName, required this.startTime, required this.endTime, required this.segments, required this.news, required this.jingles});

  static fromJson(e) {
    List<RadioSegment> segments = [];
    for(var i in e['segments']) {
      segments.add(RadioSegment.fromJson(i));
    }

    List<News> news = [];
    for(var i in e['news']) {
      news.add(News.fromJson(i));
    }

    List<int> jingles = List<int>.from(e['jingles'].map((i) => int.parse(i.toString())));
    
    return Transcription(
        radioName: e['radioName'],
        fileName: e['fileName'],
        startTime: DateTime.parse(e['startTime']),
        endTime: DateTime.parse(e['endTime']),
        segments: segments,
        news: news,
        jingles: jingles
    );
  }
}



