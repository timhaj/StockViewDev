import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/stock_symbol.dart';

class FinnhubService {
  final String apiKey = 'd54q2p9r01qojbigp750d54q2p9r01qojbigp75g';

  // ================= STOCK QUOTE =================
  Future<Stock> getStockQuote(String symbol) async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.isEmpty || data['c'] == null) {
        throw Exception('No quote data returned for $symbol');
      }

      return Stock(
        symbol: symbol,
        price: data['c'].toStringAsFixed(2),
        change_p: data['dp'].toStringAsFixed(2) + '%',
      );
    } else {
      throw Exception('Failed to load stock data for $symbol');
    }
  }

  // ================= US SYMBOLS =================
  Future<List<StockSymbol>> fetchUsSymbols() async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/stock/symbol?exchange=US&token=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => StockSymbol.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load symbols');
    }
  }

  // ================= COMPANY PROFILE =================
  Future<Map<String, dynamic>> getCompanyProfile(String symbol) async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/stock/profile2?symbol=$symbol&token=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load company profile');
    }
  }

  // ================= FINANCIALS REPORTED =================
  Future<Map<String, dynamic>> getFinancialsReported(String symbol) async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/stock/financials-reported?symbol=$symbol&token=$apiKey'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load financials reported for $symbol');
    }
  }

  // ================= INSIDER TRANSACTIONS =================
  Future<List<dynamic>> getInsiderTransactions(String symbol) async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/stock/insider-transactions?symbol=$symbol&token=$apiKey'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load insider transactions for $symbol');
    }
  }

  // ================= COMPANY BASIC FINANCIALS =================
  Future<Map<String, dynamic>> getCompanyBasicFinancials(String symbol, {String metric = 'all'}) async {
    final url = Uri.parse(
      'https://finnhub.io/api/v1/stock/metric?symbol=$symbol&metric=$metric&token=$apiKey'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load company basic financials for $symbol');
    }
  }

  // ================= EARNINGS CALENDAR =================
  Future<List<dynamic>> getEarningsCalendar({required String from, required String to}) async {
    // format datuma: yyyy-mm-dd
    final url = Uri.parse(
      'https://finnhub.io/api/v1/calendar/earnings?from=$from&to=$to&token=$apiKey'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['earningsCalendar'] ?? [];
    } else {
      throw Exception('Failed to load earnings calendar');
    }
  }
}
