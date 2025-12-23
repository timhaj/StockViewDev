import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/stock_symbol.dart';
import '../services/finhub_service.dart';
import '../widgets/stock_row.dart';
import 'search_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FinnhubService _FinService = FinnhubService();
  List<Stock> stocks = [];
  bool isLoading = true;

  // Seznam delnic za primer
  final List<String> symbols = [
  'AAPL',   // Apple
  'MSFT',   // Microsoft
  'GOOGL',  // Alphabet / Google
  'AMZN',   // Amazon
  'TSLA',   // Tesla
  'META',   // Meta / Facebook
  'NVDA',   // Nvidia
  'BRK.B',  // Berkshire Hathaway
  'JPM',    // JP Morgan
  'V',      // Visa
  'JNJ',    // Johnson & Johnson
  'WMT',    // Walmart
  'PG',     // Procter & Gamble
  'DIS',    // Disney
  'NFLX',   // Netflix
  'AKRBF',
  'EQNR',
  'VT'
  ];
  late List<StockSymbol> allSymbols;

  @override
  void initState() {
    super.initState();
    _loadSymbols();
    _fetchStocks();
  }

  Future<void> _loadSymbols() async {
    allSymbols = await _FinService.fetchUsSymbols();
  }

  Future<void> _fetchStocks() async {
    List<Stock> fetchedStocks = [];

    for (String symbol in symbols) {
      try {
        Stock stock = await _FinService.getStockQuote(symbol);
        fetchedStocks.add(stock);
      } catch (e) {
        print('Error fetching $symbol: $e');
      }
    }

    setState(() {
      stocks = fetchedStocks;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockView'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 📈 Graph placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Graph will be here')),
            ),

            const SizedBox(height: 16),

            // 📊 Table header
            Row(
              children: const [
                Expanded(child: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Change % daily', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Price / Share', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),

            const Divider(),

            // 📋 Table content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: stocks.length,
                      itemBuilder: (context, index) {
                        final stock = stocks[index];
                        return StockRow(
                          name: stock.symbol,
                          change_p: stock.change_p,
                          price: '\$${stock.price}',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ⬇️ Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),   // lupa za Search
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),     // seznam za Watchlist
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
