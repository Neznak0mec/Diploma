import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:excel/excel.dart';

import '../../Api.dart';
import '../../DataClasses/Transcription.dart';

class TranscriptionAnalysisWidget extends StatefulWidget {
  const TranscriptionAnalysisWidget({super.key});

  @override
  _TranscriptionAnalysisWidgetState createState() =>
      _TranscriptionAnalysisWidgetState();
}

class _TranscriptionAnalysisWidgetState
    extends State<TranscriptionAnalysisWidget> {
  List<Transcription> _transcriptions = [];

  @override
  void initState() {
    super.initState();
    _fetchTranscriptions();
  }

  Future<void> _fetchTranscriptions() async {
    final transcriptions = (await Api.getAllTranscriptions());

    setState(() {
      _transcriptions = transcriptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
          SingleChildScrollView(
            child: Column(
              children: _generateGraphWidgets(),
            ),
          )
      ),
    );
  }

  List<Widget> _generateGraphWidgets() {
    List<Widget> widgets = [];

    // Bar chart for the duration of each transcription
    final durationData = _transcriptions.map((t) => _DurationData(
        t.radioName,
        t.endTime.difference(t.startTime).inSeconds
    )).toList();

    widgets.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Transcription Durations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: durationData
                .map(
                  (data) => BarChartGroupData(
                x: durationData.indexOf(data),
                barRods: [
                  BarChartRodData(y: data.duration.toDouble(), colors: [Colors.blue])
                ],
                showingTooltipIndicators: [0],
              ),
            )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(showTitles: true),
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (double value) {
                  return durationData[value.toInt()].radioName;
                },
                rotateAngle: 45, // Rotating to avoid overlap if the text is long
                margin: 20, // Adjust margin to provide enough space for the labels
              ),
            ),
          ),
        ),
      ),
    );

    // Bar chart for the most popular tracks
    final trackCount = <String, int>{};
    for (var transcription in _transcriptions) {
      for (var segment in transcription.segments) {
        trackCount[segment.trackName] = (trackCount[segment.trackName] ?? 0) + 1;
      }
    }
    final popularTracksData = trackCount.entries.map((e) => _TrackData(e.key, e.value)).toList();

    widgets.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Popular Tracks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: popularTracksData
                .map(
                  (data) => BarChartGroupData(
                x: popularTracksData.indexOf(data),
                barRods: [
                  BarChartRodData(y: data.count.toDouble(), colors: [Colors.green])
                ],
                showingTooltipIndicators: [0],
              ),
            )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(showTitles: true),
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (double value) {
                  return popularTracksData[value.toInt()].trackName;
                },
                rotateAngle: 45,
                margin: 20,
              ),
            ),
          ),
        ),
      ),
    );

    // Bar chart for the total amount of time of news on air
    final newsDuration = <String, int>{};
    for (var transcription in _transcriptions) {
      for (var news in transcription.news) {
        final duration = (news.end ?? 0) - (news.start ?? 0);
        newsDuration[transcription.radioName] = (newsDuration[transcription.radioName] ?? 0) + duration;
      }
    }
    final newsDurationData = newsDuration.entries.map((e) => _NewsDurationData(e.key, e.value)).toList();

    widgets.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('News Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: newsDurationData
                .map(
                  (data) => BarChartGroupData(
                x: newsDurationData.indexOf(data),
                barRods: [
                  BarChartRodData(y: data.duration.toDouble(), colors: [Colors.red])
                ],
                showingTooltipIndicators: [0],
              ),
            )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(showTitles: true),
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (double value) {
                  return newsDurationData[value.toInt()].radioName;
                },
                rotateAngle: 45,
                margin: 20,
              ),
            ),
          ),
        ),
      ),
    );

    // Bar chart for the number of segments for each radio station
    final segmentCount = <String, int>{};
    for (var transcription in _transcriptions) {
      segmentCount[transcription.radioName] = (segmentCount[transcription.radioName] ?? 0) + transcription.segments.length;
    }
    final segmentCountData = segmentCount.entries.map((e) => _SegmentCountData(e.key, e.value)).toList();

    widgets.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Segment Count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: segmentCountData
                .map(
                  (data) => BarChartGroupData(
                x: segmentCountData.indexOf(data),
                barRods: [
                  BarChartRodData(y: data.count.toDouble(), colors: [Colors.purple])
                ],
                showingTooltipIndicators: [0],
              ),
            )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(showTitles: true),
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (double value) {
                  return segmentCountData[value.toInt()].radioName;
                },
                rotateAngle: 45,
                margin: 20,
              ),
            ),
          ),
        ),
      ),
    );

    return widgets;
  }
}

class _DurationData {
  final String radioName;
  final int duration;

  _DurationData(this.radioName, this.duration);
}

class _TrackData {
  final String trackName;
  final int count;

  _TrackData(this.trackName, this.count);
}

class _NewsDurationData {
  final String radioName;
  final int duration;

  _NewsDurationData(this.radioName, this.duration);
}

class _SegmentCountData {
  final String radioName;
  final int count;

  _SegmentCountData(this.radioName, this.count);
}
