import 'package:flutter/material.dart';
import 'package:heartguard_project_app/HeartGuard/map/mapview.dart';

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
      appBar: AppBar(title: Text("헤더"),),
      body: TextButton(onPressed: ()=>{
        Navigator.pushReplacement(
        context ,
        MaterialPageRoute( builder : (content) => MapView() )
        )
      }, child: Text("지도이동")),

    );
  }
}