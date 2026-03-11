class Holding {
  final String id;
  final String portfolioId;
  final String companyName;
  final int numberOfShares;
  final double? purchasePrice;
  final DateTime createdAt;

  const Holding({
    required this.id,
    required this.portfolioId,
    required this.companyName,
    required this.numberOfShares,
    this.purchasePrice,
    required this.createdAt,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      id: json['id'] as String,
      portfolioId: json['portfolio_id'] as String,
      companyName: json['company_name'] as String,
      numberOfShares: json['number_of_shares'] as int,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portfolio_id': portfolioId,
      'company_name': companyName,
      'number_of_shares': numberOfShares,
      'purchase_price': purchasePrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
