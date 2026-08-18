class DashboardModel {
  final dynamic totalPackage;
  final String totalAmount;
  final String extraAmountTaxi;
  final String commissionFee;
  final String totalPackageAllInStock;
  final String codAmountUsd;
  final String codAmountKhr;
  final num isProblem;
  final num rating;

  DashboardModel({
    required this.totalPackage,
    required this.totalAmount,
    required this.extraAmountTaxi,
    required this.commissionFee,
    required this.totalPackageAllInStock,
    required this.codAmountUsd,
    required this.codAmountKhr,
    required this.isProblem,
    required this.rating,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalPackage: json['total_package'] ?? 0,
      totalAmount: json['total_amount'] ?? '0.0',
      extraAmountTaxi: json['extra_amount_taxi'] ?? '0.0',
      commissionFee: json['commission_fee'] ?? '0.0',
      totalPackageAllInStock: json['total_package_all_in_stock'] ?? '0.0',
      codAmountUsd: json['cod_amount_usd'] ?? '0.0',
      codAmountKhr: json['cod_amount_khr'] ?? '0.0',
      isProblem: json['is_problem'] ?? 0,
      rating: json['kh_amount'] ?? 0,
    );
  }
}
