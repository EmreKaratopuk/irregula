import 'dart:convert';
import 'dart:math';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Random random = Random();
  List list = [];
  List? verbFamily;
  late int index;
  List<String> headings = ["Infinitive", "Past Simple", "Past Participle"];
  List<Widget> forms = [];
  String label = "Check";
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  Future loadVerbs() async {
    if (verbFamily == null) {
      String data = await rootBundle.loadString("assets/irregularVerbs.json");
      list = await json.decode(data)["verbs"];
      chooseVerb();
    }
    return true;
  }

  void chooseVerb() {
    verbFamily = list[random.nextInt(50)];
    index = random.nextInt(3);
  }

  @override
  void initState() {
    forms = List.generate(3, (int i) {
      final AnimateIconController _iconController = AnimateIconController();
      final TextEditingController _editingController = TextEditingController();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(headings[i]),
          Container(
            margin: const EdgeInsets.all(10),
            width: 100,
            child: TextFormField(
              controller: _editingController,
              validator: (String? value) {
                if (value == null) {
                  return verbFamily![i];
                } else if (value.trim().toLowerCase() == verbFamily![i]) {
                  _iconController.animateToEnd();
                  return "";
                } else {
                  return verbFamily![i];
                }
              },
              onSaved: (String? _) {
                _editingController.clear();
                _iconController.animateToStart();
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightBlue[200],
                counterText: "",
                border: const UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: AnimateIcons(
              controller: _iconController,
              startIconColor: Colors.blue,
              startIcon: Icons.add,
              endIcon: Icons.done,
              endIconColor: Colors.green,
              duration: const Duration(milliseconds: 300),
              onStartIconPress: () {
                _editingController.text = verbFamily![index];
                return false;
              },
              onEndIconPress: () => false,
            ),
          ),
        ],
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Irregular Verbs Practice"),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: loadVerbs(),
          builder: (BuildContext _, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.all(15),
                child: ListView(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: Text(verbFamily![index], style: const TextStyle(fontSize: 23)),
                      padding: const EdgeInsets.symmetric(vertical: 50),
                    ),
                    Form(
                      key: _form,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: forms,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        child: Text(label),
                        onPressed: () {
                          if (label == "Check") {
                            _form.currentState!.validate();
                            setState(() {
                              label = "Continue";
                            });
                          } else {
                            setState(() {
                              chooseVerb();
                              label = "Check";
                              _form.currentState!.reset();
                              _form.currentState!.save();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
