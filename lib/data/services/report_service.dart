import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../../core/theme/app_colors.dart';

class ReportService {
  // Generate Excel Report from Activity Data
  static Future<void> exportToExcel(
    UserModel user,
    List<DailyActivity> activities,
    BuildContext context,
  ) async {
    var excel = Excel.createExcel();
    excel.delete('Sheet1');

    // User Profile Sheet
    _createUserProfileSheet(excel, user, activities);

    // Daily Summary Sheet
    _createDailySummarySheet(excel, activities);

    // Detailed Activities Sheet
    _createDetailedSheet(excel, activities);

    // Save file
    await _saveExcelFile(excel, user.name, context);
  }

  static void _createUserProfileSheet(
    Excel excel,
    UserModel user,
    List<DailyActivity> activities,
  ) {
    var sheet = excel['User Profile'];

    // Title
    sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue('SADHANA PROGRESS REPORT');
    sheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      backgroundColorHex: ExcelColor.blue,
    );

    // User Details
    sheet.cell(CellIndex.indexByString("A3")).value = TextCellValue('Name:');
    sheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(user.name);

    sheet.cell(CellIndex.indexByString("A4")).value = TextCellValue('Email:');
    sheet.cell(CellIndex.indexByString("B4")).value = TextCellValue(user.email);

    sheet.cell(CellIndex.indexByString("A5")).value = TextCellValue('User ID:');
    sheet.cell(CellIndex.indexByString("B5")).value = TextCellValue(user.uid);

    sheet.cell(CellIndex.indexByString("A6")).value = TextCellValue('Role:');
    sheet.cell(CellIndex.indexByString("B6")).value = TextCellValue(user.role.toUpperCase());

    // Statistics
    int totalDays = activities.length;
    double totalScore = activities.fold(0.0, (sum, a) => sum + a.totalPoints);
    double avgScore = totalDays > 0 ? totalScore / totalDays : 0;
    double avgPercentage = activities.fold(0.0, (sum, a) => sum + a.percentage) / (totalDays > 0 ? totalDays : 1);

    sheet.cell(CellIndex.indexByString("A8")).value = TextCellValue('Total Days Tracked:');
    sheet.cell(CellIndex.indexByString("B8")).value = IntCellValue(totalDays);

    sheet.cell(CellIndex.indexByString("A9")).value = TextCellValue('Average Score:');
    sheet.cell(CellIndex.indexByString("B9")).value = TextCellValue(avgScore.toStringAsFixed(1));

    sheet.cell(CellIndex.indexByString("A10")).value = TextCellValue('Average Percentage:');
    sheet.cell(CellIndex.indexByString("B10")).value = TextCellValue('${avgPercentage.toStringAsFixed(1)}%');
  }

  static void _createDailySummarySheet(Excel excel, List<DailyActivity> activities) {
    var sheet = excel['Daily Summary'];

    // Headers
    var headers = [
      'Date',
      'Nindra',
      'Wake Up',
      'Day Sleep',
      'Japa',
      'Pathan',
      'Sravan',
      'Seva',
      'Total',
      'Percentage'
    ];

    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.green);
    }

    // Data
    for (int i = 0; i < activities.length; i++) {
      var activity = activities[i];
      var row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          TextCellValue(activity.dateString);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue((activity.getActivity('nindra')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          TextCellValue((activity.getActivity('wake_up')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          TextCellValue((activity.getActivity('day_sleep')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          TextCellValue((activity.getActivity('japa')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          TextCellValue((activity.getActivity('pathan')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          TextCellValue((activity.getActivity('sravan')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          TextCellValue((activity.getActivity('seva')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value =
          TextCellValue(activity.totalPoints.toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value =
          TextCellValue('${activity.percentage.toStringAsFixed(1)}%');
    }
  }

  static void _createDetailedSheet(Excel excel, List<DailyActivity> activities) {
    var sheet = excel['Detailed Data'];

    // Headers
    var headers = [
      'Date',
      'Sleep Time',
      'Wake Time',
      'Day Sleep (min)',
      'Japa (rounds)',
      'Pathan (min)',
      'Sravan (min)',
      'Seva (hrs)',
      'Total Score'
    ];

    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.yellow);
    }

    // Data
    for (int i = 0; i < activities.length; i++) {
      var activity = activities[i];
      var row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          TextCellValue(activity.dateString);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(activity.getActivity('nindra')?.extras['value']?.toString() ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          TextCellValue(activity.getActivity('wake_up')?.extras['value']?.toString() ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          IntCellValue((activity.getActivity('day_sleep')?.extras['duration'] as num?)?.toInt() ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          IntCellValue((activity.getActivity('japa')?.extras['rounds'] as num?)?.toInt() ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          IntCellValue((activity.getActivity('pathan')?.extras['duration'] as num?)?.toInt() ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          IntCellValue((activity.getActivity('sravan')?.extras['duration'] as num?)?.toInt() ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          TextCellValue(((activity.getActivity('seva')?.extras['duration'] as num?)?.toDouble() ?? 0 / 60).toStringAsFixed(1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value =
          TextCellValue(activity.totalPoints.toStringAsFixed(1));
    }
  }

  static Future<void> _saveExcelFile(Excel excel, String userName, BuildContext context) async {
    try {
      print('📊 Starting Excel export...');
      
      // Check current permission status
      var status = await Permission.storage.status;
      print('📊 Storage permission status: $status');
      
      // If permission is denied, request it
      if (status.isDenied) {
        print('📊 Requesting storage permission...');
        
        // Show explanation dialog before requesting
        if (context.mounted) {
          final shouldRequest = await _showPermissionDialog(context);
          if (!shouldRequest) {
            print('❌ User cancelled permission request');
            return;
          }
        }
        
        status = await Permission.storage.request();
        print('📊 Permission request result: $status');
      }
      
      // If still denied, try manageExternalStorage (Android 11+)
      if (!status.isGranted && Platform.isAndroid) {
        print('📊 Trying manageExternalStorage permission...');
        final manageStatus = await Permission.manageExternalStorage.status;
        
        if (manageStatus.isDenied) {
          final granted = await Permission.manageExternalStorage.request();
          if (granted.isGranted) {
            status = granted;
          }
        } else if (manageStatus.isGranted) {
          status = manageStatus;
        }
      }
      
      // If permission is permanently denied, show settings dialog
      if (status.isPermanentlyDenied) {
        print('❌ Permission permanently denied');
        if (context.mounted) {
          await _showSettingsDialog(context);
        }
        return;
      }
      
      // If still not granted, show error
      if (!status.isGranted) {
        print('❌ Permission denied: $status');
        if (context.mounted) {
          Get.snackbar(
            'Permission Required',
            'Storage access is needed to save Excel files. Please grant permission in Settings.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
            ),
          );
        }
        return;
      }
      
      print('✅ Permission granted!');

      Directory? directory;
      if (Platform.isAndroid) {
        print('📊 Android device detected');
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          print('📊 Download folder not found, using external storage');
          directory = await getExternalStorageDirectory();
        }
      } else {
        print('📊 iOS device detected');
        directory = await getApplicationDocumentsDirectory();
      }

      print('📊 Save directory: ${directory?.path}');
      
      String fileName = 'Sadhana_Report_${userName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      String filePath = '${directory!.path}/$fileName';
      
      print('📊 File path: $filePath');

      File file = File(filePath);
      var bytes = excel.encode();
      
      if (bytes != null) {
        print('📊 Writing ${bytes.length} bytes to file...');
        await file.writeAsBytes(bytes);
        print('✅ Excel file saved successfully!');

        if (context.mounted) {
          Get.snackbar(
            'Success',
            'Excel report saved:\n$fileName',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.greenSuccess,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      } else {
        print('❌ Excel encoding returned null');
        throw Exception('Failed to encode Excel file');
      }
    } catch (e, stackTrace) {
      print('❌ Excel export error: $e');
      print('Stack trace: $stackTrace');
      
      if (context.mounted) {
        Get.snackbar(
          'Error',
          'Failed to save Excel: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  // Generate PDF Report
  static Future<void> exportToPdf(
    UserModel user,
    List<DailyActivity> activities,
    BuildContext context,
  ) async {
    final pdf = pw.Document();

    // Calculate stats
    int totalDays = activities.length;
    double totalScore = activities.fold(0.0, (sum, a) => sum + a.totalPoints);
    double avgScore = totalDays > 0 ? totalScore / totalDays : 0;
    double avgPercentage = activities.fold(0.0, (sum, a) => sum + a.percentage) / (totalDays > 0 ? totalDays : 1);

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
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Overall Stats
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('OVERALL PERFORMANCE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Total Days: $totalDays', style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('Average Score: ${avgScore.toStringAsFixed(1)}', style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('Average Percentage: ${avgPercentage.toStringAsFixed(1)}%', style: const pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary Table
              pw.Text('ACTIVITY SUMMARY', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildPdfTable(activities),
            ],
          );
        },
      ),
    );

    // Generate and show PDF
    try {
      print('📄 Generating PDF...');
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          print('📄 PDF layout callback triggered');
          return pdf.save();
        },
      );

      print('✅ PDF generated successfully!');
      
      if (context.mounted) {
        Get.snackbar(
          'Success',
          'PDF report generated and ready to save',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.greenSuccess,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e, stackTrace) {
      print('❌ PDF generation error: $e');
      print('Stack trace: $stackTrace');
      
      if (context.mounted) {
        Get.snackbar(
          'Error',
          'Failed to generate PDF: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  static pw.Widget _buildPdfTable(List<DailyActivity> activities) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildPdfCell('Date', isHeader: true),
            _buildPdfCell('Nindra', isHeader: true),
            _buildPdfCell('Japa', isHeader: true),
            _buildPdfCell('Total', isHeader: true),
            _buildPdfCell('%', isHeader: true),
          ],
        ),
        // Data rows
        ...activities.take(10).toList().map((activity) {
          return pw.TableRow(
            children: [
              _buildPdfCell(activity.dateString),
              _buildPdfCell((activity.getActivity('nindra')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1)),
              _buildPdfCell((activity.getActivity('japa')?.analytics?.pointsAchieved ?? 0).toStringAsFixed(1)),
              _buildPdfCell(activity.totalPoints.toStringAsFixed(1)),
              _buildPdfCell('${activity.percentage.toStringAsFixed(1)}%'),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
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

  // Show permission explanation dialog
  static Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storage, color: AppColors.primaryOrange),
            SizedBox(width: 12),
            Text('Storage Permission'),
          ],
        ),
        content: const Text(
          'This app needs storage access to save Excel reports to your Downloads folder.\n\n'
          'Your data will only be saved locally on your device.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Show settings dialog for permanently denied permissions
  static Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.orange),
            SizedBox(width: 12),
            Text('Permission Needed'),
          ],
        ),
        content: const Text(
          'Storage permission has been denied. To save Excel reports, please:\n\n'
          '1. Tap "Open Settings" below\n'
          '2. Go to Permissions\n'
          '3. Enable Storage/Files permission',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
