// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/colors_cos.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../pdf/create_invoice_pdf.dart';

class ActivitApp extends StatefulWidget {
  ActivitApp({super.key});

  @override
  State<ActivitApp> createState() => _ActivitAppState();
}

class _ActivitAppState extends State<ActivitApp> {
  TextEditingController controller = TextEditingController(text: '');
  final _key = GlobalKey<FormState>();

  int stateCont = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفعيل التطبيق نشكركم لاختياركم منصتنا'),
        centerTitle: true,
      ),
      body: Center(
          child: Form(
        key: _key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textFormField(
              'رمز التفعيل',
              controller,
              errorText:
                  controller.text.isEmpty ? 'يرجى إدخال رمز التفعيل' : null,
            ),
            ElevatedButton(
              onPressed: () async {
                _key.currentState?.validate();
                if (stateCont < 5) {
                  if (controller.text.isNotEmpty &&
                      hashText(controller.text) == activatea) {
                    await GetStorage(localShard, localShardPath)
                        .write('token', 'ActiveIsNow2');
                    await GetStorage(localShard, localShardPath)
                        .write('tokenDate', DateTime.now().toString());
                    Navigator.pushReplacementNamed(context, '/');
                  } else {
                    //
                    controller.text = '';
                  }
                } else {
                  if (stateCont >= 10) Navigator.pop(context);
                }
                stateCont++;
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  fixedSize: const Size(300, 45),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
              child: const Text(
                'تحقق',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      )),
    );
  }

  String hashText(String text) {
    final hash = md5.convert(utf8.encode(text));
    return hash.toString();
  }

  Widget textFormField(String hint, TextEditingController controller,
      {double w = 400, String? errorText}) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: w,
      child: TextFormField(
        obscureText: true,
        validator: (value) {
          if (stateCont >= 5) {
            return 'لا يمكنك ادخال الرمز مره اخرى';
          }
          if (value == null || value.isEmpty) {
            return 'يرجى ادخال رمز التفعيل';
          }
          if (value != activatea) {
            return 'يرجى ادخال رمز التفعيل';
          }
          return null;
        },
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
}
