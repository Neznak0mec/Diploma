import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

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
  bool isTouched = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTranscriptions();
  }

  Future<void> _fetchTranscriptions() async {
    final transcriptions = (await Api.getAllTranscriptions());

    setState(() {
      _transcriptions = transcriptions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
        child: Text('Продолжительность',
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
      SizedBox(
        height: 300,
        child: trackCountWidget(),
      ),
    );

    widgets.add(
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Продожительность новостей',
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
        child: Text('Количесво сегментов',
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
      double fontSize = isTouched ? 25 : 16;
      double radius = isTouched ? 60 : 50;
      final value = data.duration.toDouble();

      return PieChartSectionData(
        color: getRandomColor(),
        value: value,
        title: data.radioName,
        radius: radius,
        titleStyle: TextStyle(
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

    popularTracksData.removeWhere((element) =>
        element.trackName == "Not Found" ||
        element.trackName == "Трек не найден");

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
                    toY: data.count.toDouble(),
                    color: Colors.green,
                    borderRadius: BorderRadius.zero,
                    rodStackItems: [],
                  ),
                ],
                showingTooltipIndicators: [],
              ),
            )
            .toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${popularTracksData[group.x].count} раз',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final trackName = popularTracksData[value.toInt()].trackName;
                final trackNameParts = trackName.split(' ');
                final lines = <String>[];

                //split track name into 2 lines
                int center = trackNameParts.length ~/ 2;
                lines.add(trackNameParts.sublist(0, center).join(' '));
                lines.add(trackNameParts.sublist(center).join(' '));

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Column(
                    children: lines.map((line) {
                      return Text(
                        line,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        gridData: FlGridData(show: false),
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

    final maxDuration = newsDurationData
        .map((data) => data.duration)
        .reduce((a, b) => max(a, b))
        .toDouble();
    final interval = maxDuration / 10;

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
                showingTooltipIndicators: [],
              ),
            )
            .toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${newsDurationData[group.x].duration} секунд',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('0сек');
                }
                if (value == maxDuration) {
                  return Text('${maxDuration.toInt()}сек');
                }
                if (value % interval != 0) {
                  return const SizedBox.shrink();
                }
                return Text('${value.toInt()}сек');
              },
              interval: 1,
              reservedSize: 40,
            ),
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
        gridData: const FlGridData(show: false),
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
                showingTooltipIndicators: [],
              ),
            )
            .toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${segmentCountData[group.x].count} сегментов',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
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
        gridData: FlGridData(show: false),
      ),
    );
  }

  getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    for (var transcription in _transcriptions) {
      final segments = transcription.segments.length;
      final differentTracks =
          transcription.segments.map((s) => s.trackName).toSet().length;
      final totalBroadcastTime = transcription.segments
          .fold<int>(0, (sum, s) => sum + (s.end - s.start));
      final totalNewsTime = transcription.news
          .fold<int>(0, (sum, n) => sum + ((n.end ?? 0) - (n.start ?? 0)));
      final popularTrack = (transcription.segments
          .map((s) => s.trackName)
          .fold<Map<String, int>>({}, (map, name) {
            map[name] = (map[name] ?? 0) + 1;
            return map;
          })
          .entries
          .reduce((a, b) => a.value > b.value ? a : b)).key;

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Радиостанция: ${transcription.radioName}',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf)),
                pw.Text('Название файла: ${transcription.fileName}',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Начало записи: ${transcription.startTime}',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Конец записи: ${transcription.endTime}',
                    style: pw.TextStyle(font: ttf)),
                pw.SizedBox(height: 10),
                pw.Text('Самый популярный трек: $popularTrack',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Кол-во записаных сегментов: $segments',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Количесво разных треков: $differentTracks',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Общее время записис: ${totalBroadcastTime}s',
                    style: pw.TextStyle(font: ttf)),
                pw.Text('Общее время новостей: ${totalNewsTime}s',
                    style: pw.TextStyle(font: ttf)),
                pw.SizedBox(height: 10),
                pw.Text('Сегменты:', style: pw.TextStyle(font: ttf)),
                pw.ListView.builder(
                  itemCount: transcription.segments.length,
                  itemBuilder: (context, index) {
                    final segment = transcription.segments[index];
                    segment.trackName = segment.trackName == "Not Found"
                        ? "Не найдено"
                        : segment.trackName;
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 2),
                        pw.Text('Название трека: ${segment.trackName}',
                            style: pw.TextStyle(font: ttf)),
                        pw.Text('Начало: ${segment.start}',
                            style: pw.TextStyle(font: ttf)),
                        pw.Text('Конец: ${segment.end}',
                            style: pw.TextStyle(font: ttf)),
                        pw.SizedBox(height: 3),
                      ],
                    );
                  },
                ),
                pw.SizedBox(height: 10),
                pw.Text('Новости:', style: pw.TextStyle(font: ttf)),
                pw.ListView.builder(
                  itemCount: transcription.news.length,
                  itemBuilder: (context, index) {
                    final news = transcription.news[index];
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Начало: ${news.start}',
                            style: pw.TextStyle(font: ttf)),
                        pw.Text('Конец: ${news.end}',
                            style: pw.TextStyle(font: ttf)),
                        pw.SizedBox(height: 5),
                      ],
                    );
                  },
                ),
                pw.SizedBox(height: 10),
                pw.Text('Джинглы: ${transcription.jingles.join(', ')}',
                    style: pw.TextStyle(font: ttf)),
                pw.SizedBox(height: 10),
                generateBarChart(transcription, ttf),
              ],
            );
          },
        ),
      );
    }
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget generateBarChart(Transcription transcription, pw.Font ttf) {
    final trackDurations = <String, int>{};
    for (var segment in transcription.segments) {
      trackDurations[segment.trackName] =
          (trackDurations[segment.trackName] ?? 0) +
              (segment.end - segment.start);
    }

    final maxDuration = trackDurations.values
        .fold<int>(0, (prev, elem) => elem > prev ? elem : prev);
    final chartBars = trackDurations.entries.map((entry) {
      final barHeight = (entry.value / maxDuration) * 100;
      return pw.Column(
        children: [
          pw.Container(
            height: barHeight,
            width: 10,
            color: PdfColors.blue,
          ),
          pw.Text(entry.key,
              style: pw.TextStyle(fontSize: 8, font: ttf),
              textAlign: pw.TextAlign.center),
        ],
      );
    }).toList();

    return pw.Container(
      width: double.infinity,
      height: 120,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: chartBars,
      ),
    );
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
