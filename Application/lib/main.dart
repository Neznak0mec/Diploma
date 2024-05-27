import 'package:flutter/material.dart';
import 'Settings.dart';
import 'UI/Diograms/DiogramWidget.dart';
import 'UI/FingerPrintWidgets/FingerPrintPage.dart';
import 'UI/RadioWidgets/RadioPage.dart';
import 'UI/SearchWidgets/SearchPage.dart';
import 'UI/SettigsWidget/Settings.dart';

void main() {
  SettingsService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Радиотрекер',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  Widget? page;
  String pageName = "Радио";

  void updateMainWidget(Widget newWidget, String newPageName) {
    setState(() {
      pageName = newPageName;
      page = newWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (page == null) {
      updatePage(null);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 80, // Adjust this value to your preference
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.radio),
              title: const Text('Радио'),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                  updatePage(null);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Поиск'),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                  updatePage(null);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Музыка'),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                  updatePage(null);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Статистика'),
              onTap: () {
                setState(() {
                  selectedIndex = 4;
                  updatePage(null);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                  updatePage(null);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(child: page!),
    );
  }

  void updatePage(Widget? widget, [String pageName = ""]) {
    if (widget != null) {
      updateMainWidget(widget, pageName);
    } else {
      switch (selectedIndex) {
        case 0:
          updateMainWidget(const RadioPage(), "Радио");
          break;
        case 1:
          updateMainWidget(TranscriptionSearchPage(parent: this), "Поиск");
          break;
        case 2:
          updateMainWidget(const FingerPrintPage(), "Музыка");
          break;
        case 3:
          updateMainWidget(SettingsPage(parent: this), "Настройки");
          break;
        case 4:
          updateMainWidget(const TranscriptionAnalysisWidget(), "Статистика");
          break;
        default:
          updateMainWidget(const RadioPage(), "Радио");
          break;
      }
    }
  }
}
