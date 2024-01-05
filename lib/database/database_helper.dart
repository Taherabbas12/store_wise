import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

import '../model/account_model.dart';
import '../model/admin_model.dart';
import '../model/barcode_data.dart';
import '../model/basket_client_model.dart';
import '../model/basket_model.dart';
import '../model/debt_model.dart';
import '../model/event_model.dart';
import '../model/expenses_model.dart';
import '../model/item_model.dart';
import '../model/sequence_model.dart';

// يستحدم لجلب اي شيئ عن طريقة التاريخ والفترات

// Future<List<String>> getDatesBetween(
//     DateTime startDate, DateTime endDate) async {
//   final List<Map<String, dynamic>> result = await _database.query(
//     'dates',
//     where: 'date_value BETWEEN ? AND ?',
//     whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
//   );

//   return result.map((dateMap) => dateMap['date_value'] as String).toList();
// }

class DatabaseProvider extends ChangeNotifier {
  late Database _database;
  List<Product> _products = [];
  List<AccountModel> _accounts = [];
  List<DebtModel> debts = [];
  List<BasketModel> baskets = [];

  List<AdminsModel> admins = []; // قائمة الإداريين
  List<EventsModel> events = []; // قائمة الأحداث
  List<SequenceModel> sequence = []; // قائمة قوائم التقرير
  List<BarcodeData> barcodeProducts = []; // قائمة الباركودات
  List<BarcodeData> barcodeProductsAll = []; // قائمة الباركودات
  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'databaseT13.db'),
      onCreate: (db, version) {
        // الادارة
        db.execute(
          'CREATE TABLE admins(id INTEGER PRIMARY KEY AUTOINCREMENT,user_name TEXT,password TEXT,updateTimeDebts TEXT)',
        );

        // المنتجات
        db.execute(
            'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, nameProduct TEXT, quantity INTEGER, sellingPrice INTEGER, purchasingPrice INTEGER, description TEXT, note TEXT)');
        //  الحسابات
        db.execute(
          'CREATE TABLE accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, storeName TEXT, phoneNumber TEXT, debts INTEGER, updateTimeDebts TEXT)',
        );
        // الديون
        db.execute(
          'CREATE TABLE debts(id INTEGER PRIMARY KEY AUTOINCREMENT, clientId INTEGER, debtAmount REAL, debtDate TEXT,notes TEXT, FOREIGN KEY (clientId) REFERENCES accounts (id) ON DELETE CASCADE)',
        );
        // السله
        db.execute(
          'CREATE TABLE basket(id INTEGER PRIMARY KEY AUTOINCREMENT,id_basket INTEGER, nameProduct TEXT, requiredQuantity INTEGER, price INTEGER, totalPrice INTEGER, note TEXT,totalPriceProfits INTEGER)',
        );
        // قائمة المستخدم
        db.execute(
          'CREATE TABLE basket_client(id INTEGER PRIMARY KEY AUTOINCREMENT,sequenceid INTEGER, nameProduct TEXT, requiredQuantity INTEGER, price INTEGER, totalPrice INTEGER, note TEXT,totalPriceProfits INTEGER)',
        );

        // رقم القائمة
        db.execute(
          'CREATE TABLE sequence(id INTEGER PRIMARY KEY AUTOINCREMENT,clientName TEXT,clientId INTEGER,total_price INTEGER,updateTimeDebts TEXT,profits INTEGER,discountPrice INTEGER,updateTimeDebtsUpdate TEXT,status TEXT)',
        );
        // الاحداث
        // db.execute(
        //   'CREATE TABLE events(id INTEGER PRIMARY KEY AUTOINCREMENT,admin_id INTEGER,event_type TEXT,event_details,Time TEXT)',
        // );
        // الاحداث
        db.execute(
          'CREATE TABLE events(id INTEGER PRIMARY KEY AUTOINCREMENT, adminId INTEGER, eventType TEXT, eventDetails TEXT, time TEXT)',
        );
        // المصروفات
        db.execute(
          'CREATE TABLE Expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, nameExpenses Text, typeExpenses TEXT, eventDetails TEXT,priceExpenses INTEGER,time TEXT,timeFilter TEXT)',
        );
        // الباركود
        db.execute(
          'CREATE TABLE barcode_table(id INTEGER PRIMARY KEY AUTOINCREMENT, productsId INTEGER,barcode TEXT)',
        );

        print('on Create database');
      },
      version: 5,
    );

    _products = await getAllProducts();
    _accounts = await getAllAccounts();
    baskets = await getBasketItems();
    // basketClient = await getBasketClientItems();
    //admins = await getAllAdmins(); // جلب الإداريين
    //events = await getAllEvents(); // جلب الأحداث
    sequence = await getAllSequence(); // جلب الأحداث
    barcodeProductsAll = await getAllBarcodesNotID(); // جلب الأحداث

    notifyListeners();
  }

// BarcodeData

  Future<void> insertBarcode(BarcodeData barcodeData) async {
    await _database.insert(
      'barcode_table',
      barcodeData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await getAllBarcodes(barcodeData.productsId);
    notifyListeners();
  }

  Future<void> getAllBarcodes(int productsId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'barcode_table',
      where: 'productsId = ?',
      whereArgs: [productsId],
    );

    barcodeProducts = List.generate(maps.length, (i) {
      return BarcodeData(
        id: maps[i]['id'],
        productsId: maps[i]['productsId'],
        barcode: maps[i]['barcode'],
      );
    });
    notifyListeners();
  }

  Future<List<BarcodeData>> getAllBarcodesNotID() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'barcode_table',
    );

    return List.generate(maps.length, (i) {
      return BarcodeData(
        id: maps[i]['id'],
        productsId: maps[i]['productsId'],
        barcode: maps[i]['barcode'],
      );
    });
  }

  Future<void> deleteBarcode(BarcodeData barcodeData) async {
    await _database.delete(
      'barcode_table',
      where: 'id = ?',
      whereArgs: [barcodeData.id],
    );
    getAllBarcodes(barcodeData.productsId);
    notifyListeners();
  }

  Future<void> insertProduct(Product product) async {
    await _database.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    _products = await getAllProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _database.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );

    _products = await getAllProducts();
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    await _database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    _products = await getAllProducts();
    notifyListeners();
  }

  Future<List<Product>> getAllProducts() async {
    final List<Map<String, dynamic>> maps = await _database.query('products');

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        nameProduct: maps[i]['nameProduct'],
        quantity: maps[i]['quantity'],
        sellingPrice: maps[i]['sellingPrice'],
        purchasingPrice: maps[i]['purchasingPrice'],
        description: maps[i]['description'],
        note: maps[i]['note'],
      );
    });
  }

  // للحسابات

  Future<void> insertAccount(AccountModel account) async {
    int id = await _database.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    Toast.show("تم اضافة الحساب $id",
        backgroundColor: const Color.fromARGB(255, 6, 238, 118),
        backgroundRadius: 10,
        duration: Toast.lengthLong,
        gravity: Toast.bottom);
    _accounts = await getAllAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(AccountModel account) async {
    await _database.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );

    _accounts = await getAllAccounts();
    notifyListeners();
  }

  Future<void> deleteAccount(int id) async {
    await _database.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );

    _accounts = await getAllAccounts();
    notifyListeners();
  }

  Future<List<AccountModel>> getAllAccounts() async {
    final List<Map<String, dynamic>> maps = await _database.query('accounts');

    return List.generate(maps.length, (i) {
      return AccountModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        storeName: maps[i]['storeName'],
        phoneNumber: maps[i]['phoneNumber'],
        debts: maps[i]['debts'],
        updateTimeDebts: DateTime.parse(maps[i]['updateTimeDebts']),
      );
    });
  }

  Future<List<SequenceModel>> getAllSequence() async {
    final List<Map<String, dynamic>> maps = await _database.query('sequence');

    return List.generate(maps.length, (i) {
      return SequenceModel.fromMap(maps[i]);
    });
  }

  List<Product> get products => _products;
  List<AccountModel> get accounts => _accounts;

//______الديون

  Future<void> insertDebt(DebtModel debt, int idClient) async {
    await _database.insert(
      'debts',
      debt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await getDebtsByClientId(idClient);
    notifyListeners();
  }

  // Future<List<DebtModel>> getAllDebts() async {
  //   final List<Map<String, dynamic>> maps = await _database.query('debts');
  //   _debts = List.generate(maps.length, (i) {
  //     return DebtModel.fromMap(maps[i]);
  //   });
  // }

  Future<void> getDebtsByClientId(int clientId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'debts',
      where: 'clientId = ?',
      whereArgs: [clientId],
    );
    debts = List.generate(maps.length, (i) {
      return DebtModel.fromMap(maps[i]);
    });
  }

//-------------------- السلة

  Future<List<BasketModel>> getBasketItems() async {
    final List<Map<String, dynamic>> maps = await _database.query('basket');

    return List.generate(maps.length, (i) {
      return BasketModel.fromMap(maps[i]);
    });
  }

  Future<List<BasketClientModel>> getBasketClientItems(int sequenceid) async {
    final List<Map<String, dynamic>> maps = await _database.query(
        'basket_client',
        where: 'sequenceid = ?',
        whereArgs: [sequenceid]);

    return List.generate(maps.length, (i) {
      return BasketClientModel.fromMap2(maps[i]);
    });
  }

// لإضافة عنصر إلى السلة
  Future<void> insertBasketItem(BasketModel basketItem) async {
    // 'CREATE TABLE basket(id INTEGER PRIMARY KEY AUTOINCREMENT,id_basket INTEGER, nameProduct TEXT, requiredQuantity INTEGER, price INTEGER, totalPrice INTEGER, note TEXT)',

    await _database.insert(
      'basket',
      basketItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    // إعادة تحميل العناصر في السلة بعد الإضافة
    await getBasketItems();
    notifyListeners();
  }

// لتحديث عنصر في السلة
  Future<void> updateBasketItem(BasketModel updatedItem) async {
    await _database.update(
      'basket',
      updatedItem.toMap(),
      where: 'id = ?',
      whereArgs: [updatedItem.id],
    );

    // إعادة تحميل العناصر في السلة بعد التحديث
    await getBasketItems();

    notifyListeners();
  }

// لحذف عنصر من السلة
  Future<void> deleteBasketItem(int id) async {
    await _database.delete(
      'basket',
      where: 'id = ?',
      whereArgs: [id],
    );

    // إعادة تحميل العناصر في السلة بعد الحذف
    await getBasketItems();

    notifyListeners();
  }

  Future<void> deleteAllBasketItems(int idBasket) async {
    await _database
        .delete('basket', where: 'id_basket = ?', whereArgs: [idBasket]);

    // إعادة تحميل العناصر في السلة بعد الحذف
    await getBasketItems();

    notifyListeners();
  }
  // الإداريين

  Future<void> insertAdmin(AdminsModel admin) async {
    await _database.insert(
      'admins',
      admin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    admins = await getAllAdmins();
    notifyListeners();
  }

  Future<void> updateAdmin(AdminsModel updatedAdmin) async {
    await _database.update(
      'admins',
      updatedAdmin.toMap(),
      where: 'id = ?',
      whereArgs: [updatedAdmin.id],
    );

    admins = await getAllAdmins();
    notifyListeners();
  }

  Future<void> deleteAdmin(int id) async {
    await _database.delete(
      'admins',
      where: 'id = ?',
      whereArgs: [id],
    );

    admins = await getAllAdmins();
    notifyListeners();
  }

  Future<List<AdminsModel>> getAllAdmins() async {
    final List<Map<String, dynamic>> maps = await _database.query('admins');

    return List.generate(maps.length, (i) {
      return AdminsModel.fromMap(maps[i]);
    });
  }

  // الأحداث

  Future<void> insertEvent(EventsModel event) async {
    await _database.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    events = await getAllEvents();
    notifyListeners();
  }

  Future<void> updateEvent(EventsModel updatedEvent) async {
    await _database.update(
      'events',
      updatedEvent.toMap(),
      where: 'id = ?',
      whereArgs: [updatedEvent.id],
    );

    events = await getAllEvents();
    notifyListeners();
  }

  Future<void> deleteEvent(int id) async {
    await _database.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    events = await getAllEvents();
    notifyListeners();
  }

  Future<List<EventsModel>> getAllEvents() async {
    final List<Map<String, dynamic>> maps = await _database.query('events');

    return List.generate(maps.length, (i) {
      return EventsModel.fromMap(maps[i]);
    });
  }
//________________________ الشراء الى

  Future<void> moveBasketDataToClient({
    required int idBasket,
    required int clientId,
    required SequenceModel sequenceModel,
    required int adminId,
  }) async {
    int idSeq = sequence.length + 1;
    for (BasketModel item
        in baskets.where((element) => element.idBasket == idBasket).toList()) {
      // إنشاء عنصر جديد في جدول basket_client
      final BasketClientModel basketClientItem = BasketClientModel(
          sequenceId: idSeq,
          nameProduct: item.nameProduct,
          requiredQuantity: item.requiredQuantity,
          price: item.price,
          totalPrice: item.totalPrice,
          note: item.note,
          totalPriceProfits: item.totalPriceProfits);

      // إضافة العنصر إلى جدول basket_client
      await insertBasketClientItem(basketClientItem);

      // حذف العنصر من جدول basket
      // await _database.delete(
      //   'basket',
      //   where: 'id_basket = ?',
      //   whereArgs: [idBasket],
      // );
    }

    try {
      AccountModel updateAccounts =
          accounts.where((element) => element.id == clientId).first;

      updateAccounts.debts += sequenceModel.totalPrice;
      updateAccounts.updateTimeDebts = DateTime.now();
      updateAccount(updateAccounts);
    } catch (e) {}
    // deleteAllBasketItems(idBasket);
    await insertEvent(EventsModel(
        adminId: adminId,
        eventType: 'سند بيع',
        eventDetails:
            '  : $idSeq\nمجموع القائمة : ${sequenceModel.totalPrice}رقم القائمة',
        time: DateTime.now().toString()));
    await insertSequence(sequenceModel);
  }

// الدوال التي تستخدمها في الكود الرئيسي

  Future<void> insertBasketClientItem(
      BasketClientModel basketClientItem) async {
    await _database.insert(
      'basket_client',
      basketClientItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    notifyListeners();
  }

  Future<void> insertSequence(SequenceModel sequence) async {
    await _database.insert(
      'sequence',
      sequence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    notifyListeners();
  }

  Future<void> insertBasketClientProduct(BasketClientModel product) async {
    await _database.insert(
      'basket_client',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<void> updateBasketClientProduct(BasketClientModel product) async {
    await _database.update(
      'basket_client',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    notifyListeners();
  }

  Future<void> deleteBasketClientProduct(int id) async {
    await _database.delete(
      'basket_client',
      where: 'sequenceid = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> updateSequence(SequenceModel sequence) async {
    await _database.update(
      'sequence',
      sequence.toMap(),
      where: 'id = ?',
      whereArgs: [sequence.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    notifyListeners();
  }

// المصروفات
  Future<void> insertExpense(ExpenseData expense) async {
    await _database.insert(
      'Expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<List<ExpenseData>> getAllExpenses() async {
    final List<Map<String, dynamic>> maps = await _database.query('Expenses');

    return List.generate(maps.length, (i) {
      return ExpenseData.fromMap(maps[i]);
    });
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}
