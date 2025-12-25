import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/stock_service.dart';
import 'package:intl/intl.dart';

class SP500Chart extends StatelessWidget {
  final List<StockDataPoint> data;
  final String currency; // Add this
  
  const SP500Chart({
    Key? key, 
    required this.data,
    this.currency = '\$', // Default to dollar
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();
    
    final minPrice = data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        



        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: (maxPrice - minPrice) / 4,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '$currency${value.toStringAsFixed(0)}', // Use currency here
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
                    bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (data.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length || value < 0) {
                  return const SizedBox.shrink();
                }
                final date = data[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('M/d').format(date),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minPrice * 0.99,
        maxY: maxPrice * 1.01,

                lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= data.length) return null;
                
                final dataPoint = data[index];
                final dateStr = DateFormat('MMM d, yyyy').format(dataPoint.date);
                final priceStr = '$currency${dataPoint.price.toStringAsFixed(2)}';
                
                return LineTooltipItem(
                  '$dateStr\n$priceStr',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),


        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}