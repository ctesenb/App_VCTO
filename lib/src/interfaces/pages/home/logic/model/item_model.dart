import 'package:flutter/material.dart';

class Item {
  final String? reference;
  final String? qr;
  final String? code;
  final String? description;
  final String? price;
  final String? quantity;
  final String? total;

  Item(
      {this.reference,
      this.qr,
      this.code,
      this.description,
      this.price,
      this.quantity,
      this.total});
}

class DataSource extends DataTableSource {
  DataSource(this.items);

  final List<Item> items;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= items.length) return null;
    final Item item = items[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Container(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(item.description!),
          ),
        )),
        DataCell(
          Text(item.quantity!),
        ),
        DataCell(IconButton(
          alignment: Alignment.centerLeft,
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            if (items.isNotEmpty) {
              items.removeAt(index);
              notifyListeners();
            }
          },
        )),
      ],
    );
  }

  @override
  int get rowCount => items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
