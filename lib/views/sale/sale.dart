// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, use_build_context_synchronously

import '../../model/sequence_model.dart';
import '/constants/colors_cos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../database/database_helper.dart';
import '../../model/basket_model.dart';
import '../../model/item_model.dart';
import '../../model/print_data_pdf_model.dart';
import '../../pdf/pdf_api.dart';
import '../widgets/add_basket_to_client.dart';
import '../widgets/widgers_more.dart';

class Sale extends StatelessWidget {
  late TextEditingController searchController = TextEditingController();
  late TextEditingController qrCodeController = TextEditingController();
  late TextEditingController discountController =
      TextEditingController(text: '0');
  late DatabaseProvider databaseProvider;
  int totalPrice = 0;
  int totalPriceBeforeDiscount = 0;
  int profits = 0;
  int idBasket = 1;
  PrintDataPdfModel printDataPdf = PrintDataPdfModel(
      nameSalary: 'بيع مباشر',
      numberOFInvoice: '0',
      phoneSalary: '',
      address: '');

  Sale({super.key});
  final FocusNode _searchFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('بيع'),
              const SizedBox(
                width: 50,
              ),
              for (int i = 1; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        idBasket = i;
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: idBasket != i
                              ? Colors.grey.shade500
                              : const Color.fromARGB(255, 248, 248, 248),
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(3))),
                      child: Text(
                        'القائمة رقم $i',
                        style: TextStyle(
                            color: idBasket != i ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500),
                      )),
                ),
            ],
          ),
        ),
        body: Row(
          children: [
            Container(
                width: 430,
                alignment: Alignment.topCenter,
                color: colorPrimary.withOpacity(0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(5),
                      width: 400,
                      height: 50,
                      child: CupertinoSearchTextField(
                        backgroundColor: colorPrimary.withOpacity(0.8),
                        controller: searchController,
                        placeholder: 'بحث عن منتج',
                        style: const TextStyle(color: Colors.white),
                        itemColor: Colors.white,
                        placeholderStyle:
                            const TextStyle(color: Colors.white60),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      width: 400,
                      height: 50,
                      child: CupertinoSearchTextField(
                        focusNode: _searchFieldFocusNode,
                        backgroundColor: colorPrimary.withOpacity(0.8),
                        controller: qrCodeController,
                        placeholder: 'امسح الباركود',
                        style: const TextStyle(color: Colors.white),
                        itemColor: Colors.white,
                        placeholderStyle:
                            const TextStyle(color: Colors.white60),
                        onSubmitted: (v) async {
                          try {
                            Product item = databaseProvider.products
                                .where((element) => element.description == v)
                                .first;

                            item.quantity--;
                            databaseProvider.updateProduct(item);
                            List<BasketModel> lsitT = databaseProvider.baskets
                                .where((element) =>
                                    element.nameProduct == item.nameProduct)
                                .toList();
                            if (lsitT.isEmpty) {
                              BasketModel newBasket = BasketModel(
                                  idBasket: idBasket,
                                  id: 0,
                                  nameProduct: item.nameProduct,
                                  note: '',
                                  price: item.sellingPrice,
                                  requiredQuantity: 1,
                                  totalPriceProfits: item.purchasingPrice,
                                  totalPrice: item.sellingPrice);
                              print('Size : ${lsitT.length}');
                              databaseProvider.insertBasketItem(newBasket);
                              print(item.nameProduct);
                            } else {
                              lsitT[0].requiredQuantity++;
                              lsitT[0].totalPrice += lsitT[0].price;
                              lsitT[0].totalPriceProfits +=
                                  item.purchasingPrice;

                              await Provider.of<DatabaseProvider>(context,
                                      listen: false)
                                  .updateBasketItem(lsitT[0]);
                              print("LSit IN Items >>>");
                            }
                          } catch (e) {
                            print("المنتج غير موجود");
                          }
                          qrCodeController.text = '';
                          _searchFieldFocusNode
                              .requestFocus(); // لتحديد التركيز على الحقل النصي
                          //         int totalPrice =
                          //     int.parse(price.text) * int.parse(quantity.text);
                          // int totalPriceProfits =
                          //     product.purchasingPrice * int.parse(quantity.text);
                          // BasketModel newBasket = BasketModel(
                          //     idBasket: idBasket,
                          //     id: 0,
                          //     nameProduct: product.nameProduct,
                          //     note: note.text,
                          //     price: int.parse(price.text),
                          //     requiredQuantity: int.parse(quantity.text),
                          //     totalPriceProfits: totalPriceProfits,
                          //     totalPrice: totalPrice);

                          // product.quantity -= int.parse(quantity.text);

                          // databaseProvider.updateProduct(product);

                          // databaseProvider.insertBasketItem(newBasket);

                          print(v);
                        },
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: buildDataTable(
                            databaseProvider.products
                                .where((element) => element.nameProduct
                                    .contains(searchController.text.trim()))
                                .toList(),
                            context),
                      ),
                    ),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // alignment: Alignment.topCenter,
                  // color: colorPrimary.withOpacity(0.2),
                  children: [
                    buildDataTableBasket(
                        databaseProvider.baskets
                            .where((element) => element.idBasket == idBasket)
                            .toList(),
                        context),
                    Container(
                      height: 60,
                      alignment: Alignment.center,
                      color: colorPrimary,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 850,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'المجموع    : ${formatCurrency(totalPrice.toString())}',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      'بعد الخصم: ${formatCurrency(totalPriceBeforeDiscount.toString())}',
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                                discountTextFormFieldNumber(
                                    'الخصم', discountController,
                                    w: 100),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(150, 45),
                                        shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    onPressed: () async {
                                      if (databaseProvider.baskets
                                          .where((element) =>
                                              element.idBasket == idBasket)
                                          .toList()
                                          .isNotEmpty) {
                                        printPDF(context);
                                      } else {
                                        Toast.show("ليس هناك منتجات تم اظافتها",
                                            backgroundColor: Colors.red,
                                            backgroundRadius: 10,
                                            duration: Toast.lengthLong,
                                            gravity: Toast.bottom);
                                      }
                                    },
                                    child: const Text(
                                      'بيع مباشر',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(150, 45),
                                        shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    onPressed: () async {
                                      if (databaseProvider.baskets
                                          .where((element) =>
                                              element.idBasket == idBasket)
                                          .toList()
                                          .isNotEmpty) {
                                        List<bool> x = [false];
                                        await addBasketToClient(
                                            context,
                                            idBasket,
                                            totalPriceBeforeDiscount,
                                            int.parse(discountController.text),
                                            profits,
                                            printDataPdf,
                                            x);
                                        if (x[0]) {
                                          await printPDF(context,
                                              isInInvoise: false);
                                          //deleteAllBaskets(context);

                                          await Provider.of<DatabaseProvider>(
                                                  context,
                                                  listen: false)
                                              .deleteAllBasketItems(idBasket);
                                        }
                                      } else {
                                        Toast.show("ليس هناك منتجات تم اظافتها",
                                            backgroundColor: Colors.red,
                                            backgroundRadius: 10,
                                            duration: Toast.lengthLong,
                                            gravity: Toast.bottom);
                                      }
                                    },
                                    child: const Text(
                                      'بيع الى..',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(150, 45),
                                        backgroundColor: Colors.red,
                                        shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    onPressed: () {
                                      deleteAllBaskets(
                                        context,
                                      );
                                      // databaseProvider.deleteAllBasketItems();
                                    },
                                    child: const Text(
                                      'حذف القائمة',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    )),
                              ]),
                        ),
                      ),
                    )
                  ],
                )),
          ],
        ));
  }

  void deleteAllBaskets(BuildContext context, {bool deleteItems = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف المنتج'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذه القائمة؟'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (deleteItems) {
                  for (BasketModel i
                      in Provider.of<DatabaseProvider>(context, listen: false)
                          .baskets) {
                    Product temp = Provider.of<DatabaseProvider>(context,
                            listen: false)
                        .products
                        .where(
                            (element) => element.nameProduct == i.nameProduct)
                        .first;
                    temp.quantity += i.requiredQuantity;
                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .updateProduct(temp);
                  }
                }
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .deleteAllBasketItems(idBasket);

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

  Widget buildDataTable(List<Product> products, BuildContext context) {
    bool isBlackRow = false; // متغير لتبديل لون الصفوف

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 400,
      child: SingleChildScrollView(
        // scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Expanded(
              child: DataTable(
                dataRowColor:
                    MaterialStateColor.resolveWith((_) => Colors.amber),
                columnSpacing: MediaQuery.sizeOf(context).width * 0.009,
                dataRowMaxHeight: 55,
                dataRowMinHeight: 55,
                columns: const [
                  DataColumn(
                      label: Text('ت', style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Center(
                          child: Text('اسم المنتج',
                              style: TextStyle(color: Colors.white)))),
                  DataColumn(
                      label: Text('الكمية المتوفرة | سعر البيع',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white))),
                ],
                rows: List.generate(products.length, (i) {
                  isBlackRow = !isBlackRow; // تبديل قيمة متغير اللون

                  return DataRow(
                    color: isBlackRow
                        ? MaterialStateColor.resolveWith((_) =>
                            products[i].quantity > 10
                                ? Colors.grey.shade300
                                : Colors.red.shade200)
                        : MaterialStateColor.resolveWith((_) =>
                            products[i].quantity > 10
                                ? Colors.white
                                : Colors.red.shade200),
                    cells: [
                      DataCell(Text((i + 1).toString())),
                      DataCell(Material(
                        color: Colors.transparent,
                        child: CupertinoButton(
                            onPressed: () {
                              if (databaseProvider.baskets
                                  .where((element) =>
                                      element.nameProduct ==
                                      products[i].nameProduct)
                                  .isEmpty) {
                                showRowDetailsDialog(context, products[i]);
                              } else {
                                Toast.show("تمت اضافة هذا المنتج بالفعل",
                                    backgroundColor: Colors.red,
                                    backgroundRadius: 10,
                                    duration: Toast.lengthLong,
                                    gravity: Toast.bottom);
                              }
                            },
                            child: Text(products[i].nameProduct)),
                      )),
                      DataCell(Center(
                        child: Text(
                            '${products[i].quantity} | ${formatCurrency(products[i].sellingPrice.toString())}',
                            textAlign: TextAlign.center),
                      )),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDataTableBasket(List<BasketModel> baskets, BuildContext context) {
    bool isBlackRow = false; // متغير لتبديل لون الصفوف
    totalPrice = 0;
    totalPriceBeforeDiscount = 0;
    profits = 0;
    return Expanded(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.778,
            child: Row(
              children: [
                Expanded(
                  child: DataTable(
                      dataRowMaxHeight: 55,
                      dataRowMinHeight: 55,
                      headingRowColor: MaterialStateColor.resolveWith(
                        (_) => colorPrimary.withOpacity(0.7),
                      ),
                      // columnSpacing: MediaQuery.sizeOf(context).width * 0.07,
                      columns: [
                        const DataColumn(
                            label: SizedBox(
                                child: Text('العمليات',
                                    style: TextStyle(color: Colors.white)))),
                        const DataColumn(
                            label: SizedBox(
                          child:
                              Text('ت', style: TextStyle(color: Colors.white)),
                        )),
                        DataColumn(
                            label: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.15,
                                child: const Text('اسم المنتج',
                                    style: TextStyle(color: Colors.white)))),
                        const DataColumn(
                            label: SizedBox(
                                width: 70,
                                child: Text('العدد',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white)))),
                        const DataColumn(
                            label: SizedBox(
                                width: 70,
                                child: Text('السعر',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white)))),
                        const DataColumn(
                            label: SizedBox(
                                width: 70,
                                child: Text('المجموع',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white)))),
                        const DataColumn(
                            label: SizedBox(
                                width: 100,
                                child: Text('ملاحظة',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white)))),
                      ],
                      rows: baskets.isNotEmpty
                          ? List.generate(baskets.length, (i) {
                              isBlackRow =
                                  !isBlackRow; // تبديل قيمة متغير اللون
                              totalPrice += baskets[i].totalPrice;
                              profits += baskets[i].totalPrice -
                                  baskets[i].totalPriceProfits;
                              if (discountController.text.isNotEmpty) {
                                totalPriceBeforeDiscount = totalPrice -
                                    int.parse(discountController.text);
                              } else {
                                totalPriceBeforeDiscount = totalPrice;
                              }

                              return DataRow(
                                color: isBlackRow
                                    ? MaterialStateColor.resolveWith(
                                        (_) => Colors.grey.shade300)
                                    : MaterialStateColor.resolveWith(
                                        (_) => Colors.white),
                                cells: [
                                  DataCell(Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showRowDetailsDialog2(
                                              context, baskets[i]);
                                        },
                                        child: const Icon(Icons.info,
                                            color: Colors.blue),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          editBasket(
                                              context,
                                              baskets[i],
                                              databaseProvider.products
                                                  .where((element) =>
                                                      element.nameProduct ==
                                                      baskets[i].nameProduct)
                                                  .first);
                                        },
                                        child: const Icon(Icons.update,
                                            color: Colors.green),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          deleteBasket(
                                              context,
                                              baskets[i],
                                              databaseProvider.products
                                                  .where((element) =>
                                                      element.nameProduct ==
                                                      baskets[i].nameProduct)
                                                  .first);
                                        },
                                        child: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  )),
                                  DataCell(Text((i + 1).toString())),
                                  DataCell(Text(baskets[i].nameProduct)),
                                  DataCell(Text(
                                      baskets[i].requiredQuantity.toString())),
                                  DataCell(Text(formatCurrency(
                                      baskets[i].price.toString()))),
                                  DataCell(Text(formatCurrency(
                                      baskets[i].totalPrice.toString()))),
                                  DataCell(Text(baskets[i].note)),
                                ],
                              );
                            })
                          : [
                              const DataRow(
                                cells: [
                                  DataCell(Text('')),
                                  DataCell(Text('0')),
                                  DataCell(Text('لم يتم اضافة أي منتجات')),
                                  DataCell(Text('0')),
                                  DataCell(Text('0000')),
                                  DataCell(Text('0000')),
                                  DataCell(Text('لايوجد')),
                                ],
                              )
                            ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showRowDetailsDialog(BuildContext context, Product product) {
    TextEditingController price =
        TextEditingController(text: product.sellingPrice.toString());
    TextEditingController quantity = TextEditingController(text: '0');
    TextEditingController note = TextEditingController(text: 'ـ');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تفاصيل المنتج'),
          content: SizedBox(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم المنتج:\t ${product.nameProduct}',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromARGB(255, 22, 87, 80))),
                Text('الكمية المتوفرة:\t ${product.quantity}',
                    style: const TextStyle(fontSize: 18)),
                Text(
                    'سعر الشراء:\t ${formatCurrency(product.purchasingPrice.toString())}',
                    style: const TextStyle(fontSize: 18)),
                textFormFieldNumber(
                  'السعر',
                  price,
                ),
                textFormFieldNumber(
                  'الكمية',
                  quantity,
                ),
                textFormField(
                  'ملاحظة',
                  note,
                ),
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
            ElevatedButton(
              onPressed: () {
                if (price.text.isNotEmpty &&
                    quantity.text.isNotEmpty &&
                    int.parse(quantity.text) != 0) {
                  if (product.purchasingPrice < int.parse(price.text)) {
                    if (int.parse(quantity.text) <= product.quantity) {
                      int totalPrice =
                          int.parse(price.text) * int.parse(quantity.text);
                      int totalPriceProfits =
                          product.purchasingPrice * int.parse(quantity.text);
                      BasketModel newBasket = BasketModel(
                          idBasket: idBasket,
                          id: 0,
                          nameProduct: product.nameProduct,
                          note: note.text,
                          price: int.parse(price.text),
                          requiredQuantity: int.parse(quantity.text),
                          totalPriceProfits: totalPriceProfits,
                          totalPrice: totalPrice);

                      product.quantity -= int.parse(quantity.text);

                      databaseProvider.updateProduct(product);

                      databaseProvider.insertBasketItem(newBasket);

                      Navigator.of(context).pop();
                    } else {
                      Toast.show("ليس هناك كمية كافية",
                          backgroundColor: Colors.red,
                          backgroundRadius: 10,
                          duration: Toast.lengthLong,
                          gravity: Toast.bottom);
                    }
                  } else {
                    Toast.show("يجب ان تكون قيمة البيع اكثر من قيمة الشراء",
                        backgroundColor: Colors.red,
                        backgroundRadius: 10,
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom);
                  }
                } else {
                  Toast.show(
                      "يرجى ملأ كل الحقول اولا ولا يجب انت تكون قيمها تساوي 0",
                      backgroundColor: Colors.red,
                      backgroundRadius: 10,
                      duration: Toast.lengthLong,
                      gravity: Toast.bottom);
                }
              },
              child: const Text('اضافة'),
            ),
          ],
        );
      },
    );
  }

  void showRowDetailsDialog2(BuildContext context, BasketModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تفاصيل المنتج'),
          content: SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم المنتج:\t ${product.nameProduct}',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromARGB(255, 22, 87, 80))),
                Text('الكمية:\t ${product.requiredQuantity}',
                    style: const TextStyle(fontSize: 18)),
                Text('السعر:\t ${formatCurrency(product.price.toString())}',
                    style: const TextStyle(fontSize: 18)),
                Text(
                    'المجموع:\t ${formatCurrency(product.totalPrice.toString())}',
                    style: const TextStyle(fontSize: 18)),
                Text('ملاحظة:\t ${product.note}',
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

  void editBasket(BuildContext context, BasketModel product, Product productA) {
    final TextEditingController quantityController =
        TextEditingController(text: product.requiredQuantity.toString());

    final TextEditingController noteController =
        TextEditingController(text: product.note);
    productA.quantity += product.requiredQuantity;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل المنتج'),
          content: SizedBox(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم المنتج:\t ${product.nameProduct}',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromARGB(255, 22, 87, 80))),
                Text('السعر:\t ${formatCurrency(product.price.toString())}',
                    style: const TextStyle(fontSize: 18)),
                Text('الكمية المتوفرة:\t ${productA.quantity}',
                    style: const TextStyle(fontSize: 18)),
                textFormFieldNumber('العدد', quantityController),
                textFormField('ملاحظة', noteController),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (quantityController.text.isNotEmpty &&
                    int.parse(quantityController.text) != 0) {
                  if (int.parse(quantityController.text) <= productA.quantity) {
                    int totalPrice =
                        product.price * int.parse(quantityController.text);
                    int totalPriceProfits = productA.purchasingPrice *
                        int.parse(quantityController.text);

                    final editedProduct = BasketModel(
                      id: product.id,
                      idBasket: idBasket,
                      price: product.price,
                      nameProduct: product.nameProduct,
                      requiredQuantity: int.parse(quantityController.text),
                      totalPrice: totalPrice,
                      totalPriceProfits: totalPriceProfits,
                      note: noteController.text,
                    );
                    productA.quantity -= int.parse(quantityController.text);

                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .updateProduct(productA);

                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .updateBasketItem(editedProduct);

                    Navigator.of(context).pop();
                  } else {
                    Toast.show("ليس هناك كمية كافية",
                        backgroundColor: Colors.red,
                        backgroundRadius: 10,
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom);
                  }
                } else {
                  Toast.show(
                      "يرجى ملأ كل الحقول اولا ولا يجب انت تكون قيمها تساوي 0",
                      backgroundColor: Colors.red,
                      backgroundRadius: 10,
                      duration: Toast.lengthLong,
                      gravity: Toast.bottom);
                }
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

  void deleteBasket(BuildContext context, BasketModel basket, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف المنتج'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا المنتج؟'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                product.quantity += basket.requiredQuantity;
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .updateProduct(product);
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .deleteBasketItem(basket.id);

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

  Future<void> printPDF(BuildContext context, {bool isInInvoise = true}) async {
    int index = 1;
    int sumNumber = 0;
    List<ModelPDf> user = [];
    try {
      printDataPdf.numberOFInvoice =
          '${databaseProvider.sequence[databaseProvider.sequence.length - 1].id! + 1}';
    } catch (e) {}
    if (!isInInvoise) {
      for (BasketModel i in databaseProvider.baskets
          .where((element) => element.idBasket == idBasket)
          .toList()) {
        user.add(ModelPDf(
            index: index++,
            note: i.note,
            price: i.price,
            subject: i.nameProduct,
            total: i.totalPrice,
            theNumber: i.requiredQuantity));
        sumNumber += i.requiredQuantity;
      }

      final pdfFile = await PdfApi.generateTaple(
          printDataPdf: printDataPdf,
          user: user,
          totalPrice: totalPrice,
          totalPriceBeforeDiscount: totalPriceBeforeDiscount,
          totalCont: sumNumber);
      if (isInInvoise) {
        deleteAllBaskets(context, deleteItems: true);
        await Provider.of<DatabaseProvider>(context, listen: false)
            .deleteAllBasketItems(idBasket);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController namePr =
              TextEditingController(text: 'بيع مباشر');
          return AlertDialog(
            title: const Text('بيع مباشر'),
            content: const Text('هل انت متأكد من بيع القائمة بشكل مباشر؟'),
            actions: [
              textFormField(
                'اسم الزبون',
                namePr,
              ),
              ElevatedButton(
                onPressed: () async {
                  for (BasketModel i in databaseProvider.baskets
                      .where((element) => element.idBasket == idBasket)
                      .toList()) {
                    user.add(ModelPDf(
                        index: index++,
                        note: i.note,
                        price: i.price,
                        subject: i.nameProduct,
                        total: i.totalPrice,
                        theNumber: i.requiredQuantity));
                    sumNumber += i.requiredQuantity;
                  }
                  SequenceModel sequenceModel = SequenceModel(
                      clientId: 0,
                      profits: profits,
                      clientName: namePr.text,
                      totalPrice: totalPriceBeforeDiscount,
                      updateTimeDebts: DateTime.now(),
                      discountPrice: int.parse(discountController.text),
                      status: '',
                      updateTimeDebtsUpdate: '');
                  await databaseProvider.moveBasketDataToClient(
                    adminId: 1,
                    clientId: 0,
                    idBasket: idBasket,
                    sequenceModel: sequenceModel,
                  );
                  if (namePr.text.trim().isNotEmpty) {
                    printDataPdf.nameSalary = namePr.text.trim();
                  }

                  final pdfFile = await PdfApi.generateTaple(
                      printDataPdf: printDataPdf,
                      user: user,
                      totalPrice: totalPrice,
                      totalPriceBeforeDiscount: totalPriceBeforeDiscount,
                      totalCont: sumNumber);
                  PdfApi.openFile(pdfFile);
                  if (isInInvoise) {
                    deleteAllBaskets(context, deleteItems: true);
                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .deleteAllBasketItems(idBasket);
                  }
                  namePr.text = "";
                  discountController.text = "0";
                  Navigator.of(context).pop();
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
    // PdfApi.openFile(pdfFile);
  }
}
