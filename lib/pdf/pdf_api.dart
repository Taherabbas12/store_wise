import 'dart:ffi';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../model/print_data_pdf_model.dart';
import '../views/widgets/widgers_more.dart';

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
    required totalPriceBeforeDiscount,
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
              formatCurrency(user.total.toString()),
              formatCurrency(user.price.toString()),
              user.theNumber,
              user.subject,
              user.index,
            ])
        .toList();

    var arabicFont =
        Font.ttf(await rootBundle.load("assets/Hacen Tunisia.ttf"));

    try {
      pdf.addPage(
        await dataPageMulti(
            index: '1  من 1',
            arabicFont: arabicFont,
            data: data,
            header: header,
            printDataPdf: printDataPdf,
            totalPriceBeforeDiscount: totalPriceBeforeDiscount,
            isEnd: true,
            totalCont: totalCont.toString(),
            totalPrice: totalPrice.toString()),
      );
    } catch (e) {}

    return saveDocument(name: 'invoice.pdf', pdf: pdf);
  }

  static Future<Uint8List> getImageBytes() async {
    final ByteData data = await rootBundle.load('assets/logo_car/LOGO1.png');
    return data.buffer.asUint8List();
  }

  static Future<MultiPage> dataPageMulti({
    required arabicFont,
    required List<List<dynamic>> data,
    required header,
    required printDataPdf,
    required totalPriceBeforeDiscount,
    required index,
    String totalPrice = '',
    String totalCont = '',
    bool isEnd = false,
  }) async {
    var v = await getImageBytes();
    return MultiPage(
      footer: (context) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('رقم القائمة:$index', style: const TextStyle(fontSize: 8)),
          Text(printDataPdf.nameSalary, style: const TextStyle(fontSize: 7)),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('     الخطأ والسهو مرجوع للطرفين',
              style: const TextStyle(fontSize: 7)),
          Text('توقيع . . . .', style: const TextStyle(fontSize: 7)),
        ])
      ]),
      pageFormat: PdfPageFormat(
          58.0 * PdfPageFormat.mm, PdfPageFormat.mm * data.length * 7 + 140),
      crossAxisAlignment: CrossAxisAlignment.start,
      theme: ThemeData.withFont(
        base: arabicFont,
      ),
      textDirection: TextDirection.rtl,
      maxPages: 1,
      build: (context) {
        num discont = 0;
        try {
          discont = int.parse(totalPrice) - totalPriceBeforeDiscount;
        } catch (e) {}
        print('discont :$discont');
        return [
          Wrap(children: [
            ListView(children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(4),
                ),
                margin: const EdgeInsets.symmetric(vertical: 2),
                height: 25,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        child: Text(
                            '      حضرة السيد/ة :${printDataPdf.nameSalary}\n ${printDataPdf.phoneSalary}',
                            style: const TextStyle(fontSize: 8)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Row(
                          verticalDirection: VerticalDirection.up,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '        رقم القائمة:${printDataPdf.numberOFInvoice}    التاريخ:${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}    ${(DateTime.now().minute < 10 ? "0${DateTime.now().minute}" : DateTime.now().minute)}: ${(DateTime.now().hour < 10 ? "0${DateTime.now().hour}" : (DateTime.now().hour < 13 ? DateTime.now().hour : (DateTime.now().hour - 12)))} ${(DateTime.now().hour < 12 ? "ص" : "م")}',
                                style: const TextStyle(fontSize: 7)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              if (isEnd)
                Container(
                  child: Row(
                    verticalDirection: VerticalDirection.up,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        height: 30,
                        child: Text('عدد المواد: $totalCont ',
                            style: const TextStyle(fontSize: 8),
                            textAlign: TextAlign.center),
                      ),
                      SizedBox(width: 5),
                      Container(
                        height: 45,
                        child: Text(
                            'المجموع: ${formatCurrency(totalPrice)} دينار\nالخصم : ${formatCurrency(discont.toString())} دينار\n_________________________\nبعد الخصم: ${formatCurrency(totalPriceBeforeDiscount.toString())} دينار',
                            style: const TextStyle(fontSize: 8),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
            ]),
          ]),
        ];
      },
    );
  }

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
