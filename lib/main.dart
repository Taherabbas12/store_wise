// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'constants/colors_cos.dart';
import 'database/database_helper.dart';
import 'views/accounts/accounts.dart';
import 'views/accounts/add_account.dart';
import 'views/admins/activit_app.dart';
import 'views/dashbord.dart';
import 'views/items/view_items.dart';
import 'views/reports/reports_screen.dart';
import 'views/sale/sale.dart';
import 'views/settings/setting_screen.dart';
import 'views/show_menu/show_menu_screen.dart';

String localShard = 'Microsoft';
String localShardPath = 'C:\\Users\\Public\\Documents';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI

    sqfliteFfiInit();

    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  GetStorage a = GetStorage(localShard, localShardPath);
  await GetStorage.init(
    localShard,
  );

  try {
    String a = GetStorage(localShard, localShardPath).read('token');
    // print('print $v');
  } catch (e) {
    GetStorage(localShard, localShardPath).write('token', 'not Active');
    // print(GetStorage('tokeeen3').read('token'));
  }

  runApp(
    ChangeNotifierProvider(
      lazy: true,
      create: (context) => DatabaseProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // scaffoldBackgroundColor: Colors.black,
          useMaterial3: true,
          appBarTheme: AppBarTheme(
              backgroundColor: colorPrimary,
              titleTextStyle:
                  const TextStyle(color: Colors.white, fontSize: 20),
              iconTheme: const IconThemeData(color: Colors.white))),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return child = Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      navigatorObservers: const [],
      routes: {
        '/': (context) => GetStorage(localShard).read('token') == 'ActiveIsNow'
            ? DashBord()
            : ActivitApp(),
        'ViewItems': (context) => const ViewItems(),
        'Sale': (context) => Sale(),
        'Accounnts': (context) => Accounnts(),
        'AddAccount': (context) => AddAccount(),
        'ReportScreen': (context) => ReportScreen(),
        'SettingScreen': (context) => SettingScreen(),
      },
    );
  }
}
