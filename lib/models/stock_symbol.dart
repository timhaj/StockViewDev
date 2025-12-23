class StockSymbol {
  final String displaySymbol;
  final String description;

  StockSymbol({
    required this.displaySymbol,
    required this.description,
  });

  factory StockSymbol.fromJson(Map<String, dynamic> json) {
    return StockSymbol(
      displaySymbol: json['displaySymbol'],
      description: json['description'] ?? '',
    );
  }
}
