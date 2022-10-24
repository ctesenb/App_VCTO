import 'package:app1c/src/interfaces/pages/home/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemVenta {
  final String? reference;
  final String? qr;
  final String? code;
  final String? description;
  String? price;
  final String? quantity;
  String? total;

  ItemVenta(
      {this.reference,
      this.qr,
      this.code,
      this.description,
      this.price,
      this.quantity,
      this.total});
}

class DataSourceVenta extends DataTableSource {
  DataSourceVenta(this.ventas);

  final List<ItemVenta> ventas;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= ventas.length) return null;
    final ItemVenta venta = ventas[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(
          Text(venta.reference!),
        ),
        DataCell(Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 250),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(venta.description!),
          ),
        )),
        DataCell(
          Text(venta.price!),
          showEditIcon: true,
          onTap: () {
            Get.defaultDialog(
              title: 'Editar precio',
              content: TextField(
                decoration: const InputDecoration(
                  hintText: 'Ingrese el nuevo precio',
                ),
                style: const TextStyle(fontSize: 20),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  venta.price = value;
                  venta.total = (double.parse(venta.price!) *
                          double.parse(venta.quantity!))
                      .toString();
                  notifyListeners();
                },
              ),
              textConfirm: 'Aceptar',
              confirmTextColor: Colors.white,
              onConfirm: () {
                Get.back();
              },
            );
          },
        ),
        DataCell(
          Text(venta.quantity!),
        ),
        DataCell(
          Text(venta.total!),
        ),
        DataCell(
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              ventas.removeAt(index);
              notifyListeners();
            },
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => ventas.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
