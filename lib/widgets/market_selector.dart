import 'package:flutter/material.dart';

class MarketSelector extends StatefulWidget {
  final Function(String) onMarketChanged;
  
  const MarketSelector({Key? key, required this.onMarketChanged}) : super(key: key);

  @override
  State<MarketSelector> createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector> {
  String selectedMarket = 'US';
  
  final List<Map<String, String>> markets = [
    {'code': 'US', 'name': 'American', 'ticker': 'GSPC'},
    {'code': 'EU', 'name': 'European', 'ticker': 'STOXX50E'},
    {'code': 'JP', 'name': 'Japanese', 'ticker': 'N225'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: markets.map((market) {
        final isSelected = selectedMarket == market['code'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMarket = market['code']!;
                });
                widget.onMarketChanged(market['code']!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                elevation: isSelected ? 2 : 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
                            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    market['ticker']!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    market['name']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}