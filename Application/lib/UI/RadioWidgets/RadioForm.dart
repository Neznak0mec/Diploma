import 'package:flutter/material.dart';
import '../SnackBars/FlashMessageError.dart';
import 'RadioPage.dart';

class AddRadioForm extends StatefulWidget {
  const AddRadioForm(this.parent, {super.key});

  final RadioPageState parent;

  @override
  State<AddRadioForm> createState() =>
      _AddRadioFormState(parent);
}

class _AddRadioFormState extends State<AddRadioForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RadioPageState parent;

  _AddRadioFormState(this.parent);

  late String name = "";
  late String url = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                              height: 20,
                              width: 200,
                              child: TextFormField(
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
                              )
                          )
                      ),
                      const SizedBox(
                        height: 10.0,
                        width: 400,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                              height: 20,
                              width: 200,
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Введите URL радиостанции',
                                ),
                                onChanged: (String? value) {
                                  url = value!;
                                },
                              )
                          )
                      )
                    ]
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      if (name.isNotEmpty && url.isNotEmpty) {
                        parent.addRadioStation(name, url);
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(FlashMessageError("Пожалуйста введите URL", context) );
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
          )
      ),
    );
  }
}
