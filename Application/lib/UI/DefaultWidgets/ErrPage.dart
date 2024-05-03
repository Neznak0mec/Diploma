import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrPage extends StatefulWidget{
  String errorText;

  ErrPage({super.key, required this.errorText});

  @override
  State<ErrPage> createState() => _ErrPageState();
}

class _ErrPageState extends State<ErrPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // create in center of screen red box with error text
      home: Scaffold(
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            height: MediaQuery.of(context).size.height/2,
            width: MediaQuery.of(context).size.width/2,
            decoration: BoxDecoration(
              color: const Color(0xFFC72C41),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text("Ошибка",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                Align(
                  alignment: Alignment.center ,
                  child: Text(
                    widget.errorText,
                    style:
                    const TextStyle(fontSize: 16.0, color: Colors.black54),
                    overflow: TextOverflow.fade,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}