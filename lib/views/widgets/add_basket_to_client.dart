// ignore_for_file: use_build_context_synchronously

import '/constants/colors_cos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/database_helper.dart';
import '../../model/account_model.dart';
import '../../model/print_data_pdf_model.dart';
import '../../model/sequence_model.dart';

class SearchActionSheet extends StatefulWidget {
  int idBasket;
  int totalPrice;
  int profits;
  int discountPrice;
  List<bool> x;
  PrintDataPdfModel printDataPdf;
  SearchActionSheet({
    super.key,
    required this.idBasket,
    required this.totalPrice,
    required this.printDataPdf,
    required this.x,
    required this.discountPrice,
    required this.profits,
  });
  @override
  _SearchActionSheetState createState() => _SearchActionSheetState();
}

class _SearchActionSheetState extends State<SearchActionSheet> {
  TextEditingController searchController = TextEditingController();
  List<AccountModel> filteredAccounts = [];

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    filteredAccounts = filteredAccounts = databaseProvider.accounts
        .where((element) => element.name.contains(searchController.text.trim()))
        .toList();
    ;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: CupertinoActionSheet(
        cancelButton: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
            color: Colors.red),
        title: const Text('الى حضرة ..'),
        message: SizedBox(
          width: 400,
          height: 50,
          child: CupertinoSearchTextField(
            backgroundColor: colorPrimary,
            controller: searchController,
            placeholder: 'بحث عن حساب',
            style: const TextStyle(color: Colors.white),
            itemColor: const Color.fromARGB(255, 48, 48, 48),
            placeholderStyle: const TextStyle(color: Colors.white60),
            onChanged: (newText) {
              setState(() {});
            },
          ),
        ),
        actions: List.generate(
          filteredAccounts.length,
          (i) => CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                await databaseProvider.moveBasketDataToClient(
                    adminId: 1,
                    clientId: filteredAccounts[i].id,
                    idBasket: widget.idBasket,
                    sequenceModel: SequenceModel(
                      clientId: filteredAccounts[i].id,
                      clientName: filteredAccounts[i].name,
                      totalPrice: widget.totalPrice,
                      profits: widget.profits,
                      updateTimeDebts: DateTime.now(),
                      discountPrice: widget.discountPrice,
                      updateTimeDebtsUpdate: '',
                      status: '',
                    ));
                widget.printDataPdf.nameSalary = filteredAccounts[i].name;
                widget.printDataPdf.numberOFInvoice =
                    widget.idBasket.toString();
                widget.printDataPdf.phoneSalary =
                    filteredAccounts[i].phoneNumber;
                widget.x[0] = true;
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'حضرة السيد : ${filteredAccounts[i].name} ',
                    style: const TextStyle(
                        color: Colors.black, fontSize: 17, height: 0),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '  اسم المتجر : ${filteredAccounts[i].storeName} ',
                    style: const TextStyle(
                        color: Colors.black, fontSize: 17, height: 0),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'الدين : ${filteredAccounts[i].debts}',
                    style: const TextStyle(
                        color: Colors.black, fontSize: 17, height: 0),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

Future<void> addBasketToClient(
    BuildContext context,
    int idBasket,
    int totalPrice,
    int discountPrice,
    int profits,
    PrintDataPdfModel printDataPdf,
    List<bool> x) async {
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      return SearchActionSheet(
          idBasket: idBasket,
          totalPrice: totalPrice,
          printDataPdf: printDataPdf,
          discountPrice: discountPrice,
          profits: profits,
          x: x);
    },
  );
}
