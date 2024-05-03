import 'package:abiba/UI/SnackBars/FlashMessageSuccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../DataClasses/Radio.dart';
import 'RadioPage.dart';

abstract class RadioWidget extends StatelessWidget {
  const RadioWidget({super.key});
}

class ShowRadioWidget extends RadioWidget {
  final MyRadio radio;
  final RadioPageState parent;

  const ShowRadioWidget(this.radio, this.parent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  radio.name,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: radio.url));
                    ScaffoldMessenger.of(context).showSnackBar( FlashMessageSucess("URL успешно скопировано в буффер обмена",context,time: 10 ));
                  },
                  child: Text(
                    radio.ShortUrl(),
                    style:
                        const TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  parent.removeRadioStation(this);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

