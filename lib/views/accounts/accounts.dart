// ignore_for_file: use_build_context_synchronously, must_be_immutable

import '/constants/colors_cos.dart';
import '/model/account_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../database/database_helper.dart';
import '../../model/debt_model.dart';
import '../widgets/widgers_more.dart';

class Accounnts extends StatelessWidget {
  Accounnts({super.key});
  TextEditingController searchController = TextEditingController();
  TextEditingController debtsNew = TextEditingController();
  TextEditingController notedebtsNew = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AccountModel debtslTemp = AccountModel(
      id: 0,
      name: 'taher',
      storeName: 'taher',
      phoneNumber: '',
      debts: 0,
      updateTimeDebts: DateTime.now());

  String timeDifference2 = '';
  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: colorPrimary),
                    height: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                            'الطلب الحالي: ${formatCurrency(debtslTemp.debts.toString())}',
                            style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 40),
                        Text('حضرة السيد:        ${debtslTemp.name}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white)),
                        Text('اسم المتجر:           ${debtslTemp.storeName}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white)),
                        Text(
                            'تاريخ اخر تحديث :  ${debtslTemp.updateTimeDebts.day}/${debtslTemp.updateTimeDebts.month}/${debtslTemp.updateTimeDebts.year}\nمنذ:                    $timeDifference2',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white))
                      ],
                    )),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      textFormFieldNumber('مقدار التسديد', debtsNew, w: 170),
                      textFormField('ملاحضة', notedebtsNew, w: 200),
                      ElevatedButton(
                        onPressed: () {
                          if (debtsNew.text.isNotEmpty &&
                              notedebtsNew.text.isNotEmpty) {
                            if (int.parse(debtsNew.text) <= debtslTemp.debts) {
                              debtslTemp.debts -=
                                  int.parse(debtsNew.text.trim());
                              debtslTemp.updateTimeDebts = DateTime.now();
                              databaseProvider.updateAccount(debtslTemp);
                              timeDifference2 = calculateTimeDifference(
                                  debtslTemp.updateTimeDebts);

                              DebtModel newDebts = DebtModel(
                                  clientId: debtslTemp.id,
                                  debtAmount:
                                      double.parse(debtsNew.text.trim()),
                                  debtDate: DateTime.now(),
                                  notes: notedebtsNew.text);
                              databaseProvider.insertDebt(
                                  newDebts, debtslTemp.id);
                              debtsNew.text = '';
                              notedebtsNew.text = '';
                            } else {
                              Toast.show(
                                  "القيمة التي يتم سدادها اكبر من القيمة المطلوبة",
                                  backgroundColor: Colors.red,
                                  backgroundRadius: 10,
                                  duration: Toast.lengthLong,
                                  gravity: Toast.bottom);
                            }
                          } else {
                            Toast.show("يرجى ملأ كل الحقول اولا",
                                backgroundColor: Colors.red,
                                backgroundRadius: 10,
                                duration: Toast.lengthLong,
                                gravity: Toast.bottom);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            fixedSize: const Size(100, 50),
                            backgroundColor: colorPrimary,
                            elevation: 8),
                        child: const Text(
                          'تسديد',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                      child: buildDataTable2(databaseProvider.debts, context)),
                )
              ],
            )),
        appBar: AppBar(
          title: const Text('الديون والحسابات'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 400,
                  height: 50,
                  child: CupertinoSearchTextField(
                    controller: searchController,
                    placeholder: 'بحث عن حساب',
                    style: const TextStyle(color: Colors.white),
                    itemColor: Colors.white,
                    placeholderStyle: const TextStyle(color: Colors.white60),
                  ),
                )
              ],
            )
          ],
        ),
        body: buildDataTable(
          databaseProvider.accounts
              .where((element) =>
                  element.name.contains(searchController.text.trim()))
              .toList(),
          context,
          databaseProvider,
        ));
  }

  Widget buildDataTable(List<AccountModel> account, BuildContext context,
      DatabaseProvider databaseProvider) {
    bool isBlackRow = false; // متغير لتبديل لون الصفوف

    return SingleChildScrollView(
      child: Row(
        children: [
          Expanded(
            child: DataTable(
              dataRowMaxHeight: 60,
              headingRowHeight: 60,
              columns: const [
                DataColumn(label: Text('ت', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('حضرة السيد', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('اسم المتجر', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('رقم الهاتف', textAlign: TextAlign.center)),
                DataColumn(
                    label: Text('الدين', textAlign: TextAlign.center),
                    tooltip: 'اضغط على الحقل للتسديد الدين'),
                DataColumn(
                    label: Text('تاريخ اخر تحديث\nd/m/y',
                        textAlign: TextAlign.center)),
                DataColumn(label: Text('')),
              ],
              rows: List.generate(account.length, (i) {
                isBlackRow = !isBlackRow; // تبديل قيمة متغير اللون
                // استخدام الدالة:
                DateTime storedDate = account[i].updateTimeDebts;
                String timeDifference = calculateTimeDifference(storedDate);
                return DataRow(
                  color: isBlackRow
                      ? MaterialStateColor.resolveWith(
                          (_) => Colors.grey.shade300)
                      : MaterialStateColor.resolveWith((_) => Colors.white),
                  cells: [
                    DataCell(
                        Text((i + 1).toString(), textAlign: TextAlign.center)),
                    DataCell(
                        Text(account[i].name, textAlign: TextAlign.center)),
                    DataCell(Text(account[i].storeName.toString(),
                        textAlign: TextAlign.center)),
                    DataCell(Text(account[i].phoneNumber.toString(),
                        textAlign: TextAlign.center)),
                    DataCell(CupertinoButton(
                      onPressed: () {
                        DateTime storedDate = account[i].updateTimeDebts;
                        timeDifference2 = calculateTimeDifference(storedDate);
                        debtslTemp = account[i];
                        databaseProvider.getDebtsByClientId(account[i].id);
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: Text(formatCurrency(account[i].debts.toString()),
                          textAlign: TextAlign.center),
                    )),
                    DataCell(Text(
                        '${account[i].updateTimeDebts.day}/${account[i].updateTimeDebts.month}/${account[i].updateTimeDebts.year}\n منذ:$timeDifference',
                        textAlign: TextAlign.center)),
                    DataCell(Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            showRowDetailsDialog(
                                context, account[i], timeDifference);
                          },
                          child: const Icon(Icons.info, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            editProduct(context, account[i]);
                          },
                          child: const Icon(Icons.update, color: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            deleteProduct(context, account[i]);
                          },
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    )),
                  ],
                );
              }),
            ),
          ),
        ],
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

  void showRowDetailsDialog(
      BuildContext context, AccountModel account, String d) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تفاصيل الحساب'),
          content: SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الاسم : ${account.name}',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromARGB(255, 22, 87, 80))),
                Text('اسم المتجر : ${account.storeName}',
                    style: const TextStyle(fontSize: 18)),
                Text('رقم الهاتف:\t ${account.phoneNumber}',
                    style: const TextStyle(fontSize: 18)),
                Text('الدين:\t ${account.debts}',
                    style: const TextStyle(fontSize: 18)),
                Text(
                    'تاريخ اخر تحديث :  ${account.updateTimeDebts.day}/${account.updateTimeDebts.month}/${account.updateTimeDebts.year}\n منذ:$d',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void editProduct(BuildContext context, AccountModel account) {
    final TextEditingController nameController =
        TextEditingController(text: account.name);
    final TextEditingController phoneNumberController =
        TextEditingController(text: account.phoneNumber.toString());
    final TextEditingController storeNameController =
        TextEditingController(text: account.storeName.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل الحساب'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  textFormField('الاسم', nameController),
                  textFormFieldNumber('رقم الهاتف', phoneNumberController),
                  textFormField('اسم المتجر', storeNameController),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final editedAccount = AccountModel(
                    id: account.id,
                    name: nameController.text.trim(),
                    debts: account.debts,
                    storeName: storeNameController.text.trim(),
                    phoneNumber: phoneNumberController.text.trim(),
                    updateTimeDebts: account.updateTimeDebts);
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .updateAccount(editedAccount);

                Navigator.of(context).pop();
              },
              child: const Text('حفظ التعديل'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  void deleteProduct(BuildContext context, AccountModel account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف المنتج'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا المنتج؟'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .deleteAccount(account.id);

                Navigator.of(context).pop();
              },
              child: const Text('نعم'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لا'),
            ),
          ],
        );
      },
    );
  }
}
