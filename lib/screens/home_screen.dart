import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/stock_symbol.dart';
import '../services/finhub_service.dart';
import '../services/stock_service.dart';
import '../widgets/stock_row.dart';
import '../widgets/sp500_chart.dart';
import '../widgets/market_selector.dart';
import 'search_screen.dart';
import 'calendar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMarket = 'US';
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
            MarketSelector(
              onMarketChanged: (market) {
                setState(() {
                  selectedMarket = market;
                });
              },
            ),
          const SizedBox(height: 12),
          
         Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FutureBuilder<MarketData>(
              key: ValueKey(selectedMarket),
              future: StockService.fetchMarketData(selectedMarket),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.points.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Unable to load data'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SP500Chart(
                    data: snapshot.data!.points,
                    currency: snapshot.data!.currency, // Pass currency
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 📊 Table header
          Row(
              children: const [
                // Stock - levo
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Stock',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Change % daily - sredina
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Change % daily',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Price / Share - desno
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Price / Share',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
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

     

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Home - trenutno ostani na tem screen-u
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
              break;
            case 2:
              /*
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WatchlistScreen()),
              );
              break;
              */
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EarningsCalendarScreen()),
              );
              break;
              
            case 4:
              /*
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              break;
              */
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
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
