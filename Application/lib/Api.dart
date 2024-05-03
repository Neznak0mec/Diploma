import 'dart:convert';
import 'dart:io';

import 'package:abiba/DataClasses/Audio.dart';
import 'package:abiba/DataClasses/Transcription.dart';
import 'package:requests/requests.dart';
import "package:http/http.dart" as http;

import 'DataClasses/Radio.dart';

class Api {
  //load baseUrl from config file
  static String baseUrl = LoadFromConfigFile();

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

  static Future<List<MyAudio>> getLastRadiostationAudio(
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

  static String LoadFromConfigFile() {
    //read config file config.json
    //return baseUrl

    File file = File('config.json');
    if (!file.existsSync()) {
      //create file with default baseUrl
      file.writeAsStringSync('{"baseUrl":"http://localhost:5020/api"}');
      //return default baseUrl
      return "http://localhost:5020/api";
    }
    String content = file.readAsStringSync();
    var json = jsonDecode(content);
    return json['baseUrl'];
  }
}





//
// i have many data looks like this:
// {"radioName":"russkoe","fileName":"russkoe-2024-03-10-11-39-05.mp3","startTime":"2024-03-10T11:39:05.038934","endTime":"2024-03-10T11:44:05.1908","segments":[{"trackName":"Спящая красавица - TESTOSTERON","startTime":0,"endTime":180,"text":" Завобед из ветки не будет сраму, что нам вангале Севы каждый мой Севы каждый мой Нанана Нана Русская радио Бучу рнай и он делает Сстават на севы И нагрудие слева Ам, и мое Не спасли в нами Рах, с кеми И не нудянуш тени Тето правда она Серце И ты любишь меня Она проснято Спящая красавца Отпаться у меня, у ровку за сняться Она послаждит на дипят, Она занят на му, Влюблян на мекти, Вебрежь мёртваться, И нас всегда останется Стоять я, красавица А безделад на мера, Как будто станет лучшим, Я не хочу бы чужие, Или на всякий случай, Я жду когда за звучит, Та родной голосковой запах твои, Опостой, голосой, голосой Не хочу на тебя, Смотрите с давный, Если это сын, Хочила, вождем тогда, Причинял ты, Бура, я подорю тебя ласков И просмюшись, Сказки, Она просмюшись, Спящи, А красавица","textSegments":[{"text":" Завобед из ветки не будет сраму, что нам вангале","start":0,"end":5},{"text":" Севы каждый мой","start":5,"end":8},{"text":" Севы каждый мой","start":8,"end":13},{"text":" Нанана Нана","start":13,"end":17},{"text":" Русская радио","start":23,"end":25},{"text":" Бучу рнай и он делает","start":25,"end":29},{"text":" Сстават на севы","start":29,"end":33},{"text":" И нагрудие слева","start":33,"end":36},{"text":" Ам, и мое","start":36,"end":39},{"text":" Не спасли в нами","start":39,"end":41},{"text":" Рах, с кеми","start":41,"end":43},{"text":" И не нудянуш тени","start":43,"end":46},{"text":" Тето правда она","start":46,"end":49},{"text":" Серце","start":49,"end":50},{"text":" И ты любишь меня","start":50,"end":54},{"text":" Она проснято","start":54,"end":57},{"text":" Спящая красавца","start":57,"end":60},{"text":" Отпаться у меня, у ровку за сняться","start":60,"end":68},{"text":" Она послаждит на дипят,","start":68,"end":72},{"text":" Она занят на му,","start":72,"end":74},{"text":" Влюблян на мекти,","start":74,"end":76},{"text":" Вебрежь мёртваться,","start":76,"end":78},{"text":" И нас всегда останется","start":78,"end":81},{"text":" Стоять я, красавица","start":81,"end":85},{"text":" А безделад на мера,","start":85,"end":90},{"text":" Как будто станет лучшим,","start":90,"end":92},{"text":" Я не хочу бы чужие,","start":92,"end":94},{"text":" Или на всякий случай,","start":94,"end":96},{"text":" Я жду когда за звучит,","start":96,"end":97},{"text":" Та родной голосковой запах твои,","start":97,"end":100},{"text":" Опостой, голосой, голосой","start":100,"end":102},{"text":" Не хочу на тебя,","start":102,"end":104},{"text":" Смотрите с давный,","start":104,"end":106},{"text":" Если это сын,","start":106,"end":107},{"text":" Хочила, вождем тогда,","start":107,"end":109},{"text":" Причинял ты,","start":109,"end":111},{"text":" Бура, я подорю тебя ласков","start":111,"end":113},{"text":" И просмюшись,","start":113,"end":114},{"text":" Сказки,","start":114,"end":115},{"text":" Она просмюшись,","start":115,"end":118},{"text":" Спящи,","start":118,"end":119},{"text":" А красавица","start":119,"end":121}]},{"trackName":"Пролетая над нами - Denis Maydanov","startTime":180,"endTime":240,"text":" Ты бы признался и насыпь до нас старался Стряем красиваться Что слушает страна? Любимая на русском Я уже в разгоне, я из Ванма сковья Скучу и тас, кое-что снова, азма Аю, ускорь тебя, азма, аю Босерция не хочет понять Он не его дуня Любимая Мы лежим и над нами, учат гадан Мы летим и под нами гадан Руссердё Все будет хорошо Брегрогом Санлайт знает, чего хотя-то женщины Хочу, кольцо с бриллиантами Исполнен, по самоветонцине А красивая упаковка Быстряя доставка Летоло Ждем в основном приложении Магазинах Санлайт О, о солнцем, я ворно с вооренцем Сцем, сомнадцать и четыре шоцах Восемь вецаде на четыре, но к двенадцать Восемь вецаде на четыре Восемь вецаде на четыре","textSegments":[{"text":" Ты бы признался и насыпь до нас старался","start":180,"end":185},{"text":" Стряем красиваться","start":186,"end":189},{"text":" Что слушает страна?","start":189,"end":191},{"text":" Любимая на русском","start":191,"end":193},{"text":" Я уже в разгоне, я из Ванма сковья","start":193,"end":196},{"text":" Скучу и тас, кое-что снова, азма","start":196,"end":199},{"text":" Аю, ускорь тебя, азма, аю","start":199,"end":203},{"text":" Босерция не хочет понять","start":203,"end":206},{"text":" Он не его дуня","start":206,"end":209},{"text":" Любимая","start":209,"end":211},{"text":" Мы лежим и над нами, учат гадан","start":211,"end":214},{"text":" Мы летим и под нами гадан","start":214,"end":217},{"text":" Руссердё","start":217,"end":219},{"text":" Все будет хорошо","start":219,"end":221},{"text":" Брегрогом","start":221,"end":222},{"text":" Санлайт знает, чего хотя-то женщины","start":222,"end":224},{"text":" Хочу, кольцо с бриллиантами","start":224,"end":226},{"text":" Исполнен, по самоветонцине","start":226,"end":227},{"text":" А красивая упаковка","start":227,"end":229},{"text":"","start":229,"end":229},{"text":" Быстряя доставка","start":229,"end":230},{"text":" Летоло","start":230,"end":231},{"text":" Ждем в основном приложении","start":231,"end":232},{"text":" Магазинах Санлайт","start":232,"end":233},{"text":" О, о солнцем, я ворно с вооренцем","start":233,"end":235},{"text":" Сцем, сомнадцать и четыре шоцах","start":235,"end":236},{"text":" Восемь вецаде на четыре, но к двенадцать","start":236,"end":237},{"text":" Восемь вецаде на четыре","start":237,"end":239},{"text":" Восемь вецаде на четыре","start":239,"end":241}]},{"trackName":"Not Found","startTime":240,"endTime":305,"text":" Пем не понятно. Зато понятно, что вам нужен накопительный вытабыщет. Там ставка 16% в годовых наижения на остаток на копите быстрее. Откройте накопительный вытабыщет на ВТБ точку ру и левови сейбанка ВТБ и открытие ВТБ. Вместе все получится. Дохотность 16% в годовых по накопительному вытабыщету. Выблодок процентов еженезично наижения в наестаток подробный информационного ТБ точку ру. Банк ВТБ. Генеральная лицензия Банк России, номер тысячи Ариклама Нольблюз. Я высплась. И знаете почему? Крця ночь спасел бесплатное ступление ее сна. Спрашивайся во всех как снижена цена. Зачаст оснат перцен, ночь, перцен ночь. Песо не цапрочь. Имится противопоказания, ознакомьтесь с инструкцией. Гиперлента гарантирует лучшие цены на все товары с красными ценниками. Например, Гопия Бушедосен-Сэй и Ред-Катана Молодой и 27 граммов. 479 рублей. С 29 вовевралиапом 18 марта. Подробности на сайте лента.com. Кровелентой канал. Стабильно, не сгеть цены. Вокруг все болеют гриппом и уэрви. Но и не стрелять. для экстренные плановы профилактики есть кога цел. Он помогает усиливать сокстенный защиту.","textSegments":[{"text":" Пем не понятно.","start":240,"end":241},{"text":" Зато понятно, что вам нужен накопительный вытабыщет.","start":241,"end":244},{"text":" Там ставка 16% в годовых наижения на остаток на копите быстрее.","start":245,"end":249},{"text":" Откройте накопительный вытабыщет на ВТБ точку ру и левови сейбанка ВТБ и открытие ВТБ.","start":249,"end":255},{"text":" Вместе все получится.","start":255,"end":257},{"text":" Дохотность 16% в годовых по накопительному вытабыщету.","start":257,"end":260},{"text":" Выблодок процентов еженезично наижения в наестаток подробный информационного ТБ точку ру.","start":260,"end":264},{"text":" Банк ВТБ.","start":264,"end":264},{"text":" Генеральная лицензия Банк России, номер тысячи Ариклама Нольблюз.","start":264,"end":267},{"text":" Я высплась.","start":267,"end":268},{"text":" И знаете почему?","start":268,"end":269},{"text":" Крця ночь спасел бесплатное ступление ее сна.","start":269,"end":272},{"text":" Спрашивайся во всех как снижена цена.","start":272,"end":274},{"text":" Зачаст оснат перцен, ночь, перцен ночь.","start":274,"end":278},{"text":" Песо не цапрочь.","start":278,"end":279},{"text":" Имится противопоказания, ознакомьтесь с инструкцией.","start":279,"end":282},{"text":" Гиперлента гарантирует лучшие цены на все товары с красными ценниками.","start":282,"end":286},{"text":" Например, Гопия Бушедосен-Сэй и Ред-Катана Молодой и 27 граммов.","start":286,"end":290},{"text":" 479 рублей.","start":290,"end":291},{"text":" С 29 вовевралиапом 18 марта.","start":291,"end":293},{"text":" Подробности на сайте лента.com.","start":293,"end":294},{"text":" Кровелентой канал.","start":294,"end":295},{"text":" Стабильно, не сгеть цены.","start":295,"end":296},{"text":" Вокруг все болеют гриппом и уэрви.","start":297,"end":299},{"text":" Но и не стрелять.","start":299,"end":300},{"text":" для экстренные плановы профилактики есть кога цел. Он помогает усиливать сокстенный защиту.","start":300,"end":305}]}],"news":[],"jingles":[23]}
//
// this data parsing into this classes:
//
// class RadioSegment {
//   String trackName;
//   int start;
//   int end;
//   String text;
//   List<TextSegment> textSegments;
//
//   RadioSegment(
//       {required this.trackName, required this.start, required this.end, required this.text, required this.textSegments});
// }
//
// class TextSegment {
//   int start;
//   int end;
//   String text;
//
//   TextSegment({required this.start, required this.end, required this.text});
// }
//
//
// class News {
//   int? start;
//   int? end;
//
//   News({required this.start, required this.end});
// }
//
//
// class Transcription {
//   String radioName;
//   String fileName;
//   DateTime startTime;
//   DateTime endTime;
//   List<RadioSegment> segments;
//   List<News> news;
//   List<int> jingles;
//
//   Transcription({required this.radioName, required this.fileName, required this.startTime, required this.endTime, required this.segments, required this.news, required this.jingles});
//
//
// }
//
//
//
// create widget with using Flutter, what get list of Transcription and with using diograms show data:
// pie diogram of played music (name of son write in RadioSegment - trackName)
// bar diogram for summ of time for every radiostation
// diogram count of word for every radisotation