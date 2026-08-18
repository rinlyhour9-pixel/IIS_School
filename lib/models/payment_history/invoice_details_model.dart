class ParentInvoiceDetailsResponse {
  final bool success;
  final String message;
  final ParentInvoiceDetailsData data;

  ParentInvoiceDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ParentInvoiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ParentInvoiceDetailsResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: ParentInvoiceDetailsData.fromJson(
        Map<String, dynamic>.from(json['data'] ?? const <String, dynamic>{}),
      ),
    );
  }
}

class ParentInvoiceDetailsData {
  final ParentInvoiceStudent student;
  final ParentInvoice invoice;
  final List<ParentInvoiceLine> details;

  ParentInvoiceDetailsData({
    required this.student,
    required this.invoice,
    required this.details,
  });

  factory ParentInvoiceDetailsData.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'] as List? ?? const <dynamic>[];
    return ParentInvoiceDetailsData(
      student: ParentInvoiceStudent.fromJson(
        Map<String, dynamic>.from(json['student'] ?? const <String, dynamic>{}),
      ),
      invoice: ParentInvoice.fromJson(
        Map<String, dynamic>.from(json['invoice'] ?? const <String, dynamic>{}),
      ),
      details:
          rawDetails
              .whereType<dynamic>()
              .map((e) => ParentInvoiceLine.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
    );
  }
}

class ParentInvoiceStudent {
  final int id;
  final String nameEn;
  final String nameKh;

  ParentInvoiceStudent({
    required this.id,
    required this.nameEn,
    required this.nameKh,
  });

  factory ParentInvoiceStudent.fromJson(Map<String, dynamic> json) {
    return ParentInvoiceStudent(
      id: _toInt(json['id']) ?? 0,
      nameEn: (json['name_en'] ?? '').toString(),
      nameKh: (json['name_kh'] ?? '').toString(),
    );
  }
}

class ParentInvoice {
  final String invoiceNo;
  final String subtotal;
  final String discountAmount;
  final String grandTotal;
  final String amountPaid;
  final String dueAmount;
  final String paymentDate;

  ParentInvoice({
    required this.invoiceNo,
    required this.subtotal,
    required this.discountAmount,
    required this.grandTotal,
    required this.amountPaid,
    required this.dueAmount,
    required this.paymentDate,
  });

  factory ParentInvoice.fromJson(Map<String, dynamic> json) {
    return ParentInvoice(
      invoiceNo: (json['invoice_no'] ?? '').toString(),
      subtotal: (json['subtotal'] ?? '0.00').toString(),
      discountAmount: (json['discount_amount'] ?? '0.00').toString(),
      grandTotal: (json['grand_total'] ?? '0.00').toString(),
      amountPaid: (json['amount_paid'] ?? '0.00').toString(),
      dueAmount: (json['due_amount'] ?? '0.00').toString(),
      paymentDate: (json['payment_date'] ?? '').toString(),
    );
  }
}

class ParentInvoiceLine {
  final String itemName;
  final String feetype;
  final String qty;
  final String unitPrice;
  final String amount;
  final String dueDate;
  final String paidDate;

  ParentInvoiceLine({
    required this.itemName,
    required this.feetype,
    required this.qty,
    required this.unitPrice,
    required this.amount,
    required this.dueDate,
    required this.paidDate,
  });

  factory ParentInvoiceLine.fromJson(Map<String, dynamic> json) {
    return ParentInvoiceLine(
      itemName: (json['item_name'] ?? '').toString(),
      feetype: (json['feetype'] ?? '').toString(),
      qty: (json['qty'] ?? '').toString(),
      unitPrice: (json['unit_price'] ?? '0.00').toString(),
      amount: (json['amount'] ?? '0.00').toString(),
      dueDate: (json['due_date'] ?? '').toString(),
      paidDate: (json['paid_date'] ?? '').toString(),
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value.trim());
  return null;
}
