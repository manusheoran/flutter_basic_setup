import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ==================== DATA MODELS ====================

class UserProfile {
  final String name;
  final String id;
  final DateTime joinDate;

  UserProfile({
    required this.name,
    required this.id,
    required this.joinDate,
  });
}

class NindraData {
  final DateTime date;
  final String bedTime;
  final int bedTimePoints;
  final String wakeUpTime;
  final int wakeUpPoints;
  final String daySleep;
  final int daySleepPoints;

  NindraData({
    required this.date,
    required this.bedTime,
    required this.bedTimePoints,
    required this.wakeUpTime,
    required this.wakeUpPoints,
    required this.daySleep,
    required this.daySleepPoints,
  });

  int get totalPoints => bedTimePoints + wakeUpPoints + daySleepPoints;
}

class ActivityData {
  final DateTime date;
  final String japaTime;
  final int japaDuration; // in minutes
  final int japaPoints;
  final int pathanDuration; // in minutes
  final int pathanPoints;
  final int sravanDuration; // in minutes
  final int sravanPoints;
  final int sevaMinutes;
  final int sevaPoints;

  ActivityData({
    required this.date,
    required this.japaTime,
    required this.japaDuration,
    required this.japaPoints,
    required this.pathanDuration,
    required this.pathanPoints,
    required this.sravanDuration,
    required this.sravanPoints,
    required this.sevaMinutes,
    required this.sevaPoints,
  });

  int get totalPoints =>
      japaPoints + pathanPoints + sravanPoints + sevaPoints;
}

class DailyRecord {
  final NindraData nindra;
  final ActivityData activities;

  DailyRecord({
    required this.nindra,
    required this.activities,
  });

  int get totalDayPoints => nindra.totalPoints + activities.totalPoints;
}

// ==================== DUMMY DATA ====================

class DummyDataGenerator {
  static UserProfile getUser() {
    return UserProfile(
      name: "Radhika Krishna Das",
      id: "RKD2024001",
      joinDate: DateTime(2024, 1, 15),
    );
  }

  static List<DailyRecord> getDummyRecords() {
    return [
      DailyRecord(
        nindra: NindraData(
          date: DateTime(2025, 11, 1),
          bedTime: "10:05 PM",
          bedTimePoints: 20,
          wakeUpTime: "03:55 AM",
          wakeUpPoints: 25,
          daySleep: "1:10 hr",
          daySleepPoints: 20,
        ),
        activities: ActivityData(
          date: DateTime(2025, 11, 1),
          japaTime: "06:30 AM",
          japaDuration: 50,
          japaPoints: 25,
          pathanDuration: 40,
          pathanPoints: 20,
          sravanDuration: 45,
          sravanPoints: 25,
          sevaMinutes: 105,
          sevaPoints: 20,
        ),
      ),
      DailyRecord(
        nindra: NindraData(
          date: DateTime(2025, 11, 2),
          bedTime: "10:20 PM",
          bedTimePoints: 15,
          wakeUpTime: "04:10 AM",
          wakeUpPoints: 20,
          daySleep: "0:55 hr",
          daySleepPoints: 25,
        ),
        activities: ActivityData(
          date: DateTime(2025, 11, 2),
          japaTime: "07:00 AM",
          japaDuration: 45,
          japaPoints: 25,
          pathanDuration: 38,
          pathanPoints: 20,
          sravanDuration: 50,
          sravanPoints: 25,
          sevaMinutes: 135,
          sevaPoints: 40,
        ),
      ),
      DailyRecord(
        nindra: NindraData(
          date: DateTime(2025, 11, 3),
          bedTime: "09:50 PM",
          bedTimePoints: 25,
          wakeUpTime: "03:50 AM",
          wakeUpPoints: 25,
          daySleep: "1:05 hr",
          daySleepPoints: 20,
        ),
        activities: ActivityData(
          date: DateTime(2025, 11, 3),
          japaTime: "06:15 AM",
          japaDuration: 55,
          japaPoints: 25,
          pathanDuration: 48,
          pathanPoints: 25,
          sravanDuration: 52,
          sravanPoints: 25,
          sevaMinutes: 165,
          sevaPoints: 60,
        ),
      ),
      DailyRecord(
        nindra: NindraData(
          date: DateTime(2025, 11, 4),
          bedTime: "10:35 PM",
          bedTimePoints: 10,
          wakeUpTime: "04:25 AM",
          wakeUpPoints: 15,
          daySleep: "1:40 hr",
          daySleepPoints: 10,
        ),
        activities: ActivityData(
          date: DateTime(2025, 11, 4),
          japaTime: "08:00 AM",
          japaDuration: 35,
          japaPoints: 20,
          pathanDuration: 30,
          pathanPoints: 15,
          sravanDuration: 40,
          sravanPoints: 20,
          sevaMinutes: 95,
          sevaPoints: 20,
        ),
      ),
    ];
  }
}

// ==================== EXCEL EXPORTER ====================

class ExcelExporter {
  static Future<void> exportToExcel(
      UserProfile user, List<DailyRecord> records, BuildContext context) async {
    var excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Create User Profile Sheet
    _createUserProfileSheet(excel, user, records);

    // Create Daily Summary Sheet
    _createDailySummarySheet(excel, records);

    // Create Nindra Details Sheet
    _createNindraDetailsSheet(excel, records);

    // Create Activities Details Sheet
    _createActivitiesDetailsSheet(excel, records);

    // Save file
    await _saveExcelFile(excel, context);
  }

  static void _createUserProfileSheet(
      Excel excel, UserProfile user, List<DailyRecord> records) {
    var sheet = excel['User Profile'];

    // Headers
    sheet.cell(CellIndex.indexByString("A1")).value =  TextCellValue('User Information');
    sheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
    );

    // User details
    sheet.cell(CellIndex.indexByString("A3")).value =  TextCellValue('Name:');
    sheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(user.name);

    sheet.cell(CellIndex.indexByString("A4")).value =  TextCellValue('User ID:');
    sheet.cell(CellIndex.indexByString("B4")).value = TextCellValue(user.id);

    sheet.cell(CellIndex.indexByString("A5")).value =  TextCellValue('Join Date:');
    sheet.cell(CellIndex.indexByString("B5")).value =
        TextCellValue('${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}');

    sheet.cell(CellIndex.indexByString("A6")).value =  TextCellValue('Report Period:');
    sheet.cell(CellIndex.indexByString("B6")).value = TextCellValue(
        '${records.first.nindra.date.day}/${records.first.nindra.date.month}/${records.first.nindra.date.year} - ${records.last.nindra.date.day}/${records.last.nindra.date.month}/${records.last.nindra.date.year}');

    // Calculate totals
    int totalPoints = records.fold(0, (sum, r) => sum + r.totalDayPoints);
    int maxPossible = records.length * 325; // 325 max points per day

    sheet.cell(CellIndex.indexByString("A8")).value =  TextCellValue('Total Points:');
    sheet.cell(CellIndex.indexByString("B8")).value = IntCellValue(totalPoints);

    sheet.cell(CellIndex.indexByString("A9")).value =  TextCellValue('Max Possible:');
    sheet.cell(CellIndex.indexByString("B9")).value = IntCellValue(maxPossible);

    sheet.cell(CellIndex.indexByString("A10")).value =  TextCellValue('Percentage:');
    sheet.cell(CellIndex.indexByString("B10")).value =
        TextCellValue('${((totalPoints / maxPossible) * 100).toStringAsFixed(1)}%');
  }

  static void _createDailySummarySheet(Excel excel, List<DailyRecord> records) {
    var sheet = excel['Daily Summary'];

    // Headers
    var headers = [
      'Date',
      'Nindra Points',
      'Japa Points',
      'Pathan Points',
      'Sravan Points',
      'Seva Points',
      'Total Points'
    ];

    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.green,
      );
    }

    // Data rows
    for (int i = 0; i < records.length; i++) {
      var record = records[i];
      var row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          TextCellValue('${record.nindra.date.day}/${record.nindra.date.month}/${record.nindra.date.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          IntCellValue(record.nindra.totalPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          IntCellValue(record.activities.japaPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          IntCellValue(record.activities.pathanPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          IntCellValue(record.activities.sravanPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          IntCellValue(record.activities.sevaPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          IntCellValue(record.totalDayPoints);
    }
  }

  static void _createNindraDetailsSheet(Excel excel, List<DailyRecord> records) {
    var sheet = excel['Nindra Details'];

    // Headers
    var headers = [
      'Date',
      'Bed Time',
      'Bed Points',
      'Wake Up',
      'Wake Points',
      'Day Sleep',
      'Sleep Points',
      'Total'
    ];

    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.cyan,
      );
    }

    // Data rows
    for (int i = 0; i < records.length; i++) {
      var nindra = records[i].nindra;
      var row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          TextCellValue('${nindra.date.day}/${nindra.date.month}/${nindra.date.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(nindra.bedTime);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          IntCellValue(nindra.bedTimePoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          TextCellValue(nindra.wakeUpTime);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          IntCellValue(nindra.wakeUpPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          TextCellValue(nindra.daySleep);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          IntCellValue(nindra.daySleepPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          IntCellValue(nindra.totalPoints);
    }
  }

  static void _createActivitiesDetailsSheet(
      Excel excel, List<DailyRecord> records) {
    var sheet = excel['Activities Details'];

    // Headers
    var headers = [
      'Date',
      'Japa Time',
      'Japa (min)',
      'Japa Pts',
      'Pathan (min)',
      'Pathan Pts',
      'Sravan (min)',
      'Sravan Pts',
      'Seva (min)',
      'Seva Pts',
      'Total'
    ];

    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.yellow,
      );
    }

    // Data rows
    for (int i = 0; i < records.length; i++) {
      var activity = records[i].activities;
      var row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          TextCellValue('${activity.date.day}/${activity.date.month}/${activity.date.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(activity.japaTime);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          IntCellValue(activity.japaDuration);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          IntCellValue(activity.japaPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          IntCellValue(activity.pathanDuration);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          IntCellValue(activity.pathanPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          IntCellValue(activity.sravanDuration);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          IntCellValue(activity.sravanPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value =
          IntCellValue(activity.sevaMinutes);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value =
          IntCellValue(activity.sevaPoints);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value =
          IntCellValue(activity.totalPoints);
    }
  }

  static Future<void> _saveExcelFile(Excel excel, BuildContext context) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String fileName =
          'Sadhana_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      String filePath = '${directory.path}/$fileName';

      // Save file
      File file = File(filePath);
      var bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel saved: $filePath')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving Excel: $e')),
        );
      }
    }
  }
}

// ==================== PDF EXPORTER ====================

class PdfExporter {
  static Future<void> exportToPdf(
      UserProfile user, List<DailyRecord> records, BuildContext context) async {
    final pdf = pw.Document();

    // Calculate statistics
    int totalPoints = records.fold(0, (sum, r) => sum + r.totalDayPoints);
    int maxPossible = records.length * 325;
    double percentage = (totalPoints / maxPossible) * 100;

    // Page 1: Report Card
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'SADHANA PROGRESS REPORT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      user.name,
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Overall Score Card
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'OVERALL SCORE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '$totalPoints / $maxPossible points',
                      style: const pw.TextStyle(fontSize: 24, color: PdfColors.blue),
                    ),
                    pw.Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      _getGrade(percentage),
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Category Breakdown
              pw.Text(
                'CATEGORY BREAKDOWN',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              ..._buildCategoryBars(records),

              pw.SizedBox(height: 20),

              // Highlights
              pw.Text(
                'HIGHLIGHTS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ..._buildHighlights(records),
            ],
          );
        },
      ),
    );

    // Page 2: Detailed Data Table
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DAILY ACTIVITY LOG',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildDataTable(records),
            ],
          );
        },
      ),
    );

    // Save and open PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully')),
      );
    }
  }

  static String _getGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    return 'D';
  }

  static List<pw.Widget> _buildCategoryBars(List<DailyRecord> records) {
    int nindraTotal = records.fold(0, (sum, r) => sum + r.nindra.totalPoints);
    int japaTotal = records.fold(0, (sum, r) => sum + r.activities.japaPoints);
    int pathanTotal =
        records.fold(0, (sum, r) => sum + r.activities.pathanPoints);
    int sravanTotal =
        records.fold(0, (sum, r) => sum + r.activities.sravanPoints);
    int sevaTotal = records.fold(0, (sum, r) => sum + r.activities.sevaPoints);

    int nindraMax = records.length * 75;
    int activityMax = records.length * 25;
    int sevaMax = records.length * 100;

    return [
      _buildProgressBar('Nindra', nindraTotal, nindraMax, PdfColors.blue),
      _buildProgressBar('Japa', japaTotal, activityMax, PdfColors.green),
      _buildProgressBar('Pathan', pathanTotal, activityMax, PdfColors.orange),
      _buildProgressBar('Sravan', sravanTotal, activityMax, PdfColors.purple),
      _buildProgressBar('Seva', sevaTotal, sevaMax, PdfColors.red),
    ];
  }

  static pw.Widget _buildProgressBar(
      String label, int value, int max, PdfColor color) {
    double percentage = (value / max) * 100;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
              pw.Text('$value/$max (${percentage.toStringAsFixed(0)}%)',
                  style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            width: double.infinity,
            height: 20,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Stack(
              children: [
                pw.Container(
                  width: (percentage / 100) * 500,
                  decoration: pw.BoxDecoration(
                    color: color,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildHighlights(List<DailyRecord> records) {
    var bestDay = records.reduce(
        (a, b) => a.totalDayPoints > b.totalDayPoints ? a : b);
    var avgPoints = records.fold(0, (sum, r) => sum + r.totalDayPoints) /
        records.length;

    return [
      pw.Bullet(
        text:
            'Best Day: ${bestDay.nindra.date.day}/${bestDay.nindra.date.month} (${bestDay.totalDayPoints} pts)',
      ),
      pw.Bullet(
        text: 'Average Daily Points: ${avgPoints.toStringAsFixed(1)}',
      ),
      pw.Bullet(
        text: 'Total Days Tracked: ${records.length}',
      ),
    ];
  }

  static pw.Widget _buildDataTable(List<DailyRecord> records) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Nindra', isHeader: true),
            _buildTableCell('Japa', isHeader: true),
            _buildTableCell('Pathan', isHeader: true),
            _buildTableCell('Sravan', isHeader: true),
            _buildTableCell('Seva', isHeader: true),
            _buildTableCell('Total', isHeader: true),
          ],
        ),
        // Data rows
        ...records.map((record) {
          return pw.TableRow(
            children: [
              _buildTableCell(
                  '${record.nindra.date.day}/${record.nindra.date.month}'),
              _buildTableCell('${record.nindra.totalPoints}'),
              _buildTableCell('${record.activities.japaPoints}'),
              _buildTableCell('${record.activities.pathanPoints}'),
              _buildTableCell('${record.activities.sravanPoints}'),
              _buildTableCell('${record.activities.sevaPoints}'),
              _buildTableCell('${record.totalDayPoints}'),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}

// ==================== MAIN WIDGET ====================

class SadhanaExportScreen extends StatelessWidget {
  const SadhanaExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DummyDataGenerator.getUser();
    final records = DummyDataGenerator.getDummyRecords();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sadhana Export'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('User ID: ${user.id}'),
                    Text(
                        'Days Tracked: ${records.length}'),
                    Text(
                        'Total Points: ${records.fold(0, (sum, r) => sum + r.totalDayPoints)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Export Buttons
            ElevatedButton.icon(
              onPressed: () async {
                await ExcelExporter.exportToExcel(user, records, context);
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Download Excel Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () async {
                await PdfExporter.exportToPdf(user, records, context);
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),

            // Preview Data
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  '${record.nindra.date.day}/${record.nindra.date.month}/${record.nindra.date.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Nindra: ${record.nindra.totalPoints} | '
                                  'Japa: ${record.activities.japaPoints} | '
                                  'Pathan: ${record.activities.pathanPoints} | '
                                  'Sravan: ${record.activities.sravanPoints} | '
                                  'Seva: ${record.activities.sevaPoints}',
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${record.totalDayPoints} pts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MAIN APP ====================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sadhana Tracker Export',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SadhanaExportScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}