import 'package:schoolapp/models/models.dart';

class PaymentDetailsModel {
  final SummaryModel? summary;
  final List<DetailsModel> details;

  PaymentDetailsModel({required this.details, this.summary});

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      summary:
          json['summary'] != null
              ? SummaryModel.fromJson(json['summary'])
              : null,
      details:
          json['detail'] != null
              ? (json['detail'] as List)
                  .map((e) => DetailsModel.fromJson(e))
                  .toList()
              : <DetailsModel>[],
    );
  }
}

class SummaryModel {
  final num amountVerifyUs;
  final num amountVerifyKh;
  final String paymentMethod;
  final num extraAmountaxi;
  final num totalAmount;
  final String paymentDate;
  final num? totalCod;

  SummaryModel({
    required this.amountVerifyUs,
    required this.amountVerifyKh,
    required this.paymentMethod,
    required this.extraAmountaxi,
    required this.totalAmount,
    required this.paymentDate,
    this.totalCod,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      amountVerifyUs: json['amount_verify_us'] ?? 0.0,
      amountVerifyKh: json['amount_verify_kh'] ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'N/A',
      extraAmountaxi: json['extra_amount_taxi'] ?? 0.0,
      totalAmount: json['total_amount'] ?? 0.0,
      paymentDate: (json['payment_date'] ?? 'N/A').split(' ')[0],
      totalCod: json['total_cod'] ?? 0,
    );
  }
}
