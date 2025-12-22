import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

class FinnhubService {
  final String apiKey = 'd54q2p9r01qojbigp750d54q2p9r01qojbigp75g';

  Future<Stock> getStockQuote(String symbol) async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // preveri vse potrebne polje
      if (data.isEmpty || data['c'] == null) {
        throw Exception('No quote data returned for $symbol');
      }

      return Stock(
        symbol: symbol,
        price: data['c'].toStringAsFixed(2),      // double → string z 2 decimalkama
        change_p: data['dp'].toStringAsFixed(2) + '%', // dnevna % sprememba kot string
      );
    } else {
      throw Exception('Failed to load stock data for $symbol');
    }
  }
}
