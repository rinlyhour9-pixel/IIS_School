class PaymentHistoryResponse {
  final bool success;
  final String message;
  final PaymentHistoryPage data;

  PaymentHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: PaymentHistoryPage.fromJson(
        Map<String, dynamic>.from(json['data'] ?? const <String, dynamic>{}),
      ),
    );
  }
}

class PaymentHistoryPage {
  final int currentPage;
  final List<PaymentHistoryItem> items;
  final int lastPage;
  final int total;

  PaymentHistoryPage({
    required this.currentPage,
    required this.items,
    required this.lastPage,
    required this.total,
  });

  factory PaymentHistoryPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['data'];
    final itemList =
        (rawItems is List ? rawItems : const <dynamic>[])
            .whereType<dynamic>()
            .map((e) => PaymentHistoryItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();

    return PaymentHistoryPage(
      currentPage: _toInt(json['current_page']) ?? 1,
      items: itemList,
      lastPage: _toInt(json['last_page']) ?? 1,
      total: _toInt(json['total']) ?? itemList.length,
    );
  }
}

class PaymentHistoryItem {
  final int id;
  final int studentId;
  final String invoiceNo;
  final String subtotal;
  final String grandTotal;
  final String discountAmount;
  final String dueAmount;
  final String amountPaid;
  final String paymentDate;
  final String studentName;
  final String studentNameKh;

  PaymentHistoryItem({
    required this.id,
    required this.studentId,
    required this.invoiceNo,
    required this.subtotal,
    required this.grandTotal,
    required this.discountAmount,
    required this.dueAmount,
    required this.amountPaid,
    required this.paymentDate,
    required this.studentName,
    required this.studentNameKh,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    final student = Map<String, dynamic>.from(
      json['student'] ?? const <String, dynamic>{},
    );
    final firstName = (student['firstname'] ?? '').toString().trim();
    final lastName = (student['lastname'] ?? '').toString().trim();
    final firstNameKh = (student['firstnamekh'] ?? '').toString().trim();
    final lastNameKh = (student['lastnamekh'] ?? '').toString().trim();

    return PaymentHistoryItem(
      id: _toInt(json['id']) ?? 0,
      studentId: _toInt(json['student_id']) ?? 0,
      invoiceNo: (json['invoice_no'] ?? '').toString(),
      subtotal: (json['subtotal'] ?? '0.00').toString(),
      grandTotal: (json['grand_total'] ?? '0.00').toString(),
      discountAmount: (json['discount_amount'] ?? '0.00').toString(),
      dueAmount: (json['due_amount'] ?? '0.00').toString(),
      amountPaid: (json['amount_paid'] ?? '0.00').toString(),
      paymentDate: (json['payment_date'] ?? '').toString(),
      studentName: _joinName(firstName, lastName),
      studentNameKh: _joinName(firstNameKh, lastNameKh),
    );
  }

  String get displayStudentName {
    final khName = studentNameKh.trim();
    if (khName.isNotEmpty) return khName;

    final name = studentName.trim();
    if (name.isNotEmpty) return name;

    return studentId > 0 ? 'Student #$studentId' : 'Student';
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String _joinName(String firstName, String lastName) {
  return [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
}
