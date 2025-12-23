import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/stock_symbol.dart';
import '../services/finhub_service.dart';
import '../widgets/stock_row.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller = TextEditingController();
  final FinnhubService _finService = FinnhubService();

  Stock? result;
  bool isLoading = false;
  String? error;

  List<StockSymbol> allSymbols = [];
  bool symbolsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSymbols();
  }

  Future<void> _loadSymbols() async {
    try {
      final symbols = await _finService.fetchUsSymbols();
      setState(() {
        allSymbols = symbols;
        symbolsLoading = false;
      });
    } catch (e) {
      print('Error loading symbols: $e');
    }
  }
  
  Future<void> _search() async {
    final ticker = _controller.text.trim().toUpperCase();
    if (ticker.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
      result = null;
    });

    try {
      final stock = await _finService.getStockQuote(ticker);
      setState(() {
        result = stock;
      });
    } catch (e) {
      setState(() {
        error = 'Ticker not found';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ⏳ Loader za simbole
            if (symbolsLoading)
              const CircularProgressIndicator()
            else
              Autocomplete<StockSymbol>(
                optionsBuilder: (value) {
                  if (value.text.isEmpty) {
                    return const Iterable<StockSymbol>.empty();
                  }
                  final query = value.text.toUpperCase();
                  return allSymbols
                      .where((s) => s.displaySymbol.startsWith(query))
                      .take(10);
                },
                displayStringForOption: (option) =>
                    '${option.displaySymbol} – ${option.description}',
                onSelected: (selection) {
                  _controller.text = selection.displaySymbol;
                  _search();
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  _controller = controller;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Search ticker',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  );
                },
              ),

            const SizedBox(height: 16),

            if (isLoading) const CircularProgressIndicator(),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            if (result != null)
              StockRow(
                name: result!.symbol,
                change_p: result!.change_p,
                price: '\$${result!.price}',
              ),
          ],
        ),
      ),
    );
  }
}
