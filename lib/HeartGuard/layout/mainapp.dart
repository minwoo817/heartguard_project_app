import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/Tmap/tmap.dart';


class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyMapPage(),
    );
  }
}
