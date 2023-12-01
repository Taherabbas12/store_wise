// ignore_for_file: must_be_immutable

import '/model/account_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../database/database_helper.dart';
import '../widgets/widgers_more.dart';

class AddAccount extends StatefulWidget {
  AddAccount({super.key});

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  TextEditingController name = TextEditingController();

  TextEditingController phone = TextEditingController();

  TextEditingController storeName = TextEditingController();

  TextEditingController debts = TextEditingController(text: '0');

  late int idLast;

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    idLast = databaseProvider.accounts.isNotEmpty
        ? databaseProvider.accounts.lastOrNull!.id
        : 1;
    return Scaffold(
        appBar: AppBar(title: const Text('اضافة حساب')),
        body: Center(
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      textFormField('اسم البائع', name),
                      textFormFieldNumber('رقم الهاتف', phone),
                      textFormField('اسم المتجر', storeName),
                      textFormFieldNumber('الدين', debts),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 50),
                        shadowColor: Colors.black,
                        elevation: 7,
                        shape: const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      onPressed: () async {
                        if (name.text.isNotEmpty &&
                            phone.text.isNotEmpty &&
                            storeName.text.isNotEmpty &&
                            debts.text.isNotEmpty) {
                          idLast++;
                          final newProduct = AccountModel(
                              id: idLast,
                              name: name.text.trim(),
                              debts: int.parse(debts.text.trim()),
                              phoneNumber: phone.text.trim(),
                              storeName: storeName.text.trim(),
                              updateTimeDebts: DateTime.now());
                          await databaseProvider.insertAccount(newProduct);
                          setState(() {
                            name.clear();
                            phone.clear();
                            storeName.clear();
                            debts.text = '0';
                          });
                        } else {
                          Toast.show("يرجى ملأ كل الحقول اولا",
                              backgroundColor: Colors.red,
                              backgroundRadius: 10,
                              duration: Toast.lengthLong,
                              gravity: Toast.bottom);
                        }
                      },
                      child: const Text(
                        'اضافة حساب',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
