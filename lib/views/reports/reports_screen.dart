// ignore_for_file: use_build_context_synchronously

import 'package:Al_Yaqeen/constants/colors_cos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/database_helper.dart';
import '../../model/basket_client_model.dart';
import '../../model/sequence_model.dart';
import '../show_menu/show_menu_screen.dart';
import '../widgets/widgers_more.dart';

class ReportScreen extends StatelessWidget {
  String timeSet(DateTime updateTimeDebts) {
    return '${updateTimeDebts.day}/${updateTimeDebts.month}/${updateTimeDebts.year}';
  }

  Set<SetDate> dateT(DatabaseProvider databaseProvider) {
    List<SetDate> date = [];

    Set<String> uniqueDates = {}; // هنا نستخدم Set لضمان عدم وجود تكرار

    for (int i = 0; i < databaseProvider.sequence.length; i++) {
      String currentDate =
          timeSet(databaseProvider.sequence[i].updateTimeDebts);

      if (uniqueDates.add(currentDate)) {
        // إذا نجحت عملية الإضافة، فهذا يعني أنه لم يكن هناك تكرار، لذا نقوم بإضافة SetDate
        date.add(
            SetDate(currentDate, databaseProvider.sequence[i].updateTimeDebts));
      }
    }

    return date.toSet();
  }

  int indexOf = 0;

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير'),
        actions: const [
          // وضع خيارات هتا لعرض جدول بياني
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: buildDataTable(
            databaseProvider.sequence, context, databaseProvider),
      ),
    );
  }

  int indexOfDay = -1;
  int totalPriceProfits = 0;

  Widget buildDataTable(List<SequenceModel> sequence, BuildContext context,
      DatabaseProvider databaseProvider) {
    List<SetDate> setDate = dateT(databaseProvider).toList().reversed.toList();
    totalPriceProfits = 0;
    List<SequenceModel> selectDay = indexOfDay == -1
        ? sequence.reversed.toList()
        : sequence
            .where((element) =>
                timeSet(element.updateTimeDebts) == setDate[indexOfDay].date)
            .toList()
            .reversed
            .toList();

    bool isBlackRow = false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Container(
          color: colorPrimary.withOpacity(0.8),
          padding: EdgeInsets.all(5),
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                        tileColor: const Color.fromARGB(255, 228, 171, 3),
                        title: const Text('تاريخ القائمة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                      ),
                      const Divider(),
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        onTap: () {
                          indexOfDay = -1;
                        },
                        hoverColor: colorHover.withOpacity(0.6),
                        tileColor: indexOfDay == index - 1
                            ? colorPrimary.withOpacity(0.9)
                            : colorPrimary.withOpacity(0.0),
                        title: const Text('الكل',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                      ),
                    ],
                  ),
                );
              } else {
                DateTime storedDate = setDate[index - 1].dateTime;
                String timeDifference = calculateTimeDifference(storedDate);

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    hoverColor: colorHover.withOpacity(0.6),
                    tileColor: indexOfDay == index - 1
                        ? colorPrimary.withOpacity(0.9)
                        : colorPrimary.withOpacity(0.0),
                    title: Text(timeDifference,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                    onTap: () {
                      indexOfDay = index - 1;
                    },
                  ),
                );
              }
            },
            itemCount: setDate.length + 1,
          ),
        )),
        Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: DataTable(
                              columnSpacing: 0.1,
                              dataRowMaxHeight: 60,
                              headingRowHeight: 60,
                              columns: const [
                                DataColumn(
                                    label:
                                        Text('ت', textAlign: TextAlign.center)),
                                DataColumn(
                                    label: Text('حضرة السيد',
                                        textAlign: TextAlign.center)),
                                DataColumn(
                                  label: Text('مبلغ القائمة',
                                      textAlign: TextAlign.center),
                                ),
                                DataColumn(
                                  label: Text('الارباح',
                                      textAlign: TextAlign.center),
                                ),
                                DataColumn(
                                    label: Text('التاريخ\nd/m/y',
                                        textAlign: TextAlign.center)),
                              ],
                              rows: List.generate(selectDay.length, (i) {
                                isBlackRow =
                                    !isBlackRow; // تبديل قيمة متغير اللون
                                // استخدام الدالة:
                                totalPriceProfits += selectDay[i].profits;
                                String select = "";
                                try {
                                  select = databaseProvider.accounts
                                      .where((element) =>
                                          element.id == selectDay[i].clientId)
                                      .first
                                      .name;
                                } catch (e) {
                                  select = "الحساب محذوف او بيع مباشر";
                                }
                                DateTime storedDate =
                                    selectDay[i].updateTimeDebts;
                                String timeDifference =
                                    calculateTimeDifference(storedDate);
                                return DataRow(
                                    onLongPress: () async {
                                      List<BasketClientModel> basketClient =
                                          await databaseProvider
                                              .getBasketClientItems(
                                        selectDay[i].id ?? 0,
                                      );

                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                        'حضرة السيد : $select'),
                                                    Text(
                                                      'مجموع القائمة : ${formatCurrency(selectDay[i].totalPrice.toString())}',
                                                    ),
                                                    Text(
                                                      'مجموع الارباح : ${formatCurrency(selectDay[i].profits.toString())}',
                                                    ),
                                                  ],
                                                ),
                                                content: SizedBox(
                                                  height:
                                                      MediaQuery.sizeOf(context)
                                                              .height *
                                                          0.8,
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.8,
                                                  child: ShowMenuScreen(
                                                      basketClient:
                                                          basketClient),
                                                ));
                                          });
                                      print(basketClient);
                                    },
                                    color: isBlackRow
                                        ? MaterialStateColor.resolveWith(
                                            (_) => Colors.grey.shade300)
                                        : MaterialStateColor.resolveWith(
                                            (_) => Colors.white),
                                    cells: [
                                      DataCell(Text((i + 1).toString(),
                                          textAlign: TextAlign.center)),
                                      DataCell(Text(select,
                                          textAlign: TextAlign.center)),
                                      DataCell(
                                        Text(
                                          formatCurrency(selectDay[i]
                                              .totalPrice
                                              .toString()),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 98, 11, 180)),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          formatCurrency(
                                              selectDay[i].profits.toString()),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 11, 180, 53)),
                                        ),
                                      ),
                                      DataCell(Text(
                                          '${selectDay[i].updateTimeDebts.day}/${selectDay[i].updateTimeDebts.month}/${selectDay[i].updateTimeDebts.year}\n منذ:$timeDifference',
                                          textAlign: TextAlign.center)),
                                    ]);
                              })),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: colorPrimary,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    'مجموع الارباح : ${formatCurrency(totalPriceProfits.toString())}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ))
      ],
    );
  }
}

class SetDate {
  String date;
  DateTime dateTime;
  SetDate(this.date, this.dateTime);
}
// SizedBox(
//       child: ListView.builder(
//         itemBuilder: (context, index) {
//           List<SequenceModel> filter = sequence
//               .where((element) =>
//                   setDate[index] ==
//                   '${element.updateTimeDebts.day}/${element.updateTimeDebts.month}/${element.updateTimeDebts.year}')
//               .toList();

//           return ExpansionTile(
//               title: Text(
//                 setDate[index],
//               ),
//               children: List.generate(
//                   filter.length,
//                   (index) => DataTable(
//                       columnSpacing: MediaQuery.sizeOf(context).width * 0.08,
//                       dataRowMaxHeight: 60,
//                       headingRowHeight: 60,
//                       columns: const [
//                         DataColumn(
//                             label: Text('ت', textAlign: TextAlign.center)),
//                         DataColumn(
//                             label: Text('حضرة السيد',
//                                 textAlign: TextAlign.center)),
//                         DataColumn(
//                             label: Text('الدين', textAlign: TextAlign.center),
//                             tooltip: 'اضغط على الحقل للتسديد الدين'),
//                         DataColumn(
//                             label: Text('التاريخ\nd/m/y',
//                                 textAlign: TextAlign.center)),
//                         DataColumn(label: Text('')),
//                       ],
//                       rows: List.generate(sequence.length, (i) {
//                         isBlackRow = !isBlackRow; // تبديل قيمة متغير اللون
// // استخدام الدالة:
//                         DateTime storedDate = sequence[i].updateTimeDebts;
//                         String timeDifference =
//                             calculateTimeDifference(storedDate);
//                         return DataRow(
//                             color: isBlackRow
//                                 ? MaterialStateColor.resolveWith(
//                                     (_) => Colors.grey.shade300)
//                                 : MaterialStateColor.resolveWith(
//                                     (_) => Colors.white),
//                             cells: [
//                               DataCell(Text((i + 1).toString(),
//                                   textAlign: TextAlign.center)),
//                               DataCell(Text(
//                                   databaseProvider.accounts
//                                       .where((element) =>
//                                           element.id == sequence[i].clientId)
//                                       .first
//                                       .name,
//                                   textAlign: TextAlign.center)),
//                               DataCell(CupertinoButton(
//                                 onPressed: () {},
//                                 child: Text(
//                                     formatCurrency(
//                                         sequence[i].totalPrice.toString()),
//                                     textAlign: TextAlign.center),
//                               )),
//                               DataCell(Text(
//                                   '${sequence[i].updateTimeDebts.day}/${sequence[i].updateTimeDebts.month}/${sequence[i].updateTimeDebts.year}\n منذ:$timeDifference',
//                                   textAlign: TextAlign.center)),
//                               DataCell(Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   InkWell(
//                                     onTap: () {},
//                                     child: const Icon(Icons.info,
//                                         color: Colors.blue),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   InkWell(
//                                     onTap: () {},
//                                     child: const Icon(Icons.update,
//                                         color: Colors.green),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   InkWell(
//                                     onTap: () {},
//                                     child: const Icon(Icons.delete,
//                                         color: Colors.red),
//                                   ),
//                                 ],
//                               ))
//                             ]);
//                       }))));
//         },
//         itemCount: setDate.length,
//       ),
//     );
