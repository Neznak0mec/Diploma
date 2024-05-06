

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'AudioPage.dart';

class SelectRadioWidget extends StatefulWidget {
  final AudioPageState parent;

  SelectRadioWidget({required this.parent, Key? key}) : super(key: key);

  @override
  SelectRadioWidgetState createState() => SelectRadioWidgetState(parent: parent);
}

class SelectRadioWidgetState extends State<SelectRadioWidget> {
  final AudioPageState parent;

  SelectRadioWidgetState({required this.parent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Align(
          alignment: Alignment.centerLeft,
          child: FutureBuilder<List<String>>(
            future: parent.getRadios(),
            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return DropdownButton<String>(
                  value: parent.dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    if (value == "all") {
                      parent.params.radioName = null;
                    } else {
                      parent.params.radioName = value;
                    }
                    setState(() {
                      parent.dropdownValue = value!;
                    });
                    parent.updateGrid();
                  },
                  items: snapshot.data!
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                );
              }
            },
          )),
    );
  }
}
