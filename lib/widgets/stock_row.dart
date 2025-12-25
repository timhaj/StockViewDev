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
    final bool isNegative = change_p.trim().startsWith('-');

    final Color changeColor = isNegative ? Colors.red : Colors.green;
    final IconData changeIcon =
        isNegative ? Icons.arrow_downward : Icons.arrow_upward;

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
            // 🏷 Ticker
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

            // 🔴🟢 Change %
            Expanded(
              child: Row(
                children: [
                  Icon(
                    changeIcon,
                    size: 16,
                    color: changeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    change_p,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 💲 Price
            Expanded(
              child: Text(
                price,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}