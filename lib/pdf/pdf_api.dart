import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../model/print_data_pdf_model.dart';

class ModelPDf {
  final int index;

  final String subject;
  final int theNumber;
  final int price;
  final int total;
  final String note;
  ModelPDf({
    required this.subject,
    required this.index,
    required this.theNumber,
    required this.price,
    required this.note,
    required this.total,
  });
}

class PdfApi {
  static Future<File> generateTaple({
    required List<ModelPDf> user,
    required PrintDataPdfModel printDataPdf,
    required totalCont,
    required totalPrice,
  }) async {
    final pdf = Document();
    final header = [
      'الملاحظات',
      'المجموع',
      'السعر',
      'العدد',
      'المادة',
      'ت',
    ];

    final data = user
        .map((user) => [
              user.note,
              user.total,
              user.price,
              user.theNumber,
              user.subject,
              user.index,
            ])
        .toList();

    var arabicFont =
        Font.ttf(await rootBundle.load("assets/Hacen Tunisia.ttf"));
    // هذا تطبع على حجم الملف كلما كبر الملف تطبع القائمة على حجمة

    if (data.length <= 17) {
      pdf.addPage(await dataPageMulti(
          index: '1  من 1',
          arabicFont: arabicFont,
          data: data,
          header: header,
          printDataPdf: printDataPdf,
          isEnd: true,
          totalCont: totalCont.toString(),
          totalPrice: totalPrice.toString()));
    } else if (data.length <= 34) {
      pdf.addPage(await dataPageMulti(
          index: '1  من 2',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(0, 17),
          header: header));
      pdf.addPage(await dataPageMulti(
          index: '2  من 2',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(17, data.length),
          header: header,
          isEnd: true,
          totalCont: totalCont.toString(),
          totalPrice: totalPrice.toString()));
    } else if (data.length <= 54) {
      pdf.addPage(await dataPageMulti(
        index: '1  من 3',
        printDataPdf: printDataPdf,
        arabicFont: arabicFont,
        data: data.sublist(0, 20),
        header: header,
      ));
      pdf.addPage(await dataPageMulti(
          index: '2  من 3',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(20, 40),
          header: header));
      pdf.addPage(await dataPageMulti(
          index: '3  من 3',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(40, data.length),
          header: header,
          isEnd: true,
          totalCont: totalCont.toString(),
          totalPrice: totalPrice.toString()));
    } else if (data.length <= 80) {
      pdf.addPage(await dataPageMulti(
          index: '1  من 4',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(0, 20),
          header: header));
      pdf.addPage(await dataPageMulti(
          index: '2  من 4 ',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(20, 40),
          header: header));
      pdf.addPage(await dataPageMulti(
          index: '3 من 4 ',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(40, 60),
          header: header));
      pdf.addPage(await dataPageMulti(
          index: '4 من 4 ',
          printDataPdf: printDataPdf,
          arabicFont: arabicFont,
          data: data.sublist(60, data.length),
          header: header,
          isEnd: true,
          totalCont: totalCont.toString(),
          totalPrice: totalPrice.toString()));
    }

    return saveDocument(name: 'my_example.pdf', pdf: pdf);
  }

  static Future<Uint8List> getImageBytes() async {
    // قم بتحميل صورتك هنا، يمكنك استخدام الحزمة 'image' مثل 'image_picker'
    // أو تحميلها من الإنترنت أو من مصدر آخر.
    // هنا يتم استخدام صورة بسيطة من الأمثلة.
    final ByteData data = await rootBundle.load('assets/logo_car/LOGO1.png');
    return data.buffer.asUint8List();
  }

  static Future<MultiPage> dataPageMulti(
      {required arabicFont,
      required data,
      required header,
      required printDataPdf,
      required index,
      String totalPrice = '',
      String totalCont = '',
      bool isEnd = false}) async {
    var v = await getImageBytes();
    return MultiPage(
        footer: (context) => Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text('رقم القائمة:$index'),
                Text(printDataPdf.nameSalary),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('الخطأ والسهو مرجوع للطرفين'),
                Text('توقيع . . . . . . .'),
              ])
            ]),
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (context) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: PdfColors.blue100,
                border: Border.all(color: PdfColors.blue900),
                borderRadius: BorderRadius.circular(5)),
            width: double.infinity,
            child: Column(children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 55),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              child: Image(MemoryImage(v),
                                  height: 30, width: 150, fit: BoxFit.contain),
                            )
                          ]),
                      Text('محلات النبأ',
                          style: TextStyle(
                              fontSize: 50,
                              fontBold: Font.timesBold(),
                              height: 0)),
                    ]),
                    Text(
                        'لبيع الادوات الاحتياطية للسيارات\nوبيع جميع انواع المحركات (الثقيلة والمولدات)\nبغداد-كسرة وعطش-مقابل دائرة الكهرباء',
                        style: TextStyle(
                            fontSize: 14,
                            fontBold: Font.timesBold(),
                            height: 0)),
                  ]),
              Text(
                  'بأدارة السيد باسم 07901150818-07707260572    |   سلمان 07716837908',
                  style: TextStyle(fontSize: 14, fontBold: Font.timesBold()),
                  textAlign: TextAlign.center),
            ])),
        theme: ThemeData.withFont(
          base: arabicFont,
        ),
        textDirection: TextDirection.rtl,
        maxPages: 100,
        build: (context) => [
              Wrap(children: [
                // الجدول
                ListView(children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child:
                        Row(verticalDirection: VerticalDirection.up, children: [
                      Expanded(
                        child: Container(
                          child: Text(
                              'حضرة السيد:${printDataPdf.nameSalary}\n ${printDataPdf.phoneSalary}'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: Row(
                                verticalDirection: VerticalDirection.up,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                              Text(
                                  'رقم القائمة:${printDataPdf.numberOFInvoice}\n التاريخ:${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}    ${(DateTime.now().minute < 10 ? "0${DateTime.now().minute}" : DateTime.now().minute)}: ${(DateTime.now().hour < 10 ? "0${DateTime.now().hour}" : (DateTime.now().hour < 13 ? DateTime.now().hour : (DateTime.now().hour - 12)))} ${(DateTime.now().hour < 12 ? "ص" : "م")}'),
                            ])),
                      )
                    ]),
                  ),
                  Table.fromTextArray(
                    data: data,
                    headers: header,
                    cellAlignment: Alignment.bottomRight,
                    headerDecoration: BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  if (isEnd)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: Row(
                        verticalDirection: VerticalDirection.up,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: PdfColors.black)),
                              height: 25,
                              child: Row(
                                  verticalDirection: VerticalDirection.up,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text('عدد المواد:'),
                                    ),
                                    VerticalDivider(
                                      color: PdfColors.black,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(totalCont),
                                    )
                                  ])),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: PdfColors.black)),
                            height: 25,
                            child: Row(
                                verticalDirection: VerticalDirection.up,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('المجموع'),
                                  ),
                                  VerticalDivider(
                                    color: PdfColors.black,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('$totalPrice   دينار'),
                                  )
                                ]),
                          )
                        ],
                      ),
                    )
                ])
              ]),
            ]);
    // المجموع
  }

  // static Future<File> generateCenteredText() async {
  //   final pdf = Document(
  //     theme: ThemeData.base(),
  //   );
  //   var arabicFont =
  //       Font.ttf(await rootBundle.load("assets/Hacen Tunisia.ttf"));
  //   pdf.addPage(Page(
  //     theme: ThemeData.withFont(
  //       base: arabicFont,
  //     ),
  //     pageFormat: PdfPageFormat.roll80,
  //     build: (Context context) => Center(
  //       child: Text('طاهر',
  //           style: TextStyle(fontSize: 20, font: Font.courier()),
  //           textDirection: TextDirection.rtl),
  //     ),
  //   ));
  //   // pdf.addPage(create_invoice);
  //   return saveDocument(name: 'my_example.pdf', pdf: pdf);
  // }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
