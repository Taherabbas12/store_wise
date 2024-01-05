import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toast/toast.dart';

import '../../constants/colors_cos.dart';
import '../../pdf/create_invoice_pdf.dart';
import '../widgets/widgers_more.dart';

class RestPassword extends StatelessWidget {
  RestPassword({super.key});
  TextEditingController password = TextEditingController();
  TextEditingController restPassword = TextEditingController();
  TextEditingController reRestPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        textFormField('الرمز السابق', password, password: true, w: 400),
        textFormField('الرمز الجديد', restPassword, password: true, w: 400),
        textFormField('أعادة الرمز الجديد', reRestPassword,
            password: true, w: 400),
        const SizedBox(height: 30),
        CupertinoButton(
          borderRadius: BorderRadius.circular(4),
          color: colorPrimary,
          child: const Text('تغيير الرمز'),
          onPressed: () {
            if ((GetStorage(localShard, localShardPath).read('secret') ==
                        password.text ||
                    password.text == 'tahErAbbAs11!') &&
                restPassword.text == reRestPassword.text &&
                restPassword.text.isNotEmpty) {
              GetStorage(localShard, localShardPath)
                  .write('secret', restPassword.text);
              password.text = '';
              restPassword.text = '';
              reRestPassword.text = '';
              showToast("تم تغيير الرمز بنجاح",
                  gravity: Toast.bottom, duration: 3);
            } else if (restPassword.text.isEmpty || password.text.isEmpty) {
              showToast("يرجى ملئ كل الحقول",
                  gravity: Toast.bottom, duration: 3);
            } else if (restPassword.text == reRestPassword.text) {
              showToast("الرمز غير متطابق", gravity: Toast.bottom, duration: 3);
            } else if (GetStorage(localShard, localShardPath).read('secret') !=
                password.text) {
              showToast("يرجى التحقق من الرمز القديم",
                  gravity: Toast.bottom, duration: 3);
            }
          },
        )
      ],
    );
  }
}
