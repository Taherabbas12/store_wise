import 'package:flutter/material.dart';
import '../../model/basket_client_model.dart';
import '../widgets/widgers_more.dart';

class ShowMenuScreen extends StatelessWidget {
  ShowMenuScreen({super.key, required this.basketClient});

  List<BasketClientModel> basketClient;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListView(children: [
        Row(
          children: [
            showMenu(
              context,
              basketClient,
            )
          ],
        )
      ]),
    );
  }

  Widget showMenu(BuildContext context, List<BasketClientModel> basketClient) {
    bool isBlackRow = false;
    return Expanded(
      child: DataTable(
        columnSpacing: MediaQuery.sizeOf(context).width * 0.08,
        dataRowMaxHeight: 60,
        headingRowHeight: 60,
        columns: const [
          DataColumn(label: Text('ت', textAlign: TextAlign.center)),
          DataColumn(label: Text('اسم المنتج', textAlign: TextAlign.center)),
          DataColumn(label: Text('سعر المنتج', textAlign: TextAlign.center)),
          DataColumn(label: Text('العدد', textAlign: TextAlign.center)),
          DataColumn(
            label: Text('المجموع', textAlign: TextAlign.center),
          )
        ],
        rows: List.generate(basketClient.length, (i) {
          isBlackRow = !isBlackRow; // تبديل قيمة متغير اللون
          // استخدام الدالة:

          return DataRow(
            color: isBlackRow
                ? MaterialStateColor.resolveWith((_) => Colors.grey.shade300)
                : MaterialStateColor.resolveWith((_) => Colors.white),
            cells: [
              DataCell(Text((i + 1).toString(), textAlign: TextAlign.center)),
              DataCell(Text(basketClient[i].nameProduct,
                  textAlign: TextAlign.center)),
              DataCell(Text(basketClient[i].price.toString(),
                  textAlign: TextAlign.center)),
              DataCell(Text(basketClient[i].requiredQuantity.toString(),
                  textAlign: TextAlign.center)),
              DataCell(
                Text(formatCurrency(basketClient[i].totalPrice.toString()),
                    textAlign: TextAlign.center),
              ),
            ],
          );
        }),
      ),
    );
  }
}
