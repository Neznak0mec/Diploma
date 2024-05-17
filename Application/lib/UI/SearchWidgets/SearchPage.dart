import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

import '../../Api.dart';
import '../../DataClasses/Transcription.dart';


class TranscriptionSearchPage extends StatefulWidget {
  @override
  _TranscriptionSearchPageState createState() => _TranscriptionSearchPageState();
}

class _TranscriptionSearchPageState extends State<TranscriptionSearchPage> {
  final TextEditingController _musicController = TextEditingController();
  final TextEditingController _phraseController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedRadioName;
  List<Transcription> _transcriptions = [];
  List<Transcription> _filteredTranscriptions = [];
  List<String> _radioNames = [];
  List<String> _trackNames = [];

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
            (transcription.startTime.isBefore(_selectedDate!.add(Duration(days: 1))) &&
                transcription.endTime.isAfter(_selectedDate!));
        bool matchesRadioName = _selectedRadioName == null ||
            transcription.radioName == _selectedRadioName;
        bool matchesMusic = _musicController.text.isEmpty ||
            transcription.segments.any((segment) => segment.trackName.contains(_musicController.text, 0));
        bool matchesPhrase = _phraseController.text.isEmpty ||
            transcription.segments.any((segment) => segment.text.contains(_phraseController.text, 0));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcription Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRadioName,
              hint: Text('Select Radio Station'),
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
            TypeAheadFormField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _musicController,
                decoration: InputDecoration(labelText: 'Music Track'),
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
            TextField(
              controller: _phraseController,
              decoration: const InputDecoration(
                labelText: 'Phrase',
              ),
              onChanged: (text) => _filterResults(),
            ),
            Row(
              children: [
                Text(_selectedDate == null
                    ? 'No date selected'
                    : 'Selected date: ${DateFormat.yMMMd().format(_selectedDate!)}'),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTranscriptions.length,
                itemBuilder: (context, index) {
                  final transcription = _filteredTranscriptions[index];
                  return ListTile(
                    title: Text(transcription.radioName),
                    subtitle: Text(
                      'From ${DateFormat.yMMMd().add_jm().format(transcription.startTime)} to ${DateFormat.yMMMd().add_jm().format(transcription.endTime)}',
                    ),
                    onTap: () {
                      // Handle item tap if needed
                    },
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
