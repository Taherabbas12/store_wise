// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../constants/colors_cos.dart';
import '../database/database_helper.dart';

class DashBord extends StatelessWidget {
  DashBord({super.key});
  List<DataView> views = [
    DataView(name: "اضافة منتجات وعرضها", url: "ViewItems"),
    DataView(name: "بيع", url: "Sale"),
    DataView(name: "اضافة حساب", url: "AddAccount"),
    DataView(name: "الديون والحسابات", url: "Accounnts"),
    DataView(name: "تقارير", url: "ReportScreen"),
  ];

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    ToastContext().init(context);

    // تهيئة الداتابيس
    databaseProvider.initializeDatabase();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(
              views.length,
              (index) => InkWell(
                onTap: () {
                  Navigator.pushNamed(context, views[index].url);
                },
                hoverColor: colorHover,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(10),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              views[index].name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DataView {
  String name;
  String url;
  DataView({required this.name, required this.url});
}
