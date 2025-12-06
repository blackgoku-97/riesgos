import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;

class ExportUtilsPlanificacion {
  static const _campos = {
    'area': 'Área',
    'planTrabajo': 'Plan de trabajo',
    'proceso': 'Proceso',
    'actividad': 'Actividad',
    'peligros': 'Peligros',
    'agenteMaterial': 'Agente Material',
    'medidas': 'Medidas',
    'nivelRiesgo': 'Riesgo',
  };

  static List<List<String>> _rows(Map<String, dynamic> data) =>
      _campos.entries.map((e) {
        final v = data[e.key];
        final txt = v is List ? v.join(', ') : v?.toString() ?? '';
        return [e.value, txt];
      }).where((r) => r[1].isNotEmpty).toList();

  static String _titulo(Map<String, dynamic> d) {
    final n = d['numeroPlanificacion']?.toString().trim() ?? '---';
    final a = d['año']?.toString().trim() ?? DateTime.now().year.toString();
    return n.toLowerCase().contains('planificación') ? n : 'Planificación $n - $a';
  }

  static String _safe(String s) =>
      s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();

  static Future<void> exportarExcel(Map<String, dynamic> data) async {
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];
    sheet.appendRow([TextCellValue('Campo'), TextCellValue('Valor')]);

    final rows = _rows(data);
    for (var i = 0; i < rows.length; i++) {
      sheet.appendRow([TextCellValue(rows[i][0]), TextCellValue(rows[i][1])]);
      final bg = i.isEven ? "#D9E1F2" : "#FFFFFF";
      for (var c = 0; c < 2; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: i + 1))
            .cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString(bg));
      }
    }

    final titulo = _titulo(data);
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${_safe(titulo)}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path)..writeAsBytesSync(excel.save()!);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: '$titulo Excel'));
  }

  static Future<void> exportarPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List());

    pw.MemoryImage? foto;
    final url = data['urlImagen']?.toString() ?? '';
    if (url.isNotEmpty) {
      final r = await http.get(Uri.parse(url));
      if (r.statusCode == 200) foto = pw.MemoryImage(r.bodyBytes);
    }

    final rows = _rows(data);
    final titulo = _titulo(data);
    final fecha = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logo, width: 60),
            pw.Text('Informe de Planificación',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generado el ${fecha.day}/${fecha.month}/${fecha.year} '
              '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        build: (_) => [
          pw.Center(
              child: pw.Text(titulo,
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Campo',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Valor',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold))),
                ],
              ),
              ...List.generate(rows.length, (i) {
                final bg = i.isEven
                    ? const PdfColor.fromInt(0xFFD9E1F2)
                    : PdfColors.white;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(rows[i][0])),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(rows[i][1])),
                  ],
                );
              }),
            ],
          ),
          if (foto != null)
            pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Image(foto, width: 300)),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${_safe(titulo)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path)..writeAsBytesSync(await pdf.save());
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: '$titulo PDF'));
  }
}