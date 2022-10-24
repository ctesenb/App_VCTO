import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';

import 'view/login_view.dart';

class Login extends StatefulWidget {
  static String id = 'login_page';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control Plus',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Control Plus'),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Restart.restartApp();
                  },
                  child: Row(
                    children: [
                      Text('Reiniciar App', style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.refresh, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Row(
                    children: [
                      Text('Salir', style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.exit_to_app_sharp, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: LoginView(),
      ),
    );
  }
}