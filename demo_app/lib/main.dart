import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/hello.dart';
import 'src/counter.dart';
import 'src/favorite_word.dart';

void main() {
  runApp(const MyApp());
}

List<(Tab, Widget)> tabs = <(Tab, Widget)>[
  (Tab(text: 'Hello'), HelloWidget()),
  (Tab(text: 'Counter'), CounterPage(title: 'Counter')),
  (Tab(text: 'Words'), WordsPage()),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String title = "ASDF";

  @override
  Widget build(BuildContext context) {
    // var splash = const CircularProgressIndicator();
    var child = LoadingWidget(title: title, splash: SplashPage(), tabs: tabs);

    var childWithNotifier = ChangeNotifierProvider(
        create: (context) => LoadingData(), child: child);

    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: childWithNotifier,
    );
  }
}
