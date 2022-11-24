import 'package:app1c/src/services/apiMethods.dart';
import 'package:app1c/src/interfaces/pages/home/logic/model/itemventa_model.dart';
import 'package:app1c/src/interfaces/pages/home/logic/model/item_model.dart';
import 'package:app1c/src/interfaces/pages/home/logic/model/temp_model.dart';
import 'package:app1c/src/interfaces/pages/home/logic/pref_logic.dart';
import 'package:app1c/src/utils/pdfMethods.dart';
import 'package:app1c/src/utils/scanMethods.dart';
import 'package:app1c/src/interfaces/pages/login/view/login_view.dart';
import 'package:app1c/src/services/itemMethods.dart';
import 'package:app1c/src/services/movementMethods.dart';
import 'package:app1c/src/utils/alertMethods.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:speech_to_text/speech_to_text.dart' as stts;
import '../../../../connection/external_connection.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var iconStatus = Icons.check_circle_outline;
  var iconStatusColor = Colors.green;
  var status = true;
  var statusError = '';
  var codeController = TextEditingController();
  var itemController = TextEditingController();
  var descController = TextEditingController();
  var cantController = TextEditingController();
  var famiController = TextEditingController();
  var stockController = TextEditingController();
  var precioController = TextEditingController();
  var mic = Icons.mic_external_off;
  var micText = "Mic Off";
  var micColor = Colors.blueGrey;
  bool islistening = false;
  var _speechToText = stts.SpeechToText();
  var micRD = Icons.mic_external_off;
  var micTextRD = "Off";
  var micColorRD = Colors.blueGrey;
  bool islisteningRD = false;
  var _speechToTextRD = stts.SpeechToText();
  var db = Mysql().getConnection();
  bool sort = false;
  List<Item> listItems = <Item>[];
  List<ItemVenta> listItemsVenta = <ItemVenta>[];
  var totalVenta = 0.0;
  var totalItems = 0.0;
  var tipoMovimiento = '';
  var tpLock = false;
  var nombre = '';
  bool itemExiste = false;
  var productosDB = ['Seleccione un Item'];
  bool isLoading = true;
  FocusNode? myFocusNode;
  bool isVenta = false;
  bool isDolar = false;
  String tipoMoneda = ' S/.';
  var quienCompra = TextEditingController();
  bool isPdf = false;
  bool isBoleta = false;
  bool isFactura = false;
  bool isProforma = false;
  bool isTraslado = false;
  bool isInvF = false;
  var nombreQuienCompra = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setNombre();
    listaItemsDB();
    myFocusNode = FocusNode();
    _speechToText = stts.SpeechToText();
    _speechToTextRD = stts.SpeechToText();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    codeController.dispose();
    itemController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(
                  color: Colors.blueGrey,
                  backgroundColor: Colors.grey,
                ),
                SizedBox(
                  height: 10,
                ),
                Text.rich(
                  TextSpan(
                    text: 'Cargando...',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.topCenter,
                  child: Text(
                    nombre.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: 'Tipo de Movimiento',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: 'Seleccionar Movimiento',
                              hintStyle: const TextStyle(color: Colors.black),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Venta',
                                child: Text('Pre-Ventas'),
                              ),
                              DropdownMenuItem(
                                value: 'Consumo',
                                child: Text('Consumos'),
                              ),
                              DropdownMenuItem(
                                value: 'InvF',
                                child: Text('Inv. Físico'),
                              ),
                              DropdownMenuItem(
                                value: 'TrasS',
                                child: Text('Traslado Salida'),
                              ),
                              DropdownMenuItem(
                                value: 'TrasI',
                                child: Text('Traslado Ingreso'),
                              ),
                              DropdownMenuItem(
                                value: 'Otro',
                                child: Text('Otros'),
                              ),
                            ],
                            onChanged: tpLock
                                ? null
                                : (value) {
                                    setState(() {
                                      tipoMovimiento = value.toString();
                                      print(
                                          'Tipo de Movimiento: $tipoMovimiento');
                                      tpLock = true;
                                    });
                                    if (tipoMovimiento == 'Venta') {
                                      setState(() {
                                        isVenta = true;
                                        listItems.clear();
                                        calcularTotalItems();
                                      });
                                    } else {
                                      setState(() {
                                        isVenta = false;
                                        listItemsVenta.clear();
                                        calcularTotalVenta();
                                      });
                                    }
                                    if (tipoMovimiento == 'TrasS' ||
                                        tipoMovimiento == 'TrasI') {
                                      setState(() {
                                        isTraslado = true;
                                      });
                                    } else {
                                      setState(() {
                                        isTraslado = false;
                                      });
                                    }
                                    if (tipoMovimiento == 'InvF') {
                                      setState(() {
                                        isInvF = true;
                                      });
                                    } else {
                                      setState(() {
                                        isInvF = false;
                                      });
                                    }
                                  },
                          ),
                        ),
                        IconButton(
                          onPressed: tpLock
                              ? () {
                                  setState(() {
                                    tpLock = false;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Estado: '),
                        IconButton(
                          icon: Icon(iconStatus, color: iconStatusColor),
                          onPressed: () {
                            if (status) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const AlertDialog(
                                    title: Text('Estado'),
                                    content: Text.rich(
                                      TextSpan(
                                        text: 'El aplicativo se encuentra ',
                                        children: [
                                          TextSpan(
                                            text: 'Activo',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '.',
                                          ),
                                          TextSpan(
                                            text: '\n\nMensaje: ',
                                          ),
                                          TextSpan(
                                            text:
                                                'Aplicativo en funcionamiento',
                                          ),
                                        ],
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 50,
                                    ),
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Estado del sistema'),
                                    content: Text.rich(
                                      TextSpan(
                                        text: 'El aplicativo se encuentra ',
                                        children: [
                                          const TextSpan(
                                            text: 'Inactivo',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '.',
                                          ),
                                          const TextSpan(
                                            text: '\n\nMensaje: ',
                                          ),
                                          TextSpan(
                                            text: statusError,
                                          ),
                                        ],
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (tipoMovimiento == '') {
                      AlertMethods()
                          .alertaInfo('Debe seleccionar un tipo de movimiento');
                    } else {
                      var resultado = await ScanQBMethods().scan();
                      if (resultado != null &&
                          resultado != '' &&
                          resultado != 'null' &&
                          resultado != 'error' &&
                          resultado != ' ') {
                        var split = resultado.split('|');
                        setState(() {
                          codeController.text = split[0];
                          print('Código: ${codeController.text}');
                        });
                        AlertMethods().mostrarDato(codeController.text);
                      } else {
                        setState(() {
                          statusError = 'Error al leer el código QR';
                        });
                      }
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_scanner),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Escanear Referencia'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Referencia',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (tipoMovimiento == '') {
                      AlertMethods()
                          .alertaInfo('Debe seleccionar un tipo de movimiento');
                    } else {
                      var resultado = await ScanQBMethods().scan();
                      if (resultado != null &&
                          resultado != '' &&
                          resultado != 'null' &&
                          resultado != 'error' &&
                          resultado != ' ') {
                        var split = resultado.split('|');
                        setState(() {
                          itemController.text = split[0];
                          print('Item: ${itemController.text}');
                        });
                        descController.text = (await ItemMethods()
                            .getDescriptionItem(itemController.text))!;
                        AlertMethods().mostrarDato(itemController.text);
                      } else {
                        setState(() {
                          statusError = 'Error al leer el item QR';
                        });
                      }
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_scanner),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Escanear Item'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: itemController,
                  decoration: InputDecoration(
                    labelText: 'Item',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: Autocomplete(
                        optionsMaxHeight: 5,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          } else {
                            return productosDB.where((word) => word
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          }
                        },
                        optionsViewBuilder:
                            (context, Function(String) onSelected, options) {
                          return Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                            child: Container(
                              height: 100,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount:
                                    options.length > 5 ? 5 : options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    title: SubstringHighlight(
                                      text: option.toString(),
                                      term: descController.text,
                                      textStyleHighlight: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue),
                                    ),
                                    onTap: () {
                                      onSelected(option.toString());
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                  height: 1,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                        onSelected: (selectedString) {
                          if (tipoMovimiento == '') {
                            AlertMethods().alertaInfo(
                                'Debe seleccionar un tipo de movimiento');
                          } else {
                            getCodigo(selectedString);
                            FocusScope.of(context).unfocus();
                          }
                        },
                        fieldViewBuilder: (context, descController, myFocusNode,
                            onEditingComplete) {
                          this.descController =
                              descController; //TODO: Linea importante
                          return TextFormField(
                            toolbarOptions: const ToolbarOptions(
                              copy: true,
                              cut: true,
                              paste: true,
                              selectAll: true,
                            ),
                            textInputAction: TextInputAction.done,
                            controller: descController,
                            focusNode: myFocusNode,
                            onEditingComplete: onEditingComplete,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: micColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (mic == Icons.mic_external_off) {
                          setState(() {
                            mic = Icons.mic_external_on;
                            micText = "Mic On";
                            micColor = Colors.blue;
                            islistening = true;
                          });
                          listen();
                        } else {
                          setState(() {
                            mic = Icons.mic_external_off;
                            micText = "Mic Off";
                            micColor = Colors.blueGrey;
                            islistening = false;
                            _speechToText.stop();
                          });
                        }
                      },
                      child: Column(
                        children: [
                          const Text('Voz'),
                          Icon(mic),
                          Text(micText),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: isVenta
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (tipoMovimiento == 'Venta') {
                                  print('ES VENTA');
                                  print('isVenta: $isVenta');
                                  if (descController.text != '') {
                                    add();
                                  } else {
                                    AlertMethods().alertaInfo(
                                        'Los campos Item y Descripción\nno pueden estar vacíos');
                                  }
                                } else {
                                  AlertMethods().alertaInfo(
                                      'Debe seleccionar un tipo de movimiento');
                                }
                              },
                              child: const Text('Agregar Item'),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (tipoMovimiento != '') {
                                  print('NO ES VENTA');
                                  print('isVenta: $isVenta');
                                  if (descController.text != '') {
                                    add();
                                  } else {
                                    AlertMethods().alertaInfo(
                                        'Los campos Item y Descripción\nno pueden estar vacíos');
                                  }
                                } else {
                                  AlertMethods().alertaInfo(
                                      'Debe seleccionar un tipo de movimiento');
                                }
                              },
                              child: const Text('Agregar Item'),
                            ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (tipoMovimiento != '') {
                            limpiarCampos();
                          } else {
                            AlertMethods().alertaInfo(
                                'Debe seleccionar un tipo de movimiento');
                          }
                        },
                        child: const Text('Limpiar Campos'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: isVenta
                          ? PaginatedDataTable(
                              columnSpacing: 15,
                              horizontalMargin: 20,
                              headingRowHeight: 50,
                              dataRowHeight: 50,
                              header: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Limpiar Lista ',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35),
                                        ),
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.blueGrey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            if (tipoMovimiento != '') {
                                              if (listItemsVenta.isNotEmpty) {
                                                setState(() {
                                                  listItemsVenta.clear();
                                                });
                                                calcularTotalVenta();
                                              } else {
                                                AlertMethods().alertaInfo(
                                                    'La lista ya se encuentra vacia');
                                                calcularTotalVenta();
                                              }
                                            } else {
                                              AlertMethods().alertaInfo(
                                                  'Debe seleccionar un tipo de movimiento');
                                            }
                                          },
                                          icon: const Icon(Icons.delete_forever,
                                              color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: isDolar
                                              ? const Icon(Icons.attach_money,
                                                  color: Colors.green)
                                              : const Icon(Icons.money,
                                                  color: Colors.orange),
                                          onPressed: () {
                                            setState(() {
                                              isDolar = !isDolar;
                                            });
                                            if (tipoMovimiento != '') {
                                              if (listItemsVenta.isNotEmpty) {
                                                calcularTotalVenta();
                                              } else {
                                                AlertMethods().alertaInfo(
                                                    'No existe un total a calcular');
                                              }
                                            } else {
                                              AlertMethods().alertaInfo(
                                                  'Debe seleccionar un tipo de movimiento');
                                            }
                                          },
                                        ),
                                        Text('Total: ',
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    35)),
                                        Text(tipoMoneda,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30,
                                                color: Colors.blueGrey)),
                                        Text('$totalVenta',
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30,
                                                color: Colors.blueGrey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              rowsPerPage:
                                  MediaQuery.of(context).size.height ~/ 271,
                              sortAscending: sort,
                              sortColumnIndex: 0,
                              columns: [
                                DataColumn(
                                  label: Text('Nombre del Item',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35)),
                                  numeric: false,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                    });
                                    if (sort) {
                                      listItemsVenta.sort((a, b) => a
                                          .description!
                                          .compareTo(b.description!));
                                    } else {
                                      listItemsVenta.sort((a, b) => b
                                          .description!
                                          .compareTo(a.description!));
                                    }
                                  },
                                ),
                                DataColumn(
                                  label: Text('P.U.',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35)),
                                  numeric: false,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                    });
                                    if (sort) {
                                      listItemsVenta.sort((a, b) =>
                                          a.price!.compareTo(b.price!));
                                    } else {
                                      listItemsVenta.sort((a, b) =>
                                          b.price!.compareTo(a.price!));
                                    }
                                  },
                                ),
                                DataColumn(
                                  label: Text('Cantidad',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35)),
                                  numeric: true,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                    });
                                    if (sort) {
                                      listItemsVenta.sort((a, b) =>
                                          a.quantity!.compareTo(b.quantity!));
                                    } else {
                                      listItemsVenta.sort((a, b) =>
                                          b.quantity!.compareTo(a.quantity!));
                                    }
                                  },
                                ),
                                DataColumn(
                                  label: Text('Total',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35)),
                                  numeric: true,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                    });
                                    if (sort) {
                                      listItemsVenta.sort((a, b) =>
                                          a.total!.compareTo(b.total!));
                                    } else {
                                      listItemsVenta.sort((a, b) =>
                                          b.total!.compareTo(a.total!));
                                    }
                                  },
                                ),
                                DataColumn(
                                  label: Text('Acciones',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35)),
                                ),
                              ],
                              source: DataSourceVenta(listItemsVenta),
                            )
                          : PaginatedDataTable(
                              header: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Limpiar Lista ',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35),
                                        ),
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.blueGrey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            if (tipoMovimiento != '') {
                                              if (listItemsVenta.isNotEmpty) {
                                                setState(() {
                                                  listItemsVenta.clear();
                                                });
                                                calcularTotalItems();
                                              } else {
                                                AlertMethods().alertaInfo(
                                                    'La lista ya se encuentra vacia');
                                                calcularTotalVenta();
                                              }
                                            } else {
                                              AlertMethods().alertaInfo(
                                                  'Debe seleccionar un tipo de movimiento');
                                            }
                                          },
                                          icon: const Icon(Icons.refresh),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Icon(
                                            Icons.production_quantity_limits),
                                        Text('Total Items: ',
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    35)),
                                        Text('$totalItems',
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    30,
                                                color: Colors.blueGrey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              rowsPerPage:
                                  MediaQuery.of(context).size.height ~/ 271,
                              sortAscending: sort,
                              sortColumnIndex: 0,
                              columns: [
                                DataColumn(
                                  tooltip: 'Descripcion',
                                  label: const Icon(Icons.description),
                                  numeric: false,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                    });
                                    if (sort) {
                                      listItems.sort((a, b) => a.description!
                                          .compareTo(b.description!));
                                    } else {
                                      listItems.sort((a, b) => b.description!
                                          .compareTo(a.description!));
                                    }
                                  },
                                ),
                                DataColumn(
                                  tooltip: 'Cantidad',
                                  label: const Icon(Icons
                                      .production_quantity_limits_sharp), //Icons.production_quantity_limits),
                                  numeric: true,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                    });
                                    if (sort) {
                                      listItems.sort((a, b) =>
                                          a.quantity!.compareTo(b.quantity!));
                                    } else {
                                      listItems.sort((a, b) =>
                                          b.quantity!.compareTo(a.quantity!));
                                    }
                                  },
                                ),
                                const DataColumn(
                                  tooltip: 'Eliminar',
                                  label: Icon(Icons.delete),
                                  numeric: false,
                                ),
                              ],
                              source: DataSource(listItems),
                            ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: isVenta
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.white54),
                            ),
                            minimumSize: const Size(200, 50),
                          ),
                          onPressed: () {
                            if (listItemsVenta.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Tipo de Documento'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: const <Widget>[
                                          Text(
                                              'Seleccione el tipo de documento'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Proforma'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          isProforma = true;
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Tipo de Documento'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text(
                                                          'Desea usar un numero de documento?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child:
                                                        const Text('DNI/RUC'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      realizarPreVenta();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text(
                                                        'SIN DNI/RUC'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      enviarListPdf();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Boleta'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          isBoleta = true;
                                          if (totalVenta > 700) {
                                            realizarPreVenta();
                                          } else {
                                            nombreQuienCompra = '---';
                                            enviarListPdf();
                                          }
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Factura'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          isFactura = true;
                                          realizarPreVenta();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              AlertMethods().alertaInfo(
                                  'No hay items para realizar la pre venta');
                            }
                          },
                          child: const Text('Realizar Pre-Venta',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.white54),
                            ),
                            minimumSize: const Size(200, 50),
                          ),
                          onPressed: () {
                            if (listItems.isNotEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      elevation: 5,
                                      title: const Text(
                                        'Guardar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      actions: [
                                        Flex(
                                          direction: Axis.horizontal,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  isPdf = false;
                                                  if (isTraslado == true) {
                                                    realizarTraslado();
                                                  } else if (isInvF = true) {
                                                    enviarListPdf();
                                                  } else {
                                                    enviarListPdf();
                                                  }
                                                },
                                                child:
                                                    const Text('Solo Guardar'),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isPdf = true;
                                                  if (isTraslado == true) {
                                                    print(
                                                        'traslado -- ESTOY ACA');
                                                    realizarTraslado();
                                                  } else if (isInvF = true) {
                                                    enviarListPdf();
                                                  } else {
                                                    enviarListPdf();
                                                  }
                                                },
                                                child: const Text(
                                                    'Guardar y Exportar'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              AlertMethods()
                                  .alertaInfo('No hay items para guardar');
                            }
                          },
                          child: const Text('Guardar Lista',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                ),
              ],
            ),
          );
  }

  void setNombre() async {
    try {
      status = true;
      var nom = await getBusiness();

      nombre = (await ApiMethods().getNameXRuc(nom!))!;
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al obtener el nombre de la empresa';
      });
    }
  }

  listaItemsDB() async {
    try {
      isLoading = true;
      productosDB = (await ItemMethods().getListDescriptionItem())!;
      setState(() {
        isLoading = false;
        status = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al cargar la lista de Items de la base de datos';
      });
    }
  }

  getCodigo(String description) async {
    try {
      status = true;
      String? externalCode =
          await ItemMethods().getExternalCodeItem(description);
      print('ExternalCode: $externalCode');
      bool? existsExternalCode =
          await ItemMethods().existsExternalCodeItem(description);
      if (existsExternalCode == true) {
        setState(() {
          itemController.text = externalCode!;
        });
      } else {
        AlertMethods()
            .alertaInfo('El item no tiene codigo de barras o no existe');
      }
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al obtener el codigo';
      });
    }
  }

  void listen() async {
    try {
      status = true;
      bool available = await _speechToText.initialize(
          onStatus: (status) => print('onStatus: $status'),
          onError: (errorNotificacion) => print('onError: $errorNotificacion'));
      if (available) {
        _speechToText.listen(onResult: (result) {
          setState(() {
            FocusScope.of(context).unfocus();
            descController.text = ItemMethods().firstUp(result.recognizedWords);
          });
          if (result.finalResult) {
            _speechToText.stop();
            mic = Icons.mic_external_off;
            micText = "Mic Off";
            micColor = Colors.blueGrey;
            islistening = false;
            getCodigo(descController.text);
            FocusScope.of(context).requestFocus(FocusNode());
          }
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        FocusScope.of(context).unfocus();
        islistening = false;
        status = false;
        statusError = 'Error al usar el boton de voz';
      });
      _speechToText.stop();
    }
  }

  void listenRD() async {
    try {
      status = true;
      bool available = await _speechToTextRD.initialize(
          onStatus: (status) => print('onStatus: $status'),
          onError: (errorNotificacion) => print('onError: $errorNotificacion'));
      if (available) {
        _speechToTextRD.listen(onResult: (result) {
          setState(() {
            quienCompra.text = result.recognizedWords;
            nombreQuienCompra = quienCompra.text;
          });
          if (result.finalResult) {
            _speechToTextRD.stop();
            micRD = Icons.mic_external_off;
            micTextRD = "Mic Off";
            micColorRD = Colors.blueGrey;
            islisteningRD = false;
          }
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        islisteningRD = false;
        status = false;
        statusError = 'Error al usar el boton de voz';
      });
    }
  }

  limpiarControllers() {
    setState(() {
      itemController.text = '';
      descController.text = '';
      cantController.text = '';
      FocusScope.of(context).unfocus();
    });
  }

  limpiarCampos() {
    setState(() {
      statusError = '';
      isFactura = false;
      isBoleta = false;
      isProforma = false;
      isPdf = false;
      isTraslado = false;
      isInvF = false;
    });
  }

  addItemListVenta() async {
    try {
      if (listItemsVenta.any((element) => element.qr == itemController.text)) {
        listItemsVenta
            .removeWhere((element) => element.qr == itemController.text);
        double? precio = await ItemMethods().getPriceItem(itemController.text);
        double? total = double.parse(cantController.text) * precio!;
        var codeInterno =
            await ItemMethods().getInternalCodeItem(descController.text);
        setState(() {
          status = true;
          listItemsVenta.add(
            ItemVenta(
              reference: codeController.text,
              qr: itemController.text,
              code: codeInterno,
              description: descController.text,
              price: precio.toString(),
              quantity: cantController.text,
              total: total.toString(),
            ),
          );
        });
      } else {
        double? precio = await ItemMethods().getPriceItem(itemController.text);
        double? total = double.parse(cantController.text) * precio!;
        var codeInterno =
            await ItemMethods().getInternalCodeItem(descController.text);
        setState(() {
          status = true;
          listItemsVenta.add(
            ItemVenta(
              reference: codeController.text,
              qr: itemController.text,
              code: codeInterno,
              description: descController.text,
              price: precio.toString(),
              quantity: cantController.text,
              total: total.toString(),
            ),
          );
        });
      }
      limpiarCampos();
      calcularTotalVenta();
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al agregar el item a la lista de pre-venta';
      });
    }
  }

  addNewItem() async {
    try {
      /*
      *YA TENGO EL EXTERNALCODE, LA FAMILIA, PRECIO Y STOCK
      */
      String? newInternalCode =
          await ItemMethods().createNewInternalCodeItem(famiController.text);
      bool? existsInternalCode = await ItemMethods()
          .existsInternalCodeItemInternalCode(newInternalCode!);
      if (existsInternalCode == true) {
        addNewItem();
      } else {
        await ItemMethods().insertNewItem(
            itemController.text,
            newInternalCode,
            descController.text,
            userLogin!,
            stockController.text,
            precioController.text);
        AlertMethods().alertaInfo('Item creado correctamente');
        await add();
      }
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al agregar el item a la base de datos';
      });
    }
  }

  addPriceItem() {
    try {
      double priceItem = 1.0;
      precioController.text = priceItem.toString();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Asignar Precio'),
              content: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          priceItem += 1;
                          precioController.text =
                              priceItem.toStringAsFixed(2).toString();
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.blue),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 200,
                      child: TextField(
                        controller: precioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Precio',
                          hintText: 'Precio',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          priceItem -= 1;
                          if (priceItem < 0) {
                            priceItem = double.parse(0.1.toStringAsFixed(2));
                          }
                          precioController.text =
                              double.parse(priceItem.toStringAsFixed(2))
                                  .toString();
                        });
                      },
                      icon: const Icon(Icons.remove, color: Colors.red),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    addPriceItemDB();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          });
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al agregar el precio al item';
      });
    }
  }

  addPriceItemDB() async {
    try {
      ItemMethods().setPriceItem(itemController.text, precioController.text);
      AlertMethods().alertaInfo('Precio asignado correctamente');
      await add();
    } catch (e) {
      print('addPriceItemDB: $e');
    }
  }

  add() async {
    /*
    *SE AGREGA EL ITEM A LA TABLA
    */
    try {
      bool? existsExternalCode =
          await ItemMethods().existsExternalCodeItem(descController.text);
      bool? existsInternalCode =
          await ItemMethods().existsInternalCodeItem(descController.text);
      if (existsExternalCode == false && existsInternalCode == false) {
        /*
        *EL ITEM NO EXISTE EN LA DB
        */
        if (itemController.text.isEmpty) {
          AlertMethods()
              .alertaInfo('REQUERIDO\nIngrese un codigo de BARRAS/QR');
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text(
                        'El item no existe en la base de datos, desea registrarlo?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            asignarFamilia();
                          },
                          child: const Text('Registrar')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            limpiarCampos();
                          },
                          child: const Text('Cancelar')),
                    ],
                  ));
        }
      } else if (existsInternalCode == true && existsExternalCode == false) {
        /*
        *EL ITEM EXISTE PERO NO TIENE UN EXTERNAL CODE (QR)
        */
        if (itemController.text.isEmpty) {
          AlertMethods()
              .alertaInfo('REQUERIDO\nIngrese un codigo de BARRAS/QR');
        } else {
          await ItemMethods()
              .setExternalCodeItem(descController.text, itemController.text);
          add();
          AlertMethods()
              .alertaInfo('Codigo de BARRAS/QR agregado correctamente');
        }
      } else {
        /*
        *EL ITEM EXISTE Y TIENE UN EXTERNAL CODE (QR)
        */
        double? priceItem =
            await ItemMethods().getPriceItem(itemController.text);
        if (priceItem == null && isVenta == true) {
          /*
          *EL ITEM NO TIENE PRECIO
          */
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text(
                        'El item no tiene un precio asignado, desea asignarle uno?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            addPriceItem();
                          },
                          child: const Text('Asignar')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            limpiarControllers();
                          },
                          child: const Text('Cancelar')),
                    ],
                  ));
        } else {
          /*
          *EL ITEM TIENE PRECIO
          */
          double cantidad = 1.0;
          cantController.text = cantidad.toString();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  elevation: 5,
                  title: const Text(
                    'Cantidad',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'El precio del Item es: ',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          Text(
                            'S/. ${priceItem.toString()}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            splashColor: Colors.blue,
                            onPressed: () {
                              setState(() {
                                cantidad += 1;
                                cantController.text =
                                    cantidad.toStringAsFixed(2).toString();
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.blue),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 200,
                            child: TextField(
                              controller: cantController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Cantidad',
                                hintText: 'Cantidad',
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                cantidad -= 1;
                                if (cantidad < 0) {
                                  cantidad =
                                      double.parse(0.1.toStringAsFixed(2));
                                }
                                cantController.text =
                                    double.parse(cantidad.toStringAsFixed(2))
                                        .toString();
                              });
                            },
                            icon: const Icon(Icons.remove, color: Colors.red),
                            splashColor: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        limpiarControllers();
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                        setState(() {
                          if (isVenta != true) {
                            addItemList();
                          } else {
                            addItemListVenta();
                          }
                        });
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                );
              });
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al obtener la cantidad';
      });
    }
  }

  asignarFamilia() async {
    try {
      /*
      *ASIGNO LOS DATOS PARA EL NUEVO QUE ES FAMILIA, STOCK Y PRECIO
      */
      var familiasListDB = await ItemMethods().getListFamilyItem();
      famiController.text = '';
      double stockItem = 1.0;
      stockController.text = '';
      double priceItem = 1.0;
      precioController.text = '';
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Registrar Item'),
              content: Container(
                  height: 220,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Familia',
                          ),
                          items: familiasListDB!
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            famiController.text = value.toString();
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione una familia';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                stockItem += 1;
                                cantController.text =
                                    stockItem.toStringAsFixed(2).toString();
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.blue),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 200,
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Stock',
                                hintText: 'Stock',
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                stockItem -= 1;
                                if (stockItem < 0) {
                                  stockItem =
                                      double.parse(0.1.toStringAsFixed(2));
                                }
                                stockController.text =
                                    double.parse(stockItem.toStringAsFixed(2))
                                        .toString();
                              });
                            },
                            icon: const Icon(Icons.remove, color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                priceItem += 1;
                                precioController.text =
                                    priceItem.toStringAsFixed(2).toString();
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.blue),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 200,
                            child: TextField(
                              controller: precioController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Precio',
                                hintText: 'Precio',
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                priceItem -= 1;
                                if (priceItem < 0) {
                                  priceItem =
                                      double.parse(0.1.toStringAsFixed(2));
                                }
                                precioController.text =
                                    double.parse(priceItem.toStringAsFixed(2))
                                        .toString();
                              });
                            },
                            icon: const Icon(Icons.remove, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  )),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    addNewItem();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          });
      FocusScope.of(context).unfocus();
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al obtener la familia';
      });
    }
  }

  calcularTotalVenta() async {
    try {
      var priceChange = await ApiMethods().getChange();
      var totalValor = 0.0;
      for (var i = 0; i < listItemsVenta.length; i++) {
        totalValor += double.parse(listItemsVenta[i].total!);
      }
      print('TOTAL: $totalValor');
      if (isDolar == false) {
        setState(() {
          status = true;
          tipoMoneda = ' S/';
          totalValor = double.parse((totalValor).toStringAsFixed(2));
          print('Total en soles: $totalValor');
          totalVenta = totalValor;
        });
      } else {
        setState(() {
          status = true;
          tipoMoneda = ' \$ ';
          totalValor =
              double.parse((totalValor / priceChange!).toStringAsFixed(2));
          print('Total en dolares: $totalValor');
          totalVenta = totalValor;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al calcular el total de la venta';
      });
    }
  }

  addItemList() {
    try {
      if (listItems.any((element) => element.qr == itemController.text)) {
        listItems.removeWhere((element) => element.qr == itemController.text);
        setState(() {
          status = true;
          listItems.add(
            Item(
              reference: codeController.text,
              qr: itemController.text,
              description: descController.text,
              quantity: cantController.text,
            ),
          );
        });
      } else {
        setState(() {
          status = true;
          listItems.add(
            Item(
              reference: codeController.text,
              qr: itemController.text,
              description: descController.text,
              quantity: cantController.text,
            ),
          );
        });
      }
      limpiarControllers();
      calcularTotalItems();
    } catch (e) {
      print('addItemList: $e');
      setState(() {
        status = false;
        statusError = 'Error al agregar el item a la lista';
      });
    }
  }

  calcularTotalItems() {
    try {
      var total = 0.0;
      for (var i = 0; i < listItems.length; i++) {
        total += double.parse(listItems[i].quantity!);
      }
      setState(() {
        status = true;
        totalItems = total;
      });
    } catch (e) {
      print('calcularTotalItems: $e');
      setState(() {
        status = false;
        statusError = 'Error al calcular el total de items';
      });
    }
  }

  enviarListPdf() async {
    try {
      List<ItemTemp> listItemsVentaTemp = <ItemTemp>[];
      List<ItemTemp> listItemsTemp = <ItemTemp>[];
      String? newIdMovement = await MovementMethods()
          .createNewIdMovement(tipoMovimiento, isBoleta, isFactura, isProforma);
      bool? existNewIdMovement =
          await MovementMethods().existsIdMovement(newIdMovement!);
      if (existNewIdMovement == true) {
        enviarListPdf();
      } else {
        if (tipoMovimiento == 'Venta') {
          var priceChange = await ApiMethods().getChange();
          var total = 0.0;
          var totalsoles = double.parse((total).toStringAsFixed(2)).toString();
          var totaldolares =
              double.parse((total / priceChange!).toStringAsFixed(2))
                  .toString();
          if (isBoleta == true) {
            int? idautomatico = await MovementMethods().insertMovement(
                newIdMovement,
                nombre,
                quienCompra.text,
                nombreQuienCompra,
                userLogin!,
                tipoMovimiento,
                totalsoles,
                totaldolares,
                'Pre-Boleta');
            for (var i = 0; i < listItemsVenta.length; i++) {
              total += double.parse(listItemsVenta[i].total!);
              listItemsVentaTemp.add(
                ItemTemp(
                  reference: listItemsVenta[i].reference,
                  qr: listItemsVenta[i].qr,
                  code: listItemsVenta[i].code,
                  description: listItemsVenta[i].description,
                  quantity: listItemsVenta[i].quantity,
                  price: listItemsVenta[i].price,
                  total: listItemsVenta[i].total,
                ),
              );
              MovementMethods().insertMovementDetails(
                idautomatico.toString(),
                newIdMovement,
                listItemsVenta[i].reference!,
                listItemsVenta[i].qr!,
                listItemsVenta[i].description!,
                listItemsVenta[i].quantity!,
                listItemsVenta[i].total!,
              );
            }
            PdfMethods().createPdfMix(
                totalsoles,
                totaldolares,
                nombreQuienCompra,
                newIdMovement,
                listItemsVentaTemp,
                'PRE BOLETA ELECTRONICA');
          } else if (isFactura == true) {
            int? idautomatico = await MovementMethods().insertMovement(
                newIdMovement,
                nombre,
                quienCompra.text,
                nombreQuienCompra,
                userLogin!,
                tipoMovimiento,
                totalsoles,
                totaldolares,
                'Pre-Factura');
            for (var i = 0; i < listItemsVenta.length; i++) {
              total += double.parse(listItemsVenta[i].total!);
              listItemsVentaTemp.add(
                ItemTemp(
                  reference: listItemsVenta[i].reference,
                  qr: listItemsVenta[i].qr,
                  code: listItemsVenta[i].code,
                  description: listItemsVenta[i].description,
                  quantity: listItemsVenta[i].quantity,
                  price: listItemsVenta[i].price,
                  total: listItemsVenta[i].total,
                ),
              );
              MovementMethods().insertMovementDetails(
                idautomatico.toString(),
                newIdMovement,
                listItemsVenta[i].reference!,
                listItemsVenta[i].qr!,
                listItemsVenta[i].description!,
                listItemsVenta[i].quantity!,
                listItemsVenta[i].total!,
              );
            }
            PdfMethods().createPdfMix(
                totalsoles,
                totaldolares,
                nombreQuienCompra,
                newIdMovement,
                listItemsVentaTemp,
                'PRE FACTURA ELECTRONICA');
          } else if (isProforma == true) {
            int? idautomatico = await MovementMethods().insertMovement(
                newIdMovement,
                nombre,
                quienCompra.text,
                nombreQuienCompra,
                userLogin!,
                tipoMovimiento,
                totalsoles,
                totaldolares,
                'Proforma');
            for (var i = 0; i < listItemsVenta.length; i++) {
              total += double.parse(listItemsVenta[i].total!);
              listItemsVentaTemp.add(
                ItemTemp(
                  reference: listItemsVenta[i].reference,
                  qr: listItemsVenta[i].qr,
                  code: listItemsVenta[i].code,
                  description: listItemsVenta[i].description,
                  quantity: listItemsVenta[i].quantity,
                  price: listItemsVenta[i].price,
                  total: listItemsVenta[i].total,
                ),
              );
              MovementMethods().insertMovementDetails(
                idautomatico.toString(),
                newIdMovement,
                listItemsVenta[i].reference!,
                listItemsVenta[i].qr!,
                listItemsVenta[i].description!,
                listItemsVenta[i].quantity!,
                listItemsVenta[i].total!,
              );
            }
            PdfMethods().createPdfMix(
                totalsoles,
                totaldolares,
                nombreQuienCompra,
                newIdMovement,
                listItemsVentaTemp,
                'PROFORMA ELECTRONICA');
          }
        } else {
          int? idautomatico = await MovementMethods().insertMovement(
              newIdMovement,
              nombre,
              quienCompra.text,
              nombreQuienCompra,
              userLogin!,
              tipoMovimiento,
              '0',
              '0',
              tipoMovimiento);

          for (var i = 0; i < listItems.length; i++) {
            MovementMethods().insertMovementDetails(
              idautomatico.toString(),
              newIdMovement,
              listItems[i].reference!,
              listItems[i].qr!,
              listItems[i].description!,
              listItems[i].quantity!,
              '0',
            );
            print('GUARDO ITEMS');
            listItemsTemp.add(
              ItemTemp(
                reference: listItems[i].reference ?? '',
                qr: listItems[i].qr,
                code: listItems[i].code,
                description: listItems[i].description,
                quantity: listItems[i].quantity,
                price: listItems[i].price ?? '0',
                total: listItems[i].total ?? '0',
              ),
            );
          }
          if (isPdf == true) {
            PdfMethods().createPdf(nombreQuienCompra, newIdMovement,
                listItemsTemp, tipoMovimiento);
          }
        }
      }
      setState(() {
        status = true;
        totalItems = 0;
        totalVenta = 0.0;
        quienCompra.clear();
        isPdf = false;
        codeController.clear();
      });
    } catch (e) {
      print('enviarListPdf: $e');
      setState(() {
        status = false;
        statusError = 'Error al enviar la venta';
      });
    }
  }

  realizarPreVenta() {
    try {
      var ruc = '';
      quienCompra.text = ruc;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ingrese RUC o DNI'),
            content: Row(
              children: [
                Container(
                  width: 300,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: quienCompra,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'RUC o DNI',
                      hintText: 'RUC o DNI',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 65,
                  width: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: micColorRD,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (micRD == Icons.mic_external_off) {
                        setState(() {
                          micRD = Icons.mic_external_on;
                          micTextRD = "On";
                          micColorRD = Colors.blue;
                          islisteningRD = true;
                        });
                        listenRD();
                      } else {
                        setState(() {
                          micRD = Icons.mic_external_off;
                          micTextRD = "Off";
                          micColorRD = Colors.blueGrey;
                          islisteningRD = false;
                          _speechToTextRD.stop();
                        });
                      }
                    },
                    child: Column(
                      children: [
                        const Text('Voz'),
                        Icon(micRD),
                        Text(micTextRD),
                      ],
                    ),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  buscarNombre(quienCompra.text);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al realizar la pre-venta';
      });
    }
  }

  buscarNombre(String datoX) async {
    try {
      if (datoX.length < 12 && datoX.length > 7) {
        var nombre = await ApiMethods().getNameXRuc(datoX);
        print('Nombre que obtengo por ruc: $nombre');
        if (nombre == null) {
          nombre = await ApiMethods().getNameXDni(datoX);
          print('Nombre que obtengo por dni: $nombre');
          if (nombre == null) {
            AlertMethods().alertaError('No se encontró el RUC o DNI');
          } else {
            nombreQuienCompra = nombre;
            if (nombreQuienCompra != null ||
                nombreQuienCompra != '' ||
                nombreQuienCompra != 'null') {
              enviarListPdf();
            }
          }
        } else {
          nombreQuienCompra = nombre;
          if (nombreQuienCompra != null ||
              nombreQuienCompra != '' ||
              nombreQuienCompra != 'null') {
            enviarListPdf();
          }
        }
      } else {
        AlertMethods().alertaError(
            'El numero de documento \nDebe tener entre 8 a 11 digitos');
      }
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al buscar el nombre';
      });
    }
  }

  realizarTraslado() {
    try {
      var traslado = '';
      quienCompra.text = traslado;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ingrese el Receptor'),
            content: Row(
              children: [
                Container(
                  width: 300,
                  child: TextField(
                    controller: quienCompra,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Receptor',
                      hintText: 'Receptor',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 65,
                  width: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: micColorRD,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (micRD == Icons.mic_external_off) {
                        setState(() {
                          micRD = Icons.mic_external_on;
                          micTextRD = "On";
                          micColorRD = Colors.blue;
                          islisteningRD = true;
                        });
                        listenRD();
                      } else {
                        setState(() {
                          micRD = Icons.mic_external_off;
                          micTextRD = "Off";
                          micColorRD = Colors.blueGrey;
                          islisteningRD = false;
                          _speechToTextRD.stop();
                        });
                      }
                    },
                    child: Column(
                      children: [
                        const Text('Voz'),
                        Icon(micRD),
                        Text(micTextRD),
                      ],
                    ),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  nombreQuienCompra = quienCompra.text;
                  if (nombreQuienCompra != null ||
                      nombreQuienCompra != '' ||
                      nombreQuienCompra != 'null') {
                    enviarListPdf();
                  } else {
                    AlertMethods()
                        .alertaError('Ingrese el nombre del receptor');
                  }
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
      setState(() {
        status = false;
        statusError = 'Error al realizar la pre-venta';
      });
    }
  }
}
