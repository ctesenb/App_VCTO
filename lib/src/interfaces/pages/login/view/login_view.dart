import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import '../../../widgets/preferences.dart';
import '../logic/snackBar_logic.dart';
import 'register_view.dart';

String? userLogin = '';

class LoginView extends StatefulWidget {
  static String id = 'login_view';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static bool _contrasenaVisible = false;
  static bool visible = false;
  static bool googleVisible = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _estaUsuarioAutenticado();
    visible = false;
    googleVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 120.0, bottom: 0.0),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 50.0),
                child: Text(
                  'Inicio de Sesión',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingrese su correo electrónico';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextFormField(
                  controller: _contrasenaController,
                  obscureText: !_contrasenaVisible,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _contrasenaVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _contrasenaVisible = !_contrasenaVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                height: 50,
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_emailController.text.contains('@')) {
                      mostrarSnackBar('Email no correcto', context);
                    } else if (_contrasenaController.text.length < 6) {
                      mostrarSnackBar(
                          'La contraseña debe contener al menos 6 caracteres',
                          context);
                    } else {
                      setState(() {
                        _cambiarEstadoIndicadorProgreso();
                      });
                      acceder(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueGrey,
                    shadowColor: Colors.black45,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                        color: Colors.white70,
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Acceder',
                    //style: TextStyle(color: Colors.white, fontSize: 20,),
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: visible,
                child: const Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '¿No tienes cuenta?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RegisterView()));
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SignInButton(
                Buttons.Google,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(
                    color: Colors.white70,
                    width: 2,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _cambiarEstadoIndicadorProgresoGoogle();
                  });
                  accederGoogle(context);
                },
              ),
              Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: googleVisible,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Container(
                          width: 220,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Colors.blueGrey[800],
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          )))),
            ],
          ),
        ),
      ),
    );
  }

  void _estaUsuarioAutenticado() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null || user == "" || user == ' ') {
        print("Usuario no autenticado");
      } else {
        print("Usuario autenticado");
        print(user.email);
        userLogin = user.email.toString();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyPreferences()));
      }
    });
  }

  Future<void> acceder(BuildContext context) async {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      formState.save();
      try {
        UserCredential credencial = await auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _contrasenaController.text.trim());
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyPreferences()));
        setState(() {
          _cambiarEstadoIndicadorProgreso();
          //usuario tendra el email del usuario que se ha logueado
          userLogin = credencial.user?.email.toString();
          print('Usuario normal:  ' + userLogin.toString());
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found")
          mostrarSnackBar("Usuario desconocido", context);
        else if (e.code == "wrong-password")
          mostrarSnackBar("Contraseña incorrecta", context);
        else
          mostrarSnackBar("Lo sentimos, hubo un error", context);
        setState(() {
          _cambiarEstadoIndicadorProgreso();
        });
      }
    }
  }

  Future<void> accederGoogle(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? _googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication _googleSignInAuthentication =
          await _googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: _googleSignInAuthentication.accessToken,
          idToken: _googleSignInAuthentication.idToken);
      await _auth.signInWithCredential(credential);
      _formKey.currentState!.save();
      setState(() {
        userLogin = _googleSignInAccount.email;
        print('Usuario google: ' + userLogin.toString());
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => new MyPreferences()));
    } catch (e) {
      mostrarSnackBar("Lo sentimos, se produjo un error", context);
    } finally {
      setState(() {
        _cambiarEstadoIndicadorProgresoGoogle();
      });
    }
  }

  void _cambiarEstadoIndicadorProgreso() {
    visible = !visible;
  }

  void _cambiarEstadoIndicadorProgresoGoogle() {
    googleVisible = !googleVisible;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}
