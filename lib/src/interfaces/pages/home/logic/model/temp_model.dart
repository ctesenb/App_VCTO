import 'package:flutter/material.dart';

class ItemTemp {
  final String? reference;
  final String? qr;
  final String? code;
  final String? description;
  final String? price;
  final String? quantity;
  final String? total;

  ItemTemp(
      {this.reference,
      this.qr,
      this.code,
      this.description,
      this.price,
      this.quantity,
      this.total});
}

class DataSourceTemp extends DataTableSource {
  DataSourceTemp(this.test);

  final List<ItemTemp> test;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= test.length) return null;
    final ItemTemp Temp = test[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(
          Text(Temp.reference!),
        ),
        DataCell(
          Text(Temp.qr!),
        ),
        DataCell(Container(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(Temp.description!),
          ),
        )),
        DataCell(
          Text(Temp.price!),
        ),
        DataCell(
          Text(Temp.quantity!),
        ),
        DataCell(
          Text(Temp.total!),
        ),
        DataCell(IconButton(
          alignment: Alignment.centerLeft,
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            if (test.isNotEmpty) {
              test.removeAt(index);
              notifyListeners();
            }
          },
        )),
      ],
    );
  }

  @override
  int get rowCount => test.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
