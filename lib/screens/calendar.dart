import 'package:flutter/material.dart';
import '../services/finhub_service.dart';

class EarningsCalendarScreen extends StatefulWidget {
  const EarningsCalendarScreen({super.key});

  @override
  State<EarningsCalendarScreen> createState() => _EarningsCalendarScreenState();
}

class _EarningsCalendarScreenState extends State<EarningsCalendarScreen> {
  final FinnhubService _finService = FinnhubService();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final from = '${now.year}-${now.month.toString().padLeft(2,'0')}-01';
    final to = '${now.year}-${now.month.toString().padLeft(2,'0')}-31';

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings Calendar')),
      body: FutureBuilder<List<dynamic>>(
        future: _finService.getEarningsCalendar(from: from, to: to),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No earnings events this month'));
          }
          final earnings = snapshot.data!
              // filtriraj samo prihodnje ali trenutne datume
              .where((e) {
                final dateStr = e['date'] ?? '';
                if (dateStr.isEmpty) return false;
                final date = DateTime.tryParse(dateStr);
                return date != null && !date.isBefore(now);
              })
              // sort po datumu ascending
              .toList()
            ..sort((a, b) {
              final dateA = DateTime.tryParse(a['date'] ?? '') ?? now;
              final dateB = DateTime.tryParse(b['date'] ?? '') ?? now;
              return dateA.compareTo(dateB);
            });

          if (earnings.isEmpty) {
            return const Center(child: Text('No upcoming earnings events'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: earnings.length,
            itemBuilder: (context, index) {
              final e = earnings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text('${e['symbol'] ?? ''}'),
                  subtitle: Text('${e['date'] ?? ''} • EPS Estimate: ${e['epsEstimate'] ?? '-'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
