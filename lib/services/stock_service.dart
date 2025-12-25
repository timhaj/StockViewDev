import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  static const Map<String, Map<String, String>> marketInfo = {
    'US': {'symbol': '^GSPC', 'currency': '\$'},
    'EU': {'symbol': '^STOXX50E', 'currency': '€'},
    'JP': {'symbol': '^N225', 'currency': '¥'},
  };
  
  static Future<MarketData> fetchMarketData(String market, {int days = 100}) async {
    final symbol;
    final currency;

    if (market == "US" || market == "EU" || market == "JP"){
        final info = marketInfo[market] ?? marketInfo['US']!;
        symbol = info['symbol']!;
        currency = info['currency']!;
    }else{
      symbol = market;
      currency = '\$';
    }
    
    
    final endDate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final startDate = DateTime.now().subtract(Duration(days: days + 10)).millisecondsSinceEpoch ~/ 1000;
    
    final url = Uri.parse(
      'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?period1=$startDate&period2=$endDate&interval=1d'
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timestamps = List<int>.from(data['chart']['result'][0]['timestamp']);
        final prices = List<double>.from(
          data['chart']['result'][0]['indicators']['quote'][0]['close'].map((e) => e?.toDouble() ?? 0.0)
        );
        
        final points = <StockDataPoint>[];
        for (int i = 0; i < timestamps.length && i < prices.length; i++) {
          if (prices[i] > 0) {
            points.add(StockDataPoint(
              date: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
              price: prices[i],
            ));
          }
        }
        
        return MarketData(
          points: points.take(days).toList(),
          currency: currency,
        );
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return MarketData(points: [], currency: currency);
  }
}

class StockDataPoint {
  final DateTime date;
  final double price;
  
  StockDataPoint({required this.date, required this.price});
}

class MarketData {
  final List<StockDataPoint> points;
  final String currency;
  
  MarketData({required this.points, required this.currency});
}