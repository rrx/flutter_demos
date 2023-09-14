import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tabs.dart';

class LoadingData extends ChangeNotifier {
  SharedPreferences? prefs;

  void load() async {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      this.prefs = prefs;
    });
  }
}

Future<LoadingData> loadData() async {
  return SharedPreferences.getInstance().then((SharedPreferences prefs) {
    LoadingData data = LoadingData();
    data.prefs = prefs;
    //data.tabIndex = prefs.getInt('tabIndex') ?? 0;
    return Future<LoadingData>.delayed(
      const Duration(seconds: 1),
      () => data,
    );
  });
}

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class LoadingWidget extends StatefulWidget {
  final String title;
  final Widget splash;
  final List<(Tab, Widget)> tabs;

  const LoadingWidget({
    super.key,
    required this.title,
    required this.splash,
    required this.tabs,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  late Future<int> initialIndex = loadData();

  Future<int> loadData() async {
    return SharedPreferences.getInstance().then((SharedPreferences prefs) {
      var index = prefs.getInt('tabIndex') ?? 0;
      print("loading2 $index");
      return index;
    });
  }

  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    var builder = FutureBuilder<int>(
      future: initialIndex,
      builder: (context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return widget.splash;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              //LoadingData? data = snapshot.data;
              int? data = snapshot.data;
              if (data != null) {
                int index = data;
                print("y $index");

                return MyTabController(
                  initialIndex: index,
                  tabs: widget.tabs,
                );
              }
            }
            return Placeholder();
        }
      },
    );

    return MaterialApp(
      title: widget.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: builder,
    );
  }
}
