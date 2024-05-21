import 'package:abiba/DataClasses/Audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import '../../Api.dart';
import '../../DataClasses/Transcription.dart';
import '../../main.dart';
import '../SnackBars/FlashMessageError.dart';
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
  List<MyAudio> _filteredAudios = [];
  List<String> _radioNames = [];
  List<String> _tracksNames = [];
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
    final transcriptions = (await Api.getAllAudioList())
        .where((e) => e.status == 0 || e.status == 1)
        .toList();
    final radioNames = (await Api.getRadioList()).map((e) => e.name).toList();
    final trackNames = await Api.getTrackNames();

    setState(() {
      _radioNames = radioNames;
      _filteredAudios = transcriptions;
      _tracksNames = trackNames;
    });
  }

  Future<void> _filterResults() async {
    List<MyAudio> audios = await Api.SearchAudios(
      _selectedRadioName,
      _musicController.text,
      _phraseController.text,
      _selectedDate,
    );

    setState(() {
      _filteredAudios = audios;
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
      await _filterResults();
    }
  }

  List<String> _getTrackNameSuggestions(String query) {
    final matches = <String>{};
    for (final trackName in _tracksNames) {
      if (trackName.toLowerCase().contains(query.toLowerCase())) {
        matches.add(trackName);
      }
      if (matches.length >= 10) {
        break;
      }
    }
    return matches.toList();
  }

  void _sortResults(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      switch (columnIndex) {
        case 0:
          _filteredAudios.sort((a, b) => a.fileName.compareTo(b.fileName));
          break;
        case 1:
          _filteredAudios
              .sort((a, b) => a.startRecording.compareTo(b.startRecording));
          break;
        case 2:
          _filteredAudios
              .sort((a, b) => a.endRecording.compareTo(b.endRecording));
          break;
        case 3:
          _filteredAudios.sort((a, b) => a.radioName!.compareTo(b.radioName!));
          break;
      }

      if (!ascending) {
        _filteredAudios = _filteredAudios.reversed.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onChanged: (value) async {
                      setState(() {
                        _selectedRadioName = value;
                      });
                      await _filterResults();
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TypeAheadFormField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _musicController,
                      decoration:
                      const InputDecoration(labelText: 'Музыкальный трек'),
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
                    onSuggestionSelected: (suggestion) async {
                      _musicController.text = suggestion;
                      await _filterResults();
                    },
                    onSaved: (suggestion) async {
                      _musicController.text = suggestion ?? '';
                      await _filterResults();
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
                    : 'Выбрана дата: ${DateFormat.yMMMd().format(
                    _selectedDate!)}'),
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
              onChanged: (text) async => await _filterResults(),
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.black, height: 5),
            const SizedBox(height: 16.0),
            const Align(
              alignment: Alignment.centerLeft,
              child:
              Text('Результаты поиска:', style: TextStyle(fontSize: 18.0)),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints:
                      BoxConstraints(minWidth: constraints.maxWidth),
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
                        rows: _getRows(),

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

  // ger table rows
  List<DataRow> _getRows() {
    return _filteredAudios.map((audio) {
      return DataRow(
        cells: [
          DataCell(Text(
            audio.fileName
          )),
          DataCell(Text(DateFormat.yMMMd()
              .add_jm()
              .format(audio.startRecording))),
          DataCell(Text(DateFormat.yMMMd()
              .add_jm()
              .format(audio.endRecording))),
          DataCell(Text(audio.radioName ?? '')),
        ],
        color: audio.status == 1 ? WidgetStateProperty.all(Colors.greenAccent) : WidgetStateProperty.all(Colors.redAccent),
        onSelectChanged: (selected) async {
          if (selected ?? false) {
            if (audio.status == 0) {
              var bar = FlashMessageError(
                  "Аудио еще не обработано", context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(bar);
              return;
            }

            Transcription? transcription =
            await Api.getTranscription(audio.fileName);
            if (transcription == null) {
              var bar = FlashMessageError(
                  "Ошибка при загрузке транскрипции",
                  context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(bar);
              return;
            }
            parent.updatePage(
                AudioTranscriptionWidget(
                    transcription: transcription),"Стенограмма");
          }
        },
      );
    }).toList();
  }
}
