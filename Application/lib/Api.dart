
import 'package:abiba/DataClasses/Audio.dart';
import 'package:abiba/DataClasses/Transcription.dart';
import 'package:requests/requests.dart';
import "package:http/http.dart" as http;

import 'DataClasses/Radio.dart';
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

  static Future<List<MyAudio>> getLastRadiostationAudio(String radioName) async
  {
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
  static Future<Transcription>? getTranscription(String fileName) async {
      var r = await Requests.get("$baseUrl/transcription/$fileName");
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


  //radiostation recording
  static Future<Map<String,bool>> radioRecordingStats() async {
    var r = await Requests.get("$baseUrl/audio/status");
    var res = <String,bool>{};
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
}