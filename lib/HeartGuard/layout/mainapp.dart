import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/map/viewMap.dart';

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
      appBar:AppBar(

      ),
      body:Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewMap()),
                );
              },
              child: Text("지도"),
            ),
          ],
        ),
      ),
    );
  }
}