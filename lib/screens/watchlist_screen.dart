import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/finhub_service.dart';
import '../models/stock.dart';
import '../widgets/stock_row.dart';
import 'login_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FinnhubService _finService = FinnhubService();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  List<String> _watchlist = [];
  Map<String, Stock> _stocks = {};

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final loggedIn = await AuthService.isLoggedIn();
    
    if (!loggedIn) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoggedIn = true;
    });

    await _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() {
      _isLoading = true;
    });

    final watchlist = await AuthService.getWatchlist();
    final stocks = <String, Stock>{};

    for (String ticker in watchlist) {
      try {
        final stock = await _finService.getStockQuote(ticker);
        stocks[ticker] = stock;
      } catch (e) {
        print('Error loading $ticker: $e');
      }
    }

    setState(() {
      _watchlist = watchlist;
      _stocks = stocks;
      _isLoading = false;
    });
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    
    if (result == true) {
      _checkAuthAndLoad();
    }
  }

  Future<void> _removeFromWatchlist(String ticker) async {
    await AuthService.removeFromWatchlist(ticker);
    _loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    // Not logged in - redirect to login
    if (!_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Watchlist')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Login Required',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please login to access your watchlist',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Login / Register',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Logged in - show watchlist
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _watchlist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.list_alt,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your watchlist is empty',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add stocks from the detail page',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Table header
                      Row(
                        children: const [
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
                          SizedBox(width: 40), // Space for delete button
                        ],
                      ),
                      const Divider(),
                      
                      // Stock list
                      Expanded(
                        child: ListView.builder(
                          itemCount: _watchlist.length,
                          itemBuilder: (context, index) {
                            final ticker = _watchlist[index];
                            final stock = _stocks[ticker];

                            if (stock == null) {
                              return ListTile(
                                title: Text(ticker),
                                trailing: const CircularProgressIndicator(),
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: StockRow(
                                    name: stock.symbol,
                                    change_p: stock.change_p,
                                    price: '\$${stock.price}',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Remove from Watchlist'),
                                        content: Text('Remove $ticker from your watchlist?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _removeFromWatchlist(ticker);
                                            },
                                            child: const Text('Remove'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}