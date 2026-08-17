import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/scheme_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../data/models/activity.dart';
import '../../data/models/address.dart';
import '../../data/models/order.dart';
import '../../data/models/scheme.dart';
import '../../data/repositories/catalog_repository.dart';
import 'money.dart';

class TransactionInvoice {
  const TransactionInvoice._();

  static Future<void> download(CustomerTransaction transaction) async {
    try {
      final bytes = await build(transaction);
      final filename = _fileName(transaction);
      final file = File('${(await getTemporaryDirectory()).path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      final origin = _shareOrigin();
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: filename)],
        subject: filename,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      Get.showSnackbar(
        GetSnackBar(
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 88),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          borderRadius: 20,
          backgroundColor: const Color(0xFF211D18),
          messageText: Text(
            'Could not prepare the invoice. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }
  }

  static Future<Uint8List> build(CustomerTransaction transaction) async {
    final auth = Get.find<AuthController>();
    final profile = auth.profile.value;
    final user = auth.user.value;
    final rawName = (profile?.displayName ?? user?.name ?? '').trim();
    final customerName = rawName.isEmpty ? 'Customer' : rawName;
    final customerPhone = (profile?.phone ?? user?.phone ?? '').trim();

    JewelleryOrder? order;
    final orderId = transaction.orderId?.trim();
    if (transaction.isShopping && orderId != null && orderId.isNotEmpty) {
      if (Get.isRegistered<ShopController>()) {
        order = Get.find<ShopController>().orderById(orderId);
      }
      if (order == null && Get.isRegistered<CatalogRepository>()) {
        try {
          order = await Get.find<CatalogRepository>().fetchOrder(orderId);
        } catch (_) {}
      }
    }

    SchemeEnrollment? enrollment;
    final enrollmentId = transaction.enrollmentId?.trim();
    if (enrollmentId != null && enrollmentId.isNotEmpty) {
      enrollment = Get.find<SchemeController>().enrollmentById(enrollmentId);
    }

    Address? address = order?.address ??
        profile?.defaultAddress ??
        (profile != null && profile.savedAddresses.isNotEmpty
            ? profile.savedAddresses.first
            : null);

    pw.MemoryImage? logo;
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {}

    final gold = PdfColor.fromInt(0xFFB97911);
    final goldDark = PdfColor.fromInt(0xFF8D5908);
    final cream = PdfColor.fromInt(0xFFFBF4E8);
    final ink = PdfColor.fromInt(0xFF171512);
    final muted = PdfColor.fromInt(0xFF6F685E);
    final line = PdfColor.fromInt(0xFFECE3D7);

    final invoiceNo = _invoiceNumber(transaction);
    final issued = _fullDate(transaction.date ?? order?.createdAt);
    final kind = transaction.isShopping ? 'Jewellery order' : 'Gold scheme';
    final lines = _lines(transaction, order);
    final gstPaise = order?.gstPaise ?? 0;
    final subtotalPaise = order?.subtotalPaise ??
        (gstPaise > 0 ? transaction.amountPaise - gstPaise : null);
    final totalPaise = order?.totalPaise ?? transaction.amountPaise;

    final doc = pw.Document(
      title: 'Wavoo invoice $invoiceNo',
      author: 'Wavoo Jewellers',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 36),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 54,
                  height: 54,
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: cream,
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(color: gold, width: 0.8),
                  ),
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 12),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'WAVOO JEWELLERS',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: goldDark,
                        letterSpacing: 0.6,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Fine jewellery',
                      style: pw.TextStyle(fontSize: 10, color: muted),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '+91 89251 62888  ·  wavoojewellers@yahoo.com',
                      style: pw.TextStyle(fontSize: 9, color: muted),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      color: cream,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: gold, width: 0.8),
                    ),
                    child: pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: goldDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    invoiceNo,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    issued,
                    style: pw.TextStyle(fontSize: 9, color: muted),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(height: 2, color: gold),
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _box(
                  title: 'Billed to',
                  gold: gold,
                  cream: cream,
                  ink: ink,
                  muted: muted,
                  children: [
                    pw.Text(
                      customerName,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    if (customerPhone.isNotEmpty)
                      pw.Text(
                        customerPhone,
                        style: pw.TextStyle(fontSize: 9, color: muted),
                      ),
                    if (address != null && address.streetLine.isNotEmpty)
                      pw.Text(
                        address.streetLine,
                        style: pw.TextStyle(fontSize: 9, color: muted),
                      ),
                    if (address != null && address.localityLine.isNotEmpty)
                      pw.Text(
                        address.localityLine,
                        style: pw.TextStyle(fontSize: 9, color: muted),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _box(
                  title: 'Transaction',
                  gold: gold,
                  cream: cream,
                  ink: ink,
                  muted: muted,
                  children: [
                    _kv('Type', kind, ink, muted),
                    _kv('Status', transaction.status.toUpperCase(), ink, muted),
                    if ((transaction.orderNumber ?? '').trim().isNotEmpty)
                      _kv('Order', transaction.orderNumber!.trim(), ink, muted),
                    if ((transaction.enrollmentNumber ?? '').trim().isNotEmpty)
                      _kv(
                        'Scheme',
                        transaction.enrollmentNumber!.trim(),
                        ink,
                        muted,
                      )
                    else if ((enrollment?.enrollmentNumber ?? '')
                        .trim()
                        .isNotEmpty)
                      _kv(
                        'Scheme',
                        enrollment!.enrollmentNumber.trim(),
                        ink,
                        muted,
                      ),
                    if (transaction.sequenceNumber != null)
                      _kv(
                        'Installment',
                        '${transaction.sequenceNumber}',
                        ink,
                        muted,
                      ),
                    if ((transaction.receiptNumber ?? '').trim().isNotEmpty)
                      _kv(
                        'Receipt',
                        transaction.receiptNumber!.trim(),
                        ink,
                        muted,
                      ),
                    if (order != null &&
                        (order.paymentMethod ?? '').trim().isNotEmpty)
                      _kv(
                        'Payment',
                        order.paymentMethodLabel,
                        ink,
                        muted,
                      ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Table(
            border: pw.TableBorder.all(color: line, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(4.2),
              1: pw.FlexColumnWidth(0.8),
              2: pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: cream),
                children: [
                  _th('Description', goldDark),
                  _th('Qty', goldDark, align: pw.TextAlign.center),
                  _th('Amount', goldDark, align: pw.TextAlign.right),
                ],
              ),
              for (final line in lines)
                pw.TableRow(
                  children: [
                    _td(
                      [
                        line.label,
                        if (line.detail != null && line.detail!.isNotEmpty)
                          line.detail!,
                      ].join('\n'),
                      ink,
                    ),
                    _td('${line.quantity}', ink, align: pw.TextAlign.center),
                    _td(_rs(line.amountPaise), ink, align: pw.TextAlign.right),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 230,
              child: pw.Column(
                children: [
                  if (subtotalPaise != null && subtotalPaise > 0)
                    _totalRow('Subtotal', _rs(subtotalPaise), ink, muted),
                  if (gstPaise > 0)
                    _totalRow('GST', _rs(gstPaise), ink, muted),
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 4),
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: cream,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: gold, width: 0.8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: goldDark,
                          ),
                        ),
                        pw.Text(
                          _rs(totalPaise),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: goldDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (order != null &&
              order.lines.isNotEmpty &&
              transaction.detail.trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Notes',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: muted,
                letterSpacing: 0.6,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              transaction.detail.trim(),
              style: pw.TextStyle(fontSize: 9, color: ink),
            ),
          ],
          pw.SizedBox(height: 28),
          pw.Divider(color: line),
          pw.SizedBox(height: 8),
          pw.Text(
            'This is a computer-generated invoice from Wavoo Jewellers and does not require a signature.',
            style: pw.TextStyle(fontSize: 8, color: muted),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Thank you for choosing Wavoo.',
            style: pw.TextStyle(fontSize: 8, color: muted),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static Rect? _shareOrigin() {
    final box = Get.overlayContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  static pw.Widget _box({
    required String title,
    required PdfColor gold,
    required PdfColor cream,
    required PdfColor ink,
    required PdfColor muted,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: cream,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: gold, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: muted,
              letterSpacing: 0.7,
            ),
          ),
          pw.SizedBox(height: 6),
          ..._spaced(children),
        ],
      ),
    );
  }

  static List<pw.Widget> _spaced(List<pw.Widget> children) {
    final out = <pw.Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) out.add(pw.SizedBox(height: 3));
      out.add(children[i]);
    }
    return out;
  }

  static pw.Widget _kv(
    String label,
    String value,
    PdfColor ink,
    PdfColor muted,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 72,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, color: muted),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _th(
    String text,
    PdfColor color, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _td(
    String text,
    PdfColor color, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 9, color: color),
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value,
    PdfColor ink,
    PdfColor muted,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: muted)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }

  static List<_InvoiceLine> _lines(
    CustomerTransaction transaction,
    JewelleryOrder? order,
  ) {
    if (order != null && order.lines.isNotEmpty) {
      return [
        for (final line in order.lines)
          _InvoiceLine(
            label: line.name,
            detail: [
              if ((line.purityLabel ?? '').trim().isNotEmpty) line.purityLabel,
            ].join(),
            quantity: line.quantity,
            amountPaise: line.lineTotalPaise,
          ),
      ];
    }
    return [
      _InvoiceLine(
        label: transaction.title,
        detail: transaction.detail.trim().isEmpty ? null : transaction.detail,
        quantity: transaction.itemCount ?? 1,
        amountPaise: transaction.amountPaise,
      ),
    ];
  }

  static String _invoiceNumber(CustomerTransaction transaction) {
    for (final value in [
      transaction.receiptNumber,
      transaction.orderNumber,
      transaction.enrollmentNumber,
    ]) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    final id = transaction.id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final suffix = id.length > 8 ? id.substring(id.length - 8) : id;
    return suffix.isEmpty ? 'WAV-INV' : 'WAV-$suffix';
  }

  static String _fileName(CustomerTransaction transaction) {
    final raw = _invoiceNumber(transaction)
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');
    return 'Wavoo-Invoice-$raw.pdf';
  }

  static String _fullDate(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$minute $suffix';
  }

  static String _rs(int paise) {
    final formatted = Money.fromPaise(paise);
    if (formatted.startsWith('₹')) {
      return 'Rs. ${formatted.substring(1)}';
    }
    return formatted;
  }
}

class _InvoiceLine {
  const _InvoiceLine({
    required this.label,
    required this.quantity,
    required this.amountPaise,
    this.detail,
  });

  final String label;
  final String? detail;
  final int quantity;
  final int amountPaise;
}
