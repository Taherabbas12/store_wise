// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, use_build_context_synchronously

import '../../model/basket_client_model.dart';
import '../../model/sequence_model.dart';
import '/constants/colors_cos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../database/database_helper.dart';
import '../../model/item_model.dart';
import '../../model/print_data_pdf_model.dart';
import '../../pdf/pdf_api.dart';
import '../widgets/widgers_more.dart';

class ScreenEditSequens extends StatelessWidget {
  late TextEditingController searchController = TextEditingController();
  late TextEditingController qrCodeController = TextEditingController();
  TextEditingController discountController = TextEditingController(text: '0');
  late DatabaseProvider databaseProvider;
  int totalPrice = 0;
  int totalPriceBeforeDiscount = 0;
  int profits = 0;

  PrintDataPdfModel printDataPdf = PrintDataPdfModel(
      nameSalary: '', numberOFInvoice: '0', phoneSalary: '', address: '');
  List<BasketClientModel> dataEdit;
  List<Product> products = [];
  SequenceModel sequenceModel;

  ScreenEditSequens({
    super.key,
    required this.sequenceModel,
    required this.dataEdit,
  });
  final FocusNode _searchFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    printDataPdf = PrintDataPdfModel(
        nameSalary: sequenceModel.clientName,
        numberOFInvoice: sequenceModel.id.toString(),
        phoneSalary: '',
        address: '');

    databaseProvider = Provider.of<DatabaseProvider>(context);
    if (products.isEmpty) {
      discountController.text = sequenceModel.discountPrice.toString();
      products = databaseProvider.products;
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('بيع'),
              SizedBox(
                width: 50,
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
                            Product item = products
                                .where((element) => element.description == v)
                                .first;

                            item.quantity--;

                            List<BasketClientModel> editB = dataEdit
                                .where((element) =>
                                    element.nameProduct == item.nameProduct)
                                .toList();
                            if (editB.isEmpty) {
                              BasketClientModel newBasket = BasketClientModel(
                                  nameProduct: item.nameProduct,
                                  note: '',
                                  price: item.sellingPrice,
                                  requiredQuantity: 1,
                                  sequenceId: sequenceModel.id!,
                                  totalPrice: item.sellingPrice,
                                  totalPriceProfits:
                                      item.sellingPrice - item.sellingPrice);
                              print('Size : ${editB.length}');
                              dataEdit.add(newBasket);
                            } else {
                              editB[0].requiredQuantity++;
                              editB[0].totalPrice += int.parse(
                                  ((editB[0].price / editB[0].requiredQuantity)
                                          .round())
                                      .toString());
                              editB[0].totalPriceProfits +=
                                  item.sellingPrice - item.sellingPrice;
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
                            products
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
                    buildDataTableBasket(context),
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
                                      if (dataEdit.isNotEmpty) {
                                        print(sequenceModel.id);
                                        await databaseProvider
                                            .deleteBasketClientProduct(
                                                sequenceModel.id!);
                                        for (BasketClientModel i in dataEdit) {
                                          i.sequenceId = sequenceModel.id!;

                                          await databaseProvider
                                              .insertBasketClientProduct(i);
                                          if (discountController.text.isEmpty) {
                                            discountController.text = '0';
                                          }
                                          sequenceModel.status = 'معدله';
                                          sequenceModel.totalPrice =
                                              totalPrice -
                                                  int.parse(
                                                      discountController.text);
                                          sequenceModel.profits =
                                              totalPrice - profits;
                                          sequenceModel.discountPrice =
                                              int.parse(
                                                  discountController.text);

                                          await databaseProvider
                                              .updateSequence(sequenceModel);

                                          for (Product i in products) {
                                            await databaseProvider
                                                .updateProduct(i);
                                          }
                                        }
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
                                      'حفظ التعديل',
                                      style: TextStyle(fontSize: 18),
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
                              if (dataEdit
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

  Widget buildDataTableBasket(BuildContext context) {
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
                      rows: dataEdit.isNotEmpty
                          ? List.generate(dataEdit.length, (i) {
                              isBlackRow =
                                  !isBlackRow; // تبديل قيمة متغير اللون
                              totalPrice += dataEdit[i].totalPrice;
                              profits += dataEdit[i].totalPriceProfits;
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
                                              context, dataEdit[i]);
                                        },
                                        child: const Icon(Icons.info,
                                            color: Colors.blue),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          editBasket(
                                              context,
                                              dataEdit[i],
                                              products
                                                  .where((element) =>
                                                      element.nameProduct ==
                                                      dataEdit[i].nameProduct)
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
                                              dataEdit[i],
                                              products
                                                  .where((element) =>
                                                      element.nameProduct ==
                                                      dataEdit[i].nameProduct)
                                                  .first);
                                        },
                                        child: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  )),
                                  DataCell(Text((i + 1).toString())),
                                  DataCell(Text(dataEdit[i].nameProduct)),
                                  DataCell(Text(
                                      dataEdit[i].requiredQuantity.toString())),
                                  DataCell(Text(formatCurrency(
                                      dataEdit[i].price.toString()))),
                                  DataCell(Text(formatCurrency(
                                      dataEdit[i].totalPrice.toString()))),
                                  DataCell(Text(dataEdit[i].note)),
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

                      BasketClientModel newBasket = BasketClientModel(
                          sequenceId: sequenceModel.id!,
                          nameProduct: product.nameProduct,
                          note: note.text,
                          price: int.parse(price.text),
                          requiredQuantity: int.parse(quantity.text),
                          totalPrice: totalPrice,
                          totalPriceProfits: totalPriceProfits);

                      product.quantity -= int.parse(quantity.text);

                      dataEdit.add(newBasket);

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

  void showRowDetailsDialog2(BuildContext context, BasketClientModel product) {
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

  void editBasket(
      BuildContext context, BasketClientModel product, Product productA) {
    final TextEditingController quantityController =
        TextEditingController(text: product.requiredQuantity.toString());
    final TextEditingController priceController =
        TextEditingController(text: product.price.toString());

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
                textFormFieldNumber('السعر', priceController),
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
                    product.price = int.parse(priceController.text);
                    product.requiredQuantity =
                        int.parse(quantityController.text);
                    product.note = noteController.text;
                    product.totalPriceProfits = productA.purchasingPrice *
                        int.parse(quantityController.text);
                    product.totalPrice = int.parse(priceController.text) *
                        int.parse(quantityController.text);
                    productA.quantity -= int.parse(quantityController.text);

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

  void deleteBasket(
      BuildContext context, BasketClientModel basket, Product product) {
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

                dataEdit.remove(basket);
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

  Future<void> printPDF(BuildContext context) async {
    int index = 1;
    int sumNumber = 0;
    List<ModelPDf> user = [];
    try {
      printDataPdf.numberOFInvoice =
          '${databaseProvider.sequence[databaseProvider.sequence.length - 1].id! + 1}';
    } catch (e) {}

    for (BasketClientModel i in dataEdit) {
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
    // PdfApi.openFile(pdfFile);
  }
}
