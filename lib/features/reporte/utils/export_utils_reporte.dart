import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;

class ExportUtilsReporte {
  static const _campos = {
    'cargo': 'Cargo',
    'lugar': 'Lugar',
    'tipoAccidente': 'Tipo de Accidente',
    'lesiones': 'Lesiones',
    'actividad': 'Actividad',
    'clasificacion': 'Clasificación',
    'accionesInseguras': 'Acciones Inseguras',
    'condicionesInseguras': 'Condiciones Inseguras',
    'medidas': 'Medidas',
    'quienAfectado': '¿A quién le ocurrió?',
    'descripcion': 'Descripción',
    'frecuencia': 'Frecuencia',
    'severidad': 'Severidad',
    'potencial': 'Potencial',
    'nivelPotencial': 'Nivel Potencial',
  };

  static DateTime _fecha(dynamic v) {
    if (v is DateTime) return v;
    try {
      return (v as dynamic).toDate();
    } catch (_) {}
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  /// 🔎 Aquí está la lógica que evita mostrar "lesiones" en cuasi accidentes
  static List<List<String>> _buildRows(Map<String, dynamic> data) {
    final tipo = (data['tipoAccidente'] ?? '').toString().toLowerCase();

    return _campos.entries
        .where((e) {
          // 👇 si es cuasi accidente, no incluir lesiones
          if (tipo.contains('cuasi') && e.key == 'lesiones') return false;
          return true;
        })
        .map((e) {
          final v = data[e.key];
          final txt = v is List ? v.join(', ') : v?.toString() ?? '';
          return [e.value, txt];
        })
        .where((r) => r[1].isNotEmpty)
        .toList();
  }

  static String _titulo(Map<String, dynamic> d) {
    var id = d['numeroReporte']?.toString() ?? '---';
    id = id.replaceFirst(RegExp(r'^reporte\s*', caseSensitive: false), '');
    return 'Reporte $id';
  }

  static String _safe(String s) =>
      s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();

  static Future<void> exportarExcel(Map<String, dynamic> data) async {
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];
    sheet.appendRow([TextCellValue('Campo'), TextCellValue('Valor')]);
    final rows = _buildRows(data);
    for (var r in rows) {
      sheet.appendRow([TextCellValue(r[0]), TextCellValue(r[1])]);
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/${_safe(_titulo(data))}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path)..writeAsBytesSync(excel.save()!);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '${_titulo(data)} exportado a Excel',
      )
    );
  }

  static Future<void> exportarPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    pw.MemoryImage? foto;
    final url = data['urlImagen']?.toString() ?? '';
    if (url.isNotEmpty) {
      final r = await http.get(Uri.parse(url));
      if (r.statusCode == 200) foto = pw.MemoryImage(r.bodyBytes);
    }

    final rows = _buildRows(data);
    final fechaGeneracion = DateTime.now();
    final fechaReporte = _fecha(data['createdAt']);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logo, width: 60),
            pw.Text(
              'Informe de Reporte',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
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
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        build: (_) => [
          pw.Center(
            child: pw.Text(
              '${_titulo(data)} - ${fechaReporte.year}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Campo',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Valor',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
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
                      child: pw.Text(rows[i][0]),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(rows[i][1]),
                    ),
                  ],
                );
              }),
            ],
          ),
          if (foto != null)
            pw.Padding(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Image(foto, width: 300),
            ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/${_safe(_titulo(data))}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path)..writeAsBytesSync(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '${_titulo(data)} exportado a PDF',
      )
    );
  }
}