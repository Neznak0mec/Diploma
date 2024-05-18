import 'package:abiba/UI/AudioWidgets/AudioPage.dart';
import 'package:abiba/UI/FingerPrintWidgets/FingerPrintPage.dart';
import 'package:flutter/material.dart';
import 'Settings.dart';
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
  var extended = true;
  Widget? page;

  void updateMainWidget(Widget newWidget) {
    setState(() {
      page = newWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (page == null) {
      updatePage(null);
    }

    return LayoutBuilder(builder: (context, constraints) {
      return SafeArea(
        child: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600 && extended,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.radio), label: Text('Радио')),
                  NavigationRailDestination(
                      icon: Icon(Icons.disc_full), label: Text('Записи')),
                  NavigationRailDestination(
                      icon: Icon(Icons.search), label: Text('Поиск')),
                  NavigationRailDestination(
                      icon: Icon(Icons.music_note), label: Text('Музыка')),
                  // NavigationRailDestination(
                  //     icon: Icon(Icons.analytics), label: Text('Статистика')),
                  NavigationRailDestination(
                      icon: Icon(Icons.settings), label: Text('Настройки')),
                  NavigationRailDestination(
                      icon: Icon(Icons.density_medium_outlined), label: Text('Свернуть')),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  if (value == 5) {
                    setState(() {
                      extended = !extended;
                    });
                  } else {
                    setState(() {
                      selectedIndex = value;
                      updatePage(null);
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: SafeArea(child: page!) ,
              ),
            ),
          ],
        ),
      );
    });
  }

  void updatePage(Widget? widget) {
    if (widget != null) {
      updateMainWidget(widget);
    } else {
      switch (selectedIndex) {
        case 0:
          updateMainWidget(const RadioPage());
          break;
        case 1:
          updateMainWidget(AudioPage(parent: this));
          break;
        case 2:
          updateMainWidget(TranscriptionSearchPage(parent: this));
          break;
          // updateMainWidget(const FingerPrintPage());
          // break;
        // case 3:
        //   updateMainWidget(const TranscriptionAnalysisWidget());
        //   break;
        case 3:
          updateMainWidget(const FingerPrintPage());
          break;
        case 4:
          updateMainWidget(SettingsPage(parent: this));
          break;
        default:
          updateMainWidget(const RadioPage());
          break;
      }
    }
  }
}
