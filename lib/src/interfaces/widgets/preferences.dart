import 'package:app1c/src/interfaces/pages/home/home.dart';
import 'package:app1c/src/interfaces/pages/login/view/login_view.dart';
import 'package:app1c/src/utils/alertMethods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/apiMethods.dart';
import '../../services/connectionMethods.dart';
import '../pages/home/logic/pref_logic.dart';

String? empresa = '';

class MyPreferences extends StatefulWidget {
  @override
  State<MyPreferences> createState() => _MyPreferencesState();
}

class _MyPreferencesState extends State<MyPreferences> {
  bool newLaunch = false;
  final _formKey = GlobalKey<FormState>();
  final _empresa = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newLaunch = true;
  }

  @override
  void dispose() {
    super.dispose();
    _empresa.dispose();
  }

  loadNewLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bool _newLaunch = ((prefs.getBool('newLaunch') ?? true));
      print("newLaunch:");
      print(_newLaunch);
      newLaunch = _newLaunch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: newLaunch
          ? preferenciasView(formKey: _formKey, empresa: _empresa)
          : Home(),
    );
  }
}

class preferenciasView extends StatefulWidget {
  const preferenciasView({
    Key? key,
    required GlobalKey<FormState> formKey,
    required TextEditingController empresa,
  })  : _formKey = formKey,
        _empresa = empresa,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final TextEditingController _empresa;

  @override
  State<preferenciasView> createState() => _preferenciasViewState();
}

class _preferenciasViewState extends State<preferenciasView> {
  var empresasList;
  var loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listEmpresas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empresas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blueGrey,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Cargando Empresas',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          listEmpresas();
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Reintentar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Iniciar Sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Form(
              key: widget._formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Empresa',
                      ),
                      items: empresasList,
                      onChanged: (value) {
                        widget._empresa.text = value.toString();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione una empresa';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      onPressed: () {
                        if (widget._formKey.currentState!.validate()) {
                          savePreferences();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        }
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'Guardar',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void listEmpresas() async {
    try {
      loading = true;
      var list = await ConnectionMethods().connectionInternalExternalList(
        userLogin!,
      );
      if (list!.length == 1) {
        widget._empresa.text = list[0]!;
        savePreferences();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else if (list.length > 1) {
        var rucNombre = [];
        for (var i = 0; i < list.length; i++) {
          var empresa = await ApiMethods().getNameXRuc(list[i]!);
          if (empresa != null) {
            rucNombre.add([list[i], empresa]);
          } else {
            rucNombre.add([list[i], list[i]]);
          }
        }
        empresasList = rucNombre.map((e) {
          return DropdownMenuItem(
            value: e[0],
            child: Text(e[1]),
          );
        }).toList();
        setState(() {
          loading = false;
        });
      } else {
        AlertMethods().alertaError("El usuario no tiene empresas asociadas");
        setState(() {
          loading = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void savePreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('newLaunch', false);
      prefs.setString('empresa', widget._empresa.text);
      empresa = await getBusiness();
      print('Empresa guardada');
      print('Empresa: ' + empresa!);
      ConnectionMethods().connectionInternalExternal(empresa!);
    } catch (e) {
      print('savePreferences(): ' +
          e.toString() +
          '\n\nError al guardar preferencias');
    }
  }
}
