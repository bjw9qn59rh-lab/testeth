import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/time_entry.dart';

class PdfService {
  Future<File> exportMonth(List<TimeEntry> entries, DateTime month) async {
    final pdf = pw.Document();
    final df = DateFormat('dd.MM.yyyy');
    final mf = DateFormat('MMMM yyyy','de_DE');

    // Filter month
    final monthEntries = entries.where((e) => e.date.year == month.year && e.date.month == month.month).toList();
    monthEntries.sort((a,b)=> a.date.compareTo(b.date));

    // Group by day
    final Map<String, List<TimeEntry>> byDay = {};
    for (final e in monthEntries) {
      final k = df.format(e.date);
      byDay.putIfAbsent(k, ()=>[]).add(e);
    }

    Duration total = Duration.zero;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text('Elektro-Technik Herold – Zeiterfassung', style: pw.TextStyle(fontSize: 20, color: PdfColors.red800, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Monatsübersicht ${mf.format(month)}', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 16),
            ...byDay.entries.map((day) {
              return pw.Column(children: [
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE53935)),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Datum', style: pw.TextStyle(color: PdfColors.white))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tätigkeit', style: pw.TextStyle(color: PdfColors.white))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Start', style: pw.TextStyle(color: PdfColors.white))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Ende', style: pw.TextStyle(color: PdfColors.white))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Dauer', style: pw.TextStyle(color: PdfColors.white))),
                      ],
                    ),
                    ...day.value.map((e) {
                      total += e.duration;
                      final d = '${e.duration.inHours}:${(e.duration.inMinutes % 60).toString().padLeft(2,'0')}';
                      return pw.TableRow(children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(day.key)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(activityLabel(e.activity))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e.start)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e.end)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(d)),
                      ]);
                    }),
                  ],
                ),
                pw.SizedBox(height: 12),
              ]);
            }).toList(),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Summe: ${total.inHours} h ${(total.inMinutes%60).toString().padLeft(2,'0')} m', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            )
          ];
        }
      )
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ETH_Monatsuebersicht_${month.year}-${month.month.toString().padLeft(2,'0')}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
