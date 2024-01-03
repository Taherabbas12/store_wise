import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../constants/colors_cos.dart';
import '../../model/debt_model.dart';

Widget textFormField(String hint, TextEditingController controller,
    {double w = 300}) {
  return Container(
    margin: const EdgeInsets.all(5),
    width: w,
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorHover),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorSelectField),
        ),
        labelText: hint,
      ),
      keyboardType: TextInputType.number,
    ),
  );
}

Widget textFormFieldNumber(String hint, TextEditingController controller,
    {double w = 300}) {
  return Container(
    margin: const EdgeInsets.all(5),
    width: w,
    child: TextFormField(
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorHover),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorSelectField),
          ),
          labelText: hint,
        )),
  );
}

Widget discountTextFormFieldNumber(
    String hint, TextEditingController controller,
    {double w = 300}) {
  return Container(
    margin: const EdgeInsets.all(5),
    width: w,
    child: TextFormField(
      controller: controller,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 184, 184, 184)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelText: hint,
          labelStyle:
              const TextStyle(color: Color.fromARGB(255, 223, 223, 223))),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );
}

Widget textTableView(String text) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 17),
    ),
  );
}

String calculateTimeDifference(DateTime storedDate) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(storedDate);

  if (difference.inDays > 0) {
    return "${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}";
  } else if (difference.inHours > 0) {
    return "${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}";
  } else {
    return "الآن";
  }
}

String formatCurrency(String text) {
  final formatter = NumberFormat("#,##0", "ar_IQD");
  return formatter.format(double.parse(text));
}

Widget buildDataTable2(List<DebtModel> debts, BuildContext context) {
  bool isBlackRow = false; // متغير لتبديل لون الصفوف

  return SizedBox(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ت', textAlign: TextAlign.center)),
          DataColumn(label: Text('المبلغ المسدد', textAlign: TextAlign.center)),
          DataColumn(
              label:
                  Text('تاريخ اخر تحديث\nd/m/y', textAlign: TextAlign.center)),
          DataColumn(label: Text('الملاحظة', textAlign: TextAlign.center)),
        ],
        rows: List.generate(debts.length, (i) {
          isBlackRow = !isBlackRow; // تبديل قيمة متغير اللون
// استخدام الدالة:

          String timeDifference = calculateTimeDifference(debts[i].debtDate);
          return DataRow(
            color: isBlackRow
                ? MaterialStateColor.resolveWith((_) => Colors.grey.shade300)
                : MaterialStateColor.resolveWith((_) => Colors.white),
            cells: [
              DataCell(Text((i + 1).toString(), textAlign: TextAlign.center)),
              DataCell(Text(formatCurrency(debts[i].debtAmount.toString()),
                  textAlign: TextAlign.center)),
              DataCell(Text(
                  '${debts[i].debtDate.day}/${debts[i].debtDate.month}/${debts[i].debtDate.year}\n منذ:$timeDifference',
                  textAlign: TextAlign.center)),
              DataCell(Text(
                debts[i].notes,
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.clip,
              )),
            ],
          );
        }),
      ),
    ),
  );
}
