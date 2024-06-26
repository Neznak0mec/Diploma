import 'package:abiba/UI/SnackBars/FlashMessageSuccess.dart';
import 'package:flutter/material.dart';
import '../../Api.dart';
import '../SnackBars/FlashMessageError.dart';
import 'RadioPage.dart';

class AddRadioForm extends StatefulWidget {
  const AddRadioForm(this.parent, {super.key});

  final RadioPageState parent;

  @override
  State<AddRadioForm> createState() => _AddRadioFormState(parent);
}

class _AddRadioFormState extends State<AddRadioForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RadioPageState parent;

  _AddRadioFormState(this.parent);

  late String name = "";
  late String url = "";

  bool professional = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Switch(
                value: professional,
                onChanged: (bool value) {
                  setState(() {
                    professional = value;
                  });
                },
              ),
              professional
                  ? const Text("Ручное добавление радиостанции")
                  : const Text("Отправить запрос на добавление радиостанции"),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Введите название радиостанции',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите что-либо';
                        }
                        return null;
                      },
                      onChanged: (String? value) {
                        name = value!;
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                      width: 400,
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Введите URL радиостанции',
                      ),
                      onChanged: (String? value) {
                        url = value!;
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () async {
                      if (name.isNotEmpty && url.isNotEmpty) {
                        if (professional) {
                          if (await Api.isAudioStream(url)) {
                            parent.addRadioStation(name, url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              FlashMessageError(
                                "Пожалуйста введите URL аудио потока",
                                context,
                              ),
                            );
                          }
                        } else {
                          if (await Api.sendRequestToAdd(name, url)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              FlashMessageSuccess(
                                "Запрос на добавление отправлен",
                                context,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              FlashMessageError(
                                "Ошибка при отправке запроса",
                                context,
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          FlashMessageError("Пожалуйста введите URL", context),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
