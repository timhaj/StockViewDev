import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Expanded(child: Text(change_p)),
          Expanded(child: Text(price)),
        ],
      ),
    );
  }
}
