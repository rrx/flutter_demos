import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

class MyTabController extends StatefulWidget {
  final int initialIndex;
  final List<(Tab, Widget)> tabs;

  MyTabController({super.key, required this.initialIndex, required this.tabs});

  @override
  State<MyTabController> createState() => _MyTabControllerState();
}

class _MyTabControllerState extends State<MyTabController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print("init to ${widget.initialIndex}");

    void openDrawer() {
      scaffoldKey.currentState!.openDrawer();
    }

    var button = IconButton(
      icon: const Icon(Icons.reddit),
      tooltip: 'Stuff',
      onPressed: () {
        openDrawer();
      },
    );

    return ChangeNotifierProvider(
      create: (context) => LoadingPageState(),
      child: DefaultTabController(
        initialIndex: widget.initialIndex, //appState.index,
        length: widget.tabs.length,
        child: LayoutBuilder(
            builder: (BuildContext context, Constraints constraints) {
          final TabController tabController = DefaultTabController.of(context);

          var appState = context.watch<LoadingPageState>();

          tabController.addListener(() async {
            if (!tabController.indexIsChanging) {
              print('tab change ${tabController.index}');
              appState.save(tabController.index);
            }
          });

          var tabBar = TabBar(
              tabs: widget.tabs.map((e) {
            return e.$1;
          }).toList());

          var page = Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              leading: button,
              flexibleSpace: SafeArea(child: tabBar),
              scrolledUnderElevation: 1.0,
              //title: Text("ASDF"),
              //centerTitle: true,
              //bottom: tabBar,
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Drawer Header',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.message),
                    title: Text('Messages'),
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('Profile'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                  ListTile(
                    leading: Icon(Icons.change_history),
                    title: Text('Change history'),
                    //onTap: () {
                    // change app state...
                    //Navigator.pop(context); // close the drawer
                    //},
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: widget.tabs.map((e) {
                return e.$2;
              }).toList(),
            ),
          );

          return page;
        }),
      ),
    );
  }
}

class LoadingPageState extends ChangeNotifier {
  int index = 0;

  Future<int> loadData() async {
    return SharedPreferences.getInstance().then((SharedPreferences prefs) {
      index = prefs.getInt('tabIndex') ?? 0;
      print("loading2 $index");
      return index;
    });
  }

  void save(int index) async {
    await SharedPreferences.getInstance().then((SharedPreferences prefs) {
      prefs.setInt('tabIndex', index).then((bool success) {
        print("saved $index - $success");
      });
    });
  }
}
