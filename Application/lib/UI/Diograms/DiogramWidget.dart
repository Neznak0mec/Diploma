import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
  int pieTouchedIndex = -1;

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
          child: SingleChildScrollView(
            child: Column(
              children: _generateGraphWidgets(),
            ),
          )),
    );
  }

  List<Widget> _generateGraphWidgets() {
    List<Widget> widgets = [];

    // Bar chart for the duration of each transcription
    widgets.add(
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Transcription Durations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: transcriptionDurationsWidget(),
      ),
    );

    widgets.add(
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Popular Tracks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: trackCountWidget(),
      ),
    );

    widgets.add(
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('News Duration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: newsDurationWidget(),
      ),
    );

    widgets.add(
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Segment Count',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
    widgets.add(
      SizedBox(
        height: 300,
        child: segmentsCountWidget(),
      ),
    );

    return widgets;
  }

  // BarChart transcriptionDurationsWidget() {
  //   var durationData = _transcriptions
  //       .map((t) =>
  //       _DurationData(
  //           t.radioName, t.endTime
  //           .difference(t.startTime)
  //           .inSeconds))
  //       .toList();
  //
  //   final durationDataSummarized = <String, int>{};
  //   for (var data in durationData) {
  //     durationDataSummarized[data.radioName] =
  //         (durationDataSummarized[data.radioName] ?? 0) + data.duration;
  //
  //   }
  //
  //   durationData = durationDataSummarized.entries
  //       .map((e) => _DurationData(e.key, e.value))
  //       .toList();
  //
  //
  //   return BarChart(
  //     BarChartData(
  //       alignment: BarChartAlignment.spaceAround,
  //       barGroups: durationData
  //           .map(
  //             (data) =>
  //             BarChartGroupData(
  //               x: durationData.indexOf(data),
  //               barRods: [
  //                 BarChartRodData(
  //                     toY: data.duration.toDouble()/60, color: Colors.blue)
  //               ],
  //               showingTooltipIndicators: [0],
  //             ),
  //       )
  //           .toList(),
  //       titlesData: FlTitlesData(
  //           leftTitles: const AxisTitles(
  //             sideTitles: SideTitles(
  //               showTitles: false,
  //             ),
  //           ),
  //           bottomTitles: AxisTitles(
  //             sideTitles: SideTitles(
  //               showTitles: true,
  //               getTitlesWidget: (double value, TitleMeta meta) {
  //                 return SideTitleWidget(
  //                     axisSide: meta.axisSide,
  //                     space: 4,
  //                     child: Text(durationData[value.toInt()].radioName,
  //                         style: const TextStyle(
  //                             fontSize: 16, fontWeight: FontWeight.bold)));
  //               },
  //               reservedSize: 22,
  //             ),
  //           )),
  //     ),
  //   );
  // }

  AspectRatio transcriptionDurationsWidget() {
    var durationData = _transcriptions
        .map((t) => _DurationData(
            t.radioName, t.endTime.difference(t.startTime).inSeconds))
        .toList();

    final durationDataSummarized = <String, int>{};
    for (var data in durationData) {
      durationDataSummarized[data.radioName] =
          (durationDataSummarized[data.radioName] ?? 0) + data.duration;
    }

    durationData = durationDataSummarized.entries
        .map((e) => _DurationData(e.key, e.value))
        .toList();

    List<PieChartSectionData> pieChartSectionDataList =
        durationData.map((data) {
      const isTouched = false;
      const double fontSize = isTouched ? 25 : 16;
      const double radius = isTouched ? 60 : 50;
      final value = data.duration.toDouble();

      return PieChartSectionData(
        color: getRandomColor(),
        value: value,
        title: data.radioName,
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      );
    }).toList();

    return AspectRatio(
        aspectRatio: 1.3,
        child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: pieChartSectionDataList,
              ),
            )));
  }

  BarChart trackCountWidget() {
    // Bar chart for the most popular tracks
    final trackCount = <String, int>{};
    for (var transcription in _transcriptions) {
      for (var segment in transcription.segments) {
        trackCount[segment.trackName] =
            (trackCount[segment.trackName] ?? 0) + 1;
      }
    }
    var popularTracksData =
        trackCount.entries.map((e) => _TrackData(e.key, e.value)).toList();

    //get top 10
    popularTracksData.sort((a, b) => b.count.compareTo(a.count));
    if (popularTracksData.length > 10) {
      popularTracksData = popularTracksData.sublist(0, 10);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: popularTracksData
            .map(
              (data) => BarChartGroupData(
                x: popularTracksData.indexOf(data),
                barRods: [
                  BarChartRodData(
                      toY: data.count.toDouble(), color: Colors.green)
                ],
                showingTooltipIndicators: [0],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(popularTracksData[value.toInt()].trackName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)));
                },
                reservedSize: 22,
              ),
            )),
      ),
    );
  }

  BarChart newsDurationWidget() {
    final newsDuration = <String, int>{};
    for (var transcription in _transcriptions) {
      for (var news in transcription.news) {
        final duration = (news.end ?? 0) - (news.start ?? 0);
        newsDuration[transcription.radioName] =
            (newsDuration[transcription.radioName] ?? 0) + duration;
      }
    }
    final newsDurationData = newsDuration.entries
        .map((e) => _NewsDurationData(e.key, e.value))
        .toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: newsDurationData
            .map(
              (data) => BarChartGroupData(
                x: newsDurationData.indexOf(data),
                barRods: [
                  BarChartRodData(
                      toY: data.duration.toDouble(), color: Colors.red)
                ],
                showingTooltipIndicators: [0],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(newsDurationData[value.toInt()].radioName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)));
              },
              reservedSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  BarChart segmentsCountWidget() {
    // Bar chart for the number of segments for each radio station
    final segmentCount = <String, int>{};
    for (var transcription in _transcriptions) {
      segmentCount[transcription.radioName] =
          (segmentCount[transcription.radioName] ?? 0) +
              transcription.segments.length;
    }
    final segmentCountData = segmentCount.entries
        .map((e) => _SegmentCountData(e.key, e.value))
        .toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: segmentCountData
            .map(
              (data) => BarChartGroupData(
                x: segmentCountData.indexOf(data),
                barRods: [
                  BarChartRodData(
                      toY: data.count.toDouble(), color: Colors.purple)
                ],
                showingTooltipIndicators: [0],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(segmentCountData[value.toInt()].radioName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)));
              },
              reservedSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
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
