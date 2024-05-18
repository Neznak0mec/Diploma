import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import '../../Api.dart';
import '../../DataClasses/Transcription.dart';
import '../../main.dart';
import '../TranscriptionWidget/AudioTranscriptionWidget.dart';

class TranscriptionSearchPage extends StatefulWidget {
  const TranscriptionSearchPage({super.key, required this.parent});
  final MyHomePageState parent;

  @override
  _TranscriptionSearchPageState createState() =>
      _TranscriptionSearchPageState(parent: parent);
}

class _TranscriptionSearchPageState extends State<TranscriptionSearchPage> {
  final TextEditingController _musicController = TextEditingController();
  final TextEditingController _phraseController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedRadioName;
  List<Transcription> _transcriptions = [];
  List<Transcription> _filteredTranscriptions = [];
  List<String> _radioNames = [];
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  final MyHomePageState parent;

  _TranscriptionSearchPageState({required this.parent});

  @override
  void initState() {
    super.initState();
    _fetchTranscriptions();
  }

  Future<void> _fetchTranscriptions() async {
    final transcriptions = await Api.getAllTranscriptions();
    final radioNames = transcriptions.map((t) => t.radioName).toSet().toList();

    setState(() {
      _transcriptions = transcriptions;
      _radioNames = radioNames;
      _filteredTranscriptions = transcriptions;
    });
  }

  void _filterResults() {
    setState(() {
      _filteredTranscriptions = _transcriptions.where((transcription) {
        bool matchesDate = _selectedDate == null ||
            (transcription.startTime
                .isBefore(_selectedDate!.add(const Duration(days: 1))) &&
                transcription.endTime.isAfter(_selectedDate!));
        bool matchesRadioName = _selectedRadioName == null ||
            transcription.radioName == _selectedRadioName;
        bool matchesMusic = _musicController.text.isEmpty ||
            transcription.segments.any((segment) =>
                segment.trackName.contains(_musicController.text, 0));
        bool matchesPhrase = _phraseController.text.isEmpty ||
            transcription.segments.any((segment) =>
                segment.text.toLowerCase().contains(_phraseController.text.toLowerCase(), 0));

        return matchesDate && matchesRadioName && matchesMusic && matchesPhrase;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _filterResults();
    }
  }

  List<String> _getTrackNameSuggestions(String query) {
    final matches = <String>{};
    for (var transcription in _transcriptions) {
      for (var segment in transcription.segments) {
        if (segment.trackName.toLowerCase().contains(query.toLowerCase())) {
          matches.add(segment.trackName);
        }
        if (matches.length == 10) break;
      }
      if (matches.length == 10) break;
    }
    return matches.toList();
  }

  void _sortResults(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      switch (columnIndex) {
        case 0:
          _filteredTranscriptions.sort((a, b) => a.fileName.compareTo(b.fileName));
          break;
        case 1:
          _filteredTranscriptions.sort((a, b) => a.startTime.compareTo(b.startTime));
          break;
        case 2:
          _filteredTranscriptions.sort((a, b) => a.endTime.compareTo(b.endTime));
          break;
        case 3:
          _filteredTranscriptions.sort((a, b) => a.radioName.compareTo(b.radioName));
          break;
      }

      if (!ascending) {
        _filteredTranscriptions = _filteredTranscriptions.reversed.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRadioName,
                    hint: const Text('Радиостанция'),
                    items: _radioNames.map((name) {
                      return DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRadioName = value;
                      });
                      _filterResults();
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TypeAheadFormField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _musicController,
                      decoration: const InputDecoration(labelText: 'Музыкальный трек'),
                    ),
                    suggestionsCallback: (pattern) async {
                      if (pattern.length > 1) {
                        return _getTrackNameSuggestions(pattern);
                      } else {
                        return [];
                      }
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _musicController.text = suggestion;
                      _filterResults();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(_selectedDate == null
                    ? 'Дата записи не выбрана'
                    : 'Выбрана дата: ${DateFormat.yMMMd().format(_selectedDate!)}'),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Выбор даты'),
                ),
              ],
            ),
            TextField(
              controller: _phraseController,
              decoration: const InputDecoration(
                labelText: 'Фраза, слова',
              ),
              onChanged: (text) => _filterResults(),
            ),
            const SizedBox(height: 16.0),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Результаты поиска:', style: TextStyle(fontSize: 18.0)),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        showCheckboxColumn: false,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: [
                          DataColumn(
                            label: const Text('Имя файла'),
                            onSort: (columnIndex, ascending) {
                              _sortResults(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: const Text('Начало записи'),
                            onSort: (columnIndex, ascending) {
                              _sortResults(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: const Text('Конец записи'),
                            onSort: (columnIndex, ascending) {
                              _sortResults(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: const Text('Радиостанция'),
                            onSort: (columnIndex, ascending) {
                              _sortResults(columnIndex, ascending);
                            },
                          ),
                        ],
                        rows: _filteredTranscriptions.map((transcription) {
                          return DataRow(
                            cells: [
                              DataCell(Text(transcription.fileName)),
                              DataCell(Text(DateFormat.yMMMd().add_jm().format(transcription.startTime))),
                              DataCell(Text(DateFormat.yMMMd().add_jm().format(transcription.endTime))),
                              DataCell(Text(transcription.radioName)),
                            ],
                            onSelectChanged: (selected) {
                              if (selected ?? false) {
                                parent.updateMainWidget(AudioTranscriptionWidget(transcription: transcription));
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
