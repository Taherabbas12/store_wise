import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

dynamic create_invoice = MultiPage(
    build: (context) => [
          buildCustomeHeadLine(),
          Paragraph(text: LoremText().paragraph(60)),
          Paragraph(text: LoremText().paragraph(60)),
          Paragraph(text: LoremText().paragraph(60)),
          Paragraph(text: LoremText().paragraph(60)),
        ]);

Widget buildCustomeHeadLine() => Header(
    child: Text('ٌ taher قائمة شراء الوزير',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: PdfColors.white),
        textDirection: TextDirection.rtl),
    decoration: BoxDecoration(color: PdfColors.red));
