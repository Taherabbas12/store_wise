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
    final pdf = Document(pageMode: PdfPageMode.fullscreen);
    final header = [
      'المجموع',
      'السعر',
      'العدد',
      'المادة',
      'ت',
    ];

    final data = user
        .map((user) => [
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

    // if (data.length <= 17) {
    pdf.addPage(
      await dataPageMulti(
          index: '1  من 1',
          arabicFont: arabicFont,
          data: data,
          header: header,
          printDataPdf: printDataPdf,
          isEnd: true,
          totalCont: totalCont.toString(),
          totalPrice: totalPrice.toString()),
    );
    // } else if (data.length <= 34) {
    //   pdf.addPage(await dataPageMulti(
    //       index: '1  من 2',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(0, 17),
    //       header: header));
    //   pdf.addPage(await dataPageMulti(
    //       index: '2  من 2',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(17, data.length),
    //       header: header,
    //       isEnd: true,
    //       totalCont: totalCont.toString(),
    //       totalPrice: totalPrice.toString()));
    // } else if (data.length <= 54) {
    //   pdf.addPage(await dataPageMulti(
    //     index: '1  من 3',
    //     printDataPdf: printDataPdf,
    //     arabicFont: arabicFont,
    //     data: data.sublist(0, 20),
    //     header: header,
    //   ));
    //   pdf.addPage(await dataPageMulti(
    //       index: '2  من 3',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(20, 40),
    //       header: header));
    //   pdf.addPage(await dataPageMulti(
    //       index: '3  من 3',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(40, data.length),
    //       header: header,
    //       isEnd: true,
    //       totalCont: totalCont.toString(),
    //       totalPrice: totalPrice.toString()));
    // } else if (data.length <= 80) {
    //   pdf.addPage(await dataPageMulti(
    //       index: '1  من 4',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(0, 20),
    //       header: header));
    //   pdf.addPage(await dataPageMulti(
    //       index: '2  من 4 ',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(20, 40),
    //       header: header));
    //   pdf.addPage(await dataPageMulti(
    //       index: '3 من 4 ',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(40, 60),
    //       header: header));
    //   pdf.addPage(await dataPageMulti(
    //       index: '4 من 4 ',
    //       printDataPdf: printDataPdf,
    //       arabicFont: arabicFont,
    //       data: data.sublist(60, data.length),
    //       header: header,
    //       isEnd: true,
    //       totalCont: totalCont.toString(),
    //       totalPrice: totalPrice.toString()));
    // }

    return saveDocument(name: 'invoice.pdf', pdf: pdf);
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
      required List<List<dynamic>> data,
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
                Text('رقم القائمة:$index', style: const TextStyle(fontSize: 8)),
                Text(printDataPdf.nameSalary,
                    style: const TextStyle(fontSize: 8)),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('الخطأ والسهو مرجوع للطرفين',
                    style: const TextStyle(fontSize: 8)),
                Text('توقيع . . . . . . .',
                    style: const TextStyle(fontSize: 8)),
              ])
            ]),
        pageFormat: PdfPageFormat(58.0 * PdfPageFormat.mm,
            (PdfPageFormat.inch * data.length * 3) + 10),
        orientation: PageOrientation.landscape,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    height: 15,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
                    cellHeight: 10,
                    cellStyle: const TextStyle(fontSize: 6),
                    headerStyle: const TextStyle(fontSize: 6),
                    cellAlignment: Alignment.bottomRight,
                    headerDecoration: BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  if (isEnd)
                    Container(
                      child: Row(
                        verticalDirection: VerticalDirection.up,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 12,
                            child: Text('عدد المواد: $totalCont',
                                style: const TextStyle(fontSize: 8)),
                          ),
                          SizedBox(width: 5),
                          Container(
                            height: 12,
                            child: Text('المجموع: $totalPrice دينار',
                                style: const TextStyle(fontSize: 8)),
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
