import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;

class ExportUtils {
  static const List<String> _camposPermitidos = [
    'area',
    'planTrabajo',
    'proceso',
    'actividad',
    'peligros',
    'agenteMaterial',
    'medidas',
    'nivelRiesgo',
  ];

  static String _etiquetaCampo(String key) {
    switch (key) {
      case 'area':
        return 'Área';
      case 'planTrabajo':
        return 'Plan de trabajo';
      case 'proceso':
        return 'Proceso';
      case 'actividad':
        return 'Actividad';
      case 'peligros':
        return 'Peligros';
      case 'agenteMaterial':
        return 'Agente Material';
      case 'medidas':
        return 'Medidas';
      case 'nivelRiesgo':
        return 'Riesgo';
      default:
        return key;
    }
  }

  static String _tituloDocumento(Map<String, dynamic> data) {
    final numero = data['numeroPlanificacion']?.toString().trim() ?? '---';
    final anio = data['año']?.toString().trim() ?? DateTime.now().year.toString();
    if (numero.toLowerCase().contains('planificación')) return numero;
    return 'Planificación $numero - $anio';
  }

  static String _sanitizeFilename(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').replaceAll('  ', ' ').trim();
  }

  static List<List<String>> _buildDataList(Map<String, dynamic> data) {
    final rows = <List<String>>[];
    for (final campo in _camposPermitidos) {
      if (data.containsKey(campo)) {
        final valor = data[campo];
        final texto = valor is List ? valor.join(', ') : valor?.toString() ?? '';
        rows.add([_etiquetaCampo(campo), texto]);
      }
    }
    return rows;
  }

  static Future<void> exportarExcel(Map<String, dynamic> data) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet()!;
    final sheet = excel[defaultSheet];
    for (final name in excel.sheets.keys.toList()) {
      if (name != defaultSheet) excel.delete(name);
    }

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
      backgroundColorHex: ExcelColor.fromHexString("#4472C4"),
      horizontalAlign: HorizontalAlign.Center,
    );

    sheet.appendRow([TextCellValue('Campo'), TextCellValue('Valor')]);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).cellStyle = headerStyle;

    final rows = _buildDataList(data);
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      sheet.appendRow([TextCellValue(row[0]), TextCellValue(row[1])]);
      final bgColor = i % 2 == 0 ? "#D9E1F2" : "#FFFFFF";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).cellStyle =
          CellStyle(backgroundColorHex: ExcelColor.fromHexString(bgColor));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).cellStyle =
          CellStyle(backgroundColorHex: ExcelColor.fromHexString(bgColor));
    }

    final fechaGeneracion = DateTime.now();
    final tituloDoc = _tituloDocumento(data);

    sheet.appendRow([
      TextCellValue('Generado el'),
      TextCellValue(
        '${fechaGeneracion.day}/${fechaGeneracion.month}/${fechaGeneracion.year} '
        '${fechaGeneracion.hour.toString().padLeft(2, '0')}:${fechaGeneracion.minute.toString().padLeft(2, '0')}',
      ),
    ]);

    final lastRowIndex = sheet.maxRows - 1;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: lastRowIndex)).cellStyle =
        CellStyle(backgroundColorHex: ExcelColor.fromHexString("#FFD966"), bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: lastRowIndex)).cellStyle =
        CellStyle(backgroundColorHex: ExcelColor.fromHexString("#FFD966"));

    for (var col = 0; col < sheet.maxColumns; col++) {
      int maxLength = 0;
      for (var row in sheet.rows) {
        final cellValue = row[col]?.value?.toString() ?? '';
        if (cellValue.length > maxLength) maxLength = cellValue.length;
      }
      sheet.setColumnWidth(col, maxLength.toDouble() + 2);
    }

    final dir = await getTemporaryDirectory();
    final safeTitle = _sanitizeFilename(tituloDoc);
    final path = '${dir.path}/$safeTitle${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(path)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: '$tituloDoc exportada a Excel'),
      );
    }
  }

  static Future<void> exportarPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pw.MemoryImage? fotoImage;
    if (data['urlImagen'] != null && data['urlImagen'].toString().isNotEmpty) {
      final response = await http.get(Uri.parse(data['urlImagen']));
      if (response.statusCode == 200) {
        fotoImage = pw.MemoryImage(response.bodyBytes);
      }
    }

    final rows = _buildDataList(data);
    final fechaGeneracion = DateTime.now();
    final tituloDoc = _tituloDocumento(data);

    final headerRow = pw.Container(
      color: const PdfColor.fromInt(0xFF4472C4),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey, width: 0.5)),
              child: pw.Text('Campo', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey, width: 0.5)),
              child: pw.Text('Valor', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    final List<pw.Widget> tableLike = [headerRow];

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isEven = i % 2 == 0;
      tableLike.add(
        pw.Container(
          color: isEven ? const PdfColor.fromInt(0xFFD9E1F2) : PdfColors.white,
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey, width: 0.5)),
                  child: pw.Text(row[0]),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey, width: 0.5)),
                  child: pw.Text(row[1]),
                ),
              ),
            ],
          ),
        ),
      );

      if (row[0] == 'Riesgo' && fotoImage != null) {
        tableLike.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Center(child: pw.Image(fotoImage, width: 300)),
          ),
        );
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logoImage, width: 60),
            pw.Text('Informe de Planificación', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generado el ${fechaGeneracion.day}/${fechaGeneracion.month}/${fechaGeneracion.year} '
              '${fechaGeneracion.hour.toString().padLeft(2, '0')}:${fechaGeneracion.minute.toString().padLeft(2, '0')}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        build: (_) => [
          pw.SizedBox(height: 20),
          pw.Center(child: pw.Text(tituloDoc, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Column(children: tableLike),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final safeTitle = _sanitizeFilename(tituloDoc);
    final path = '${dir.path}/$safeTitle${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: '$tituloDoc exportada a PDF'),
    );
  }
}