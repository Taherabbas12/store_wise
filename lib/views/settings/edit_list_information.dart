import 'package:flutter/material.dart';

import '../widgets/widgers_more.dart';

class EditListInformation extends StatelessWidget {
  EditListInformation({super.key});
  TextEditingController nameMatjer = TextEditingController();

  Widget textTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textTitle('بيانات عامة :'),
            const SizedBox(height: 10),
            Wrap(children: [
              textFormField('اسم المتجر', nameMatjer),
              textFormField('اسم المالك', nameMatjer),
              textFormField('الايميل', nameMatjer),
            ]),
            const SizedBox(height: 30),
            textTitle('ارقام الهواتف :'),
            const SizedBox(height: 10),
            Wrap(children: [
              textFormField(' رقم الهاتف 1', nameMatjer),
              textFormField(' رقم الهاتف 2', nameMatjer),
              textFormField(' رقم الهاتف 3', nameMatjer),
              textFormField(' رقم الهاتف 4', nameMatjer),
            ]),
            const SizedBox(height: 30),
            textTitle('ملاحضة :'),
            const SizedBox(height: 10),
            textFormField('ملاحضة ', nameMatjer,
                w: MediaQuery.sizeOf(context).width * 0.6),
          ],
        ),
      ),
    );
  }
}
