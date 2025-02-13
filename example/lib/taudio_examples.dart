/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'td/td_simple_playback/td_simple_playback.dart';
/*
    This Form is just a driver to call the various Flutter Sound examples.
    Please refer to the examples/README.md and all the examples located under the examples/lib directory.
*/

///
const int tNotWeb = 1;

///
class Example {
  ///
  final String? title;

  ///
  final String? subTitle;

  ///
  final String? description;

  ///
  final WidgetBuilder? route;

  ///
  final int? flags;

  ///
  /* ctor */ Example(
      {this.title, this.subTitle, this.description, this.flags, this.route});

  ///
  void go(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: route!));
}

///
final List<Example> exampleTable = [
  // If you update the following test, please update also the Examples/README.md file and the comment inside the dart file.
  Example(
    title: 'simplePlayback',
    subTitle: 'A very simple example',
    flags: 0,
    route: (_) => const TDSimplePlayback(),
    description: '''
This is a very simple example for Flutter Sound beginners,
that shows how to play a remote file.

This example is really basic.
''',
  ),
];

///

/// Example app.
class TaudioExamples extends StatefulWidget {
  const TaudioExamples({super.key});

  @override
  State<TaudioExamples> createState() => _TaudioExamples();
}

class _TaudioExamples extends State<TaudioExamples> {
  Example? selectedExample;

  @override
  void initState() {
    selectedExample = exampleTable[0];
    super.initState();
    //_scrollController = ScrollController( );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardBuilder(BuildContext context, int index) {
      var isSelected = (exampleTable[index] == selectedExample);
      return GestureDetector(
        onTap: () => setState(() {
          selectedExample = exampleTable[index];
        }),
        child: Card(
          shape: const RoundedRectangleBorder(),
          borderOnForeground: false,
          elevation: 3.0,
          child: Container(
            height: 55,
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected ? Colors.indigo : const Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),

            //color: isSelected ? Colors.indigo : Colors.cyanAccent,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(exampleTable[index].title!,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black)),
              Text(exampleTable[index].subTitle!,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black)),
            ]),
          ),
        ),
      );
    }

    Widget makeBody() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0E6),
                border: Border.all(
                  color: Colors.indigo,
                  width: 3,
                ),
              ),
              child: ListView.builder(
                  itemCount: exampleTable.length, itemBuilder: cardBuilder),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0E6),
                border: Border.all(
                  color: Colors.indigo,
                  width: 3,
                ),
              ),
              child: SingleChildScrollView(
                child: Text(selectedExample!.description!),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('La plume du chapeau'),
      ),
      body: makeBody(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text((kIsWeb && (selectedExample!.flags! & tNotWeb != 0))
                    ? 'Not supported on Flutter Web '
                    : ''),
                ElevatedButton(
                  onPressed:
                      (kIsWeb && (selectedExample!.flags! & tNotWeb != 0))
                          ? null
                          : () => selectedExample!.go(context),
                  //color: Colors.indigo,
                  child: const Text(
                    'GO',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
