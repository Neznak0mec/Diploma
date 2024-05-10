import 'package:flutter/material.dart';

class FlashMessageSucess extends SnackBar {
  final String message;
  final int time;

  final BuildContext context;

  const FlashMessageSucess(this.message, this.context,
      {super.key, this.time = 10, super.content = const Text('')});

  @override
  Widget get content => Container(
    padding: const EdgeInsets.all(8.0),
    height: 80,
    decoration: BoxDecoration(
      color: Colors.lightGreen,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Stack(
      children: [
        Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text("Успешно",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                message,
                style:
                const TextStyle(fontSize: 14.0, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  // TODO: implement behavior
  SnackBarBehavior? get behavior => SnackBarBehavior.floating;

  @override
  // TODO: implement backgroundColor
  Color? get backgroundColor => Colors.transparent;

  @override
  // TODO: implement elevation
  double? get elevation => 0;

  @override
  // TODO: implement duration
  Duration get duration => Duration(seconds: time);

}
