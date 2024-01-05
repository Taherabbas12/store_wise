// ignore_for_file: library_private_types_in_public_api

import 'package:Al_Yaqeen/model/barcode_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_helper.dart';
import '../../model/item_model.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../../constants/colors_cos.dart';

class ViewItems extends StatelessWidget {
  late TextEditingController searchController = TextEditingController();
  TextEditingController nameProduct = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController purchasingPrice = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController note = TextEditingController();
  final FocusNode _searchFieldFocusNode = FocusNode();
  late TextEditingController qrCodeController = TextEditingController();

  late int idLast;
  late DatabaseProvider databaseProvider;
  @override
  Widget build(BuildContext context) {
    databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("اضافة المنتجات"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 400,
                height: 50,
                child: CupertinoSearchTextField(
                  controller: searchController,
                  placeholder: 'بحث عن منتج',
                  style: const TextStyle(color: Colors.white),
                  itemColor: Colors.white,
                  placeholderStyle: const TextStyle(color: Colors.white60),
                ),
              )
            ],
          )
        ],
      ),
      body: addView(context),
    );
  }

  Widget addView(BuildContext context) {
    idLast = databaseProvider.products.isNotEmpty
        ? databaseProvider.products.lastOrNull!.id
        : 1;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                textFormField('اسم المنتج', nameProduct),
                textFormFieldNumber('الكمية المتوفرة', quantity),
                textFormFieldNumber('سعر البيع', sellingPrice),
                textFormFieldNumber('سعر الشراء', purchasingPrice),
                textFormField('الباركود', description),
                textFormField('ملاحظة', note),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 50),
              shadowColor: Colors.black,
              elevation: 7,
              shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            onPressed: () async {
              if (nameProduct.text.isNotEmpty &&
                  quantity.text.isNotEmpty &&
                  sellingPrice.text.isNotEmpty &&
                  purchasingPrice.text.isNotEmpty &&
                  description.text.isNotEmpty &&
                  note.text.isNotEmpty) {
                if (int.parse(sellingPrice.text) >
                    int.parse(purchasingPrice.text)) {
                  idLast++;
                  final newProduct = Product(
                    id: idLast,
                    nameProduct: nameProduct.text,
                    description: description.text,
                    note: note.text,
                    purchasingPrice: int.parse(purchasingPrice.text),
                    quantity: int.parse(quantity.text),
                    sellingPrice: int.parse(sellingPrice.text),
                  );
                  await databaseProvider.insertProduct(newProduct);

                  nameProduct.clear();
                  quantity.clear();
                  sellingPrice.clear();
                  purchasingPrice.clear();
                  description.clear();
                  note.clear();
                } else {
                  Toast.show("يجب ان يكون سعر البيع اكثر من سعر الشراء",
                      backgroundColor: Colors.red,
                      backgroundRadius: 10,
                      duration: Toast.lengthLong,
                      gravity: Toast.bottom);
                }
              } else {
                Toast.show("يرجى ملأ كل الحقول اولا",
                    backgroundColor: Colors.red,
                    backgroundRadius: 10,
                    duration: Toast.lengthLong,
                    gravity: Toast.bottom);
              }
            },
            child: const Text(
              'اضافة المنتج',
              style: TextStyle(fontSize: 18),
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
      ),
    );
  }

  Widget buildDataTable(List<Product> products, BuildContext context) {
    bool isBlackRow = false; // متغير لتبديل لون الصفوف

    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: MediaQuery.sizeOf(context).width * 0.08,
          columns: const [
            DataColumn(label: Text('')),
            DataColumn(label: Text('ت')),
            DataColumn(label: Text('اسم المنتج')),
            DataColumn(label: Text('الكمية المتوفرة')),
            DataColumn(label: Text('سعر البيع')),
            DataColumn(label: Text('سعر الشراء')),
            DataColumn(label: Text('الباركود')),
            DataColumn(label: Text('ملاحظة')),
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
                DataCell(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        databaseProvider.getAllBarcodes(products[i].id);
                        showAndAddQrCode(context, products[i]);
                      },
                      child: const Icon(Icons.qr_code_scanner_sharp,
                          color: Color.fromARGB(255, 24, 24, 24)),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        showRowDetailsDialog(context, products[i]);
                      },
                      child: const Icon(Icons.info, color: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        editProduct(context, products[i]);
                      },
                      child: const Icon(Icons.update, color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        deleteProduct(context, products[i]);
                      },
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                )),
                DataCell(Text((i + 1).toString())),
                DataCell(Text(products[i].nameProduct)),
                DataCell(Text(products[i].quantity.toString())),
                DataCell(Text(products[i].sellingPrice.toString())),
                DataCell(Text(products[i].purchasingPrice.toString())),
                DataCell(Text(products[i].description)),
                DataCell(Text(products[i].note)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget textFormField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 300,
      child: TextFormField(
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

  Widget textFormFieldNumber(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 300,
      child: TextFormField(
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
      ),
    );
  }

  Widget textTableView(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 17),
      ),
    );
  }

  void showRowDetailsDialog(BuildContext context, Product product) {
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
                Text('الكمية المتوفرة:\t ${product.quantity}',
                    style: const TextStyle(fontSize: 18)),
                Text('سعر البيع:\t ${product.sellingPrice}',
                    style: const TextStyle(fontSize: 18)),
                Text('سعر الشراء:\t ${product.purchasingPrice}',
                    style: const TextStyle(fontSize: 18)),
                Text('الباركود:\t ${product.description}',
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

  void showAndAddQrCode(BuildContext context, Product product) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اضافة باركود للمنتج'),
          content: SizedBox(
            height: 400,
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم المنتج:\t ${product.nameProduct}',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromARGB(255, 22, 87, 80))),
                Container(
                  margin: const EdgeInsets.all(5),
                  width: 290,
                  height: 50,
                  child: CupertinoSearchTextField(
                      focusNode: _searchFieldFocusNode,
                      backgroundColor: colorPrimary.withOpacity(0.8),
                      controller: qrCodeController,
                      placeholder: 'امسح الباركود',
                      style: const TextStyle(color: Colors.white),
                      itemColor: Colors.white,
                      placeholderStyle: const TextStyle(color: Colors.white60),
                      onSubmitted: (v) async {
                        if (v.isNotEmpty) {
                          databaseProvider.insertBarcode(BarcodeData(
                              id: 0,
                              productsId: product.id,
                              barcode: qrCodeController.text));
                          print("ADD______");
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
                      }),
                ),
                Expanded(
                  child: StreamBuilder(
                      stream: Stream.periodic(
                          const Duration(milliseconds: 200), (v) => {}),
                      builder: (context, snapshot) {
                        return ListView.builder(
                          itemCount: databaseProvider.barcodeProducts.length,
                          itemBuilder: (context, index) => ListTile(
                            leading: Text('${index + 1}'),
                            title: Text(databaseProvider
                                .barcodeProducts.reversed
                                .toList()[index]
                                .barcode),
                            trailing: IconButton(
                                onPressed: () {
                                  databaseProvider.deleteBarcode(
                                      databaseProvider.barcodeProducts.reversed
                                          .toList()[index]);
                                },
                                icon: const Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.red,
                                )),
                          ),
                        );
                      }),
                )
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

  void editProduct(BuildContext context, Product product) {
    final TextEditingController nameProductController =
        TextEditingController(text: product.nameProduct);
    final TextEditingController quantityController =
        TextEditingController(text: product.quantity.toString());
    final TextEditingController sellingPriceController =
        TextEditingController(text: product.sellingPrice.toString());
    final TextEditingController purchasingPriceController =
        TextEditingController(text: product.purchasingPrice.toString());
    final TextEditingController descriptionController =
        TextEditingController(text: product.description);
    final TextEditingController noteController =
        TextEditingController(text: product.note);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل المنتج'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  textFormField('اسم المنتج', nameProductController),
                  textFormFieldNumber('العدد', quantityController),
                  textFormFieldNumber('سعر البيع', sellingPriceController),
                  textFormFieldNumber('سعر الشراء', purchasingPriceController),
                  textFormField('الباركود', descriptionController),
                  textFormField('ملاحظة', noteController),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final editedProduct = Product(
                  id: product.id,
                  nameProduct: nameProductController.text,
                  quantity: int.parse(quantityController.text),
                  sellingPrice: int.parse(sellingPriceController.text),
                  purchasingPrice: int.parse(purchasingPriceController.text),
                  description: descriptionController.text,
                  note: noteController.text,
                );
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .updateProduct(editedProduct);

                Navigator.of(context).pop();
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

  void deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف المنتج'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا المنتج؟'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .deleteProduct(product.id);

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
}
