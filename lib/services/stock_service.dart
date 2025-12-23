import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  // Get free API key from https://www.alphavantage.co/support/#api-key
  static const String apiKey = 'MNYCLFYXDYEMG7FV';

  static Future<List<StockDataPoint>> fetchSP500Data() async {
    final url = Uri.parse(
      'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=SPY&apikey=$apiKey'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timeSeries = data['Time Series (Daily)'] as Map<String, dynamic>;

        // Get last 30 days
        final points = timeSeries.entries
            .take(100)
            .map((e) => StockDataPoint(
                  date: DateTime.parse(e.key),
                  price: double.parse(e.value['4. close']),
                ))
            .toList()
            .reversed
            .toList();

        return points;
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return [];
  }
}

class StockDataPoint {
  final DateTime date;
  final double price;

  StockDataPoint({required this.date, required this.price});
}

