import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:requests/requests.dart';
import 'package:http/http.dart' as http;

import 'DataClasses/Audio.dart';
import 'DataClasses/Radio.dart';
import 'DataClasses/Transcription.dart';
import 'Settings.dart';

class Api {
  //load baseUrl from config file
  static String baseUrl = SettingsService.API_URL;

  //check availability of server
  static Future<bool> checkServer(url) async {
    try {
      var r = await Requests.get("$url/radio");
      return r.success;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isAudioStream(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null) {
          return contentType.startsWith('audio/');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    return false;
  }

  static Future<bool> sendRequestToAdd(
      String radioName, String radioUrl) async {
    try {
      String telegramBotToken = '6543542035:AAEqmMA6vIKhceTTPp--eBA2qmR-j6gYDSQ';

      String url = 'https://api.telegram.org/bot$telegramBotToken/sendMessage';

      Map<String, dynamic> data = {
        'chat_id': '464151751',
        'text': 'Want to add $radioName - $radioUrl',
      };

      var response = await http.post(Uri.parse(url),
          body: data.map((k, v) => MapEntry(k, '$v')));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Message sent successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to send message: ${response.statusCode} ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    return false;
  }

  ///////////////////////////////
  // Radio
  ///////////////////////////////
  static Future<List<MyRadio>> getRadioList() async {
    var r = await Requests.get("$baseUrl/radio");
    var radios = r.json();

    List<MyRadio> res = [];
    for (var i in radios) {
      res.add(MyRadio.fromJson(i));
    }
    return res;
  }

  static void removeRadioStation(MyRadio radio) {
    Requests.delete("$baseUrl/radio", queryParameters: {"name": radio.name});
  }

  static void addRadioStation(String name, String url) {
    Requests.post("$baseUrl/radio", json: {"name": name, "url": url});
  }

  ///////////////////////////////
  // Audio
  ///////////////////////////////
  static Future<List<MyAudio>> getAllAudioList() async {
    List<MyRadio> radios = await getRadioList();
    List<MyAudio> res = [];
    for (var i in radios) {
      var r = await Requests.get("$baseUrl/audio/all/${i.name}");
      var json = r.json();
      for (var j in json) {
        res.add(MyAudio.fromJson(j));
      }
    }
    return res;
  }

  static Future<List<MyAudio>> getAudioList(String radioName) async {
    var r = await Requests.get("$baseUrl/audio/all/$radioName");
    var audios = r.json();

    List<MyAudio> res = [];
    for (var i in audios) {
      res.add(MyAudio.fromJson(i));
    }
    return res;
  }

  static Future<List<MyAudio>> getLastRadioStationAudio(
      String radioName) async {
    var r = await Requests.get("$baseUrl/audio/last/$radioName");
    var audios = r.json();

    List<MyAudio> res = [];
    for (var i in audios) {
      res.add(MyAudio.fromJson(i));
    }
    return res;
  }

  ///////////////////////////////
  // Transcription
  ///////////////////////////////
  static Future<Transcription?> getTranscription(String fileName) async {
    var r = await Requests.get("$baseUrl/transcription/$fileName");
    if (!r.success) {
      return null;
    }
    var json = r.json();
    return Transcription.fromJson(json);
  }

  static String getFileUrl(String filename) {
    return "$baseUrl/audio/file/$filename";
  }

  ///////////////////////////////
  // Fingerprint
  ///////////////////////////////
  static Future<List<MyAudio>> getFingerprintsList() async {
    var r = await Requests.get("$baseUrl/fingerprint/all");
    var audios = r.json();

    List<MyAudio> res = [];
    for (var i in audios) {
      res.add(MyAudio.fromJson(i));
    }
    return res;
  }

  static String getFingerprintUrl(String filename) {
    return "$baseUrl/fingerprint/file/$filename";
  }

  //send audio to server
  static Future<int> sendAudioToServer(String name, String path) async {
    var url = Uri.parse("$baseUrl/fingerprint?name=$name");
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', path));
    var res = await request.send();
    return res.statusCode;
  }

  static Future<int> sendJingleToServer(
      String name, String path, String radioName) async {
    var url = Uri.parse(
        "$baseUrl/fingerprint?name=$name&jingle=true&radioName=$radioName");
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', path));
    var res = await request.send();
    return res.statusCode;
  }

  static Future<List<Transcription>> getAllTranscriptions() async {
    //use existing functions
    var audios = await getAllAudioList();
    List<Transcription> res = [];
    for (var i in audios) {
      var temp = await getTranscription(i.fileName);
      if (temp != null) {
        res.add(temp);
      }
    }
    return res;
  }

  static Future<Map<String, bool>> radioRecordingStats() async {
    var r = await Requests.get("$baseUrl/audio/status");
    var res = <String, bool>{};
    for (var i in r.json().keys) {
      res[i] = r.json()[i];
    }
    return res;
  }

  //start recording
  static Future startRecording(String radioName) async {
    await Requests.post("$baseUrl/audio/continue/$radioName");
  }

  //stop recording
  static Future stopRecording(String radioName) async {
    await Requests.post("$baseUrl/audio/pause/$radioName");
  }

  //stop all recordings
  static Future stopAllRecordings() async {
    await Requests.post("$baseUrl/audio/pause");
  }

  //start all recordings
  static Future startAllRecordings() async {
    await Requests.post("$baseUrl/audio/continue");
  }

  //search audios
  static Future<List<MyAudio>> searchAudios(
      [String? radioName,
      String? musicName,
      String? text,
      DateTime? date]) async {
    List<MyAudio> result = [];
    String query = "";
    if (radioName != null && radioName.isNotEmpty) {
      query += "radioName=$radioName";
    }
    if (musicName != null && musicName.isNotEmpty) {
      if (query.isNotEmpty) {
        query += "&";
      }
      query += "musicName=$musicName";
    }
    if (text != null && text.isNotEmpty) {
      if (query.isNotEmpty) {
        query += "&";
      }
      query += "text=$text";
    }
    if (date != null) {
      if (query.isNotEmpty) {
        query += "&";
      }
      query += "date=$date";
    }

    if (query.isEmpty) {
      return await getAllAudioList();
    }

    var r = await Requests.get("$baseUrl/audio/search?$query");
    var audios = r.json();
    for (var i in audios) {
      result.add(MyAudio.fromJson(i));
    }

    return result;
  }

  //get musics
  static Future<List<String>> getTrackNames() async {
    var r = await Requests.get("$baseUrl/audio/musics");
    var musics = r.json();
    List<String> res = [];
    for (var i in musics) {
      res.add(i);
    }
    return res;
  }
}
