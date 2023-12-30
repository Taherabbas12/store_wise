import 'package:Al_Yaqeen/constants/colors_cos.dart';
import 'package:flutter/material.dart';

import 'add_admin.dart';
import 'favorites_app.dart';
import 'managment_admin.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<ListMenue> listMenue = [
    ListMenue('اضافة حساب', const AddAdmin()),
    ListMenue('ادارة الحسابات', const ManagmentAdmin()),
    ListMenue('تفضيلات التطبيق', const FavoritesApp()),
  ];

  int i = 0;

  // EditListInformation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاعدادات')),
      body: Row(children: [
        Expanded(
            child: Container(
          color: colorPrimary.withOpacity(0.7),
          child: ListView.builder(
            itemCount: listMenue.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  i = index;
                  setState(() {});
                },
                hoverColor: const Color.fromARGB(255, 196, 196, 196),
                title: Text(
                  listMenue[index].text,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        )),
        Expanded(
            flex: 4,
            child: Center(
              child: listMenue[i].view,
            )),
      ]),
    );
  }
}

class ListMenue {
  Widget view;
  String text;
  ListMenue(this.text, this.view);
}
