import 'package:app1c/src/interfaces/pages/login/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'interfaces/pages/home/home.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control de Plus',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: AnimatedSplashScreen(
        splash: 'assets/logo-control-plus.png',
        nextScreen: Login(),
        splashTransition: SplashTransition.rotationTransition,
        pageTransitionType: PageTransitionType.fade,
      ),
      routes: {
        Login.id: (context) => Login(),
        Home.id: (context) => Home(),
      },
    );
  }
}
