import 'package:flutter/material.dart';

class DropdownButtonExample extends StatefulWidget {
  final List<String> list;
  const DropdownButtonExample({super.key, required this.list});


  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState(list: list);
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  final List<String> list;

  _DropdownButtonExampleState({required this.list}){
    dropdownValue = list.first;
  }

  String dropdownValue = "not selected";

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}