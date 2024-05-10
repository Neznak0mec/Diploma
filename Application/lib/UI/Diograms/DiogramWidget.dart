import 'dart:io';

import 'package:abiba/Api.dart';
import 'package:abiba/DataClasses/Transcription.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:excel/excel.dart';

class TranscriptionAnalysisWidget extends StatefulWidget {
  const TranscriptionAnalysisWidget({super.key});

  @override
  _TranscriptionAnalysisWidgetState createState() => _TranscriptionAnalysisWidgetState();
}

class _TranscriptionAnalysisWidgetState extends State<TranscriptionAnalysisWidget> {
  List<Transcription> transcriptions = [];

  @override
  void initState() {
    super.initState();
    getTranscriptions();
  }

  Future<void> getTranscriptions() async {
    transcriptions = await Api.getAllTranscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription Analysis'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<PieSegment, String>(
                  dataSource: getMusicData(),
                  xValueMapper: (PieSegment data, _) => data.radioName,
                  yValueMapper: (PieSegment data, _) => data.recordetTime,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  dataLabelMapper: (PieSegment data, _) => data.radioName,
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(),
              series: [
                BarSeries<TrackData, String>(
                  dataSource: getTracksCount(transcriptions),
                  xValueMapper: (TrackData data, _) => data.trackName,
                  yValueMapper: (TrackData data, _) => data.count,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(),
              series:
                  [
                BarSeries<TrackData, String>(
                  dataSource: TotalSegmentsOfRadiostation(transcriptions),
                  xValueMapper: (TrackData data, _) => data.trackName,
                  yValueMapper: (TrackData data, _) => data.count,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
          ElevatedButton(
            child: const Text('Создать отчет'),
            onPressed: () {
              createExcelReport(getMusicData(), getTracksCount(transcriptions), TotalSegmentsOfRadiostation(transcriptions));
            },
          ),
        ],
      ),
    );
  }

  List<PieSegment> getMusicData() {
    List<PieSegment> musicData = [];
    for (var transcription in transcriptions) {
      PieSegment segment = PieSegment();
      segment.radioName = transcription.radioName;
      segment.recordetTime = calculateTotalTime(transcription.segments).toInt();
      if (musicData.any((element) => element.radioName == segment.radioName)) {
        musicData[musicData.indexWhere((element) => element.radioName == segment.radioName)].recordetTime += segment.recordetTime;
      } else {
        musicData.add(segment);
      }
    }
    return musicData;
  }

  double calculateTotalTime(List<RadioSegment> segments) {
    double totalTime = 0;
    for (var segment in segments) {
      totalTime += segment.end - segment.start;
    }
    return totalTime;
  }

  List<TrackData> getTracksCount(List<Transcription> segments) {
    List<TrackData> trackData = [];
    for (var transcription in segments) {
      TrackData track = TrackData();
      for (var segment in transcription.segments) {
        String trackName = segment.trackName.toLowerCase();
        track.trackName = trackName;
        track.count++;
      }
      if (trackData.any((element) => element.trackName == track.trackName)) {
        trackData[trackData.indexWhere((element) => element.trackName == track.trackName)].count += track.count;
      } else {
        trackData.add(track);
      }

    }
    trackData.sort((a, b) => a.count.compareTo(b.count));
    return trackData;

  }

  List<TrackData> TotalSegmentsOfRadiostation(List<Transcription> transcriptions) {
    List<TrackData> trackData = [];
    for (var transcription in transcriptions) {
      TrackData track = TrackData();

      track.trackName = transcription.radioName;
      track.count = transcription.segments.length;

      if (trackData.any((element) => element.trackName == track.trackName)) {
        trackData[trackData.indexWhere((element) => element.trackName == track.trackName)].count += track.count;
      } else {
        trackData.add(track);
      }

    }
    trackData.sort((a, b) => a.count.compareTo(b.count));
    return trackData;

  }

  void createExcelReport(List<PieSegment> pieData, List<TrackData> barData1, List<TrackData> barData2) async {
    var excel = Excel.createExcel();

    // Create a sheet for pie chart data
    var sheetPie = excel['PieData'];
    sheetPie.appendRow([toCellValue('Radio Name'), toCellValue('Recorded Time')]);
    for (var data in pieData) {
      sheetPie.appendRow([toCellValue(data.radioName), toCellValue(data.recordetTime)]) ;
    }

    // Create a sheet for bar chart data 1
    var sheetBar1 = excel['BarData1'];
    sheetBar1.appendRow([toCellValue('Track Name'), toCellValue('Count')]);
    for (var data in barData1) {
      sheetBar1.appendRow([toCellValue(data.trackName), toCellValue(data.count)]);
    }

    // Create a sheet for bar chart data 2
    var sheetBar2 = excel['BarData2'];
    sheetBar2.appendRow([toCellValue('Track Name'), toCellValue('Count')]);
    for (var data in barData2) {
      sheetBar2.appendRow([toCellValue(data.trackName), toCellValue(data.count)]);
    }

    // Save the Excel file
    var bytes = excel.encode();
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/report.xlsx');
    await file.writeAsBytes(bytes!);
  }

  TextCellValue toCellValue(dynamic value) {
    return TextCellValue(value.toString());
  }
}

class PieSegment{
  String radioName = "";
  int recordetTime = 0;
}

class TrackData{
  String trackName = "";
  int count = 0;
}
