class PaymentModel {
  final String name;
  final String phone;
  final String tranId;
  final num total;
  final num amountUs;
  final num amountKh;
  final String verifyBy;
  final String codDate;

  PaymentModel({
    required this.name,
    required this.phone,
    required this.tranId,
    required this.total,
    required this.amountUs,
    required this.amountKh,
    required this.verifyBy,
    required this.codDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      name: json['name'] ?? json['delivery_name'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      tranId: json['tran_id'] ?? 'N/A',
      total: json['total'] ?? 0.0,
      amountUs: json['amount_us'] ?? 0.0,
      amountKh: json['amount_kh'] ?? 0.0,
      verifyBy: json['verify_by'] ?? 'N/A',
      codDate: json['cod_date'] ?? 'N/A',
    );
  }
}
