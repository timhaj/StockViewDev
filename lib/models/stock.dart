class Stock {
  final String symbol;
  final String price;
  final String change_p;

  Stock({
    required this.symbol,
    required this.price,
    required this.change_p,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      price: (json['c'] ?? 0).toStringAsFixed(2),         // Finnhub 'c' -> string
      change_p: (json['dp'] ?? 0).toStringAsFixed(2) + '%', // Finnhub 'dp' -> string z %
    );
  }
}
