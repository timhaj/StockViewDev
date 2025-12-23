import 'package:flutter/material.dart';
import '../screens/stock_detail_screen.dart';

class StockRow extends StatelessWidget {
  final String name;
  final String change_p;
  final String price;

  const StockRow({
    super.key,
    required this.name,
    required this.change_p,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockDetailScreen(symbol: name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(name)),
            Expanded(child: Text(change_p)),
            Expanded(child: Text(price)),
          ],
        ),
      ),
    );
  }
}
