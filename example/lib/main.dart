/*
 * Copyright 2024 Canardoux.
 *
 * This file is part of the τ Project.
 *
 * τ (Tau) is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * τ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/material.dart';
import 'taudio_examples.dart';
//import 'flutter_sound_examples.dart';

///
//class Example {}

void main() {
  runApp(const ExamplesApp());
}

///
class ExamplesApp extends StatelessWidget {
  const ExamplesApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sound Examples',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ExamplesAppHomePage(title: 'τ (Tau) Examples'),
    );
  }
}

///
class ExamplesAppHomePage extends StatefulWidget {
  ///
  const ExamplesAppHomePage({super.key, this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  ///
  final String? title;

  @override
  State<ExamplesAppHomePage> createState() => _ExamplesHomePageState();
}

class _ExamplesHomePageState extends State<ExamplesAppHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: ElevatedButton(
                child: const Text(
                  'Flutter Sound examples',
                ),
                onPressed: () {
                  //Navigator.of(context).push(MaterialPageRoute(
                  //builder: (context) => const FlutterSoundExamples()));
                }),
          ),
          Center(
            child: ElevatedButton(
              child: const Text(
                'τ-audio examples',
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TaudioExamples()));
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('τ Examples'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.stop,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          ),
        ],
      ),
      body: makeBody(),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.blue,
      ),
    );
  }
}
