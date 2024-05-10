import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static String API_URL = "http://0.0.0.0:5020/api";
  static bool INTERNET_AUDIO = true;

  static late SharedPreferences prefs;

  void init() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString("api_url") == null) {
      prefs.setString("api_url", API_URL);
    }
    if (prefs.getBool("internet_audio") == null) {
      prefs.setBool("internet_audio", INTERNET_AUDIO);
    }

    API_URL = prefs.getString("api_url") ?? API_URL;
    INTERNET_AUDIO = prefs.getBool("internet_audio") ?? INTERNET_AUDIO;
  }

  static void updateApi() async {
    API_URL = prefs.getString("api_url") ?? API_URL;
  }

  static void updateInternetAudio() async {
    INTERNET_AUDIO = prefs.getBool("internet_audio") ?? INTERNET_AUDIO;
  }

  static Future<void> setApiUrl(String url) async {
    prefs.setString("api_url", url);
    updateApi();
  }

  static Future<void> setInternetAudio(bool value) async {
    prefs.setBool("internet_audio", value);
    updateInternetAudio();
  }

}