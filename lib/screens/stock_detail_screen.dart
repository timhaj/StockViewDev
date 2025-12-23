import 'package:flutter/material.dart';
import '../models/company.dart';
import '../services/finhub_service.dart';
import 'package:url_launcher/url_launcher.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final FinnhubService _finService = FinnhubService();

  Company? company;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    try {
      final data = await _finService.getCompanyProfile(widget.symbol);
      setState(() {
        company = Company.fromJson(data);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading company: $e');
      isLoading = false;
    }
  }

  Future<void> _launchWebsite(String? website) async {
    if (website == null || website.trim().isEmpty) return;

    final url = website.trim().startsWith('http') ? website.trim() : 'https://${website.trim()}';
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch website')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : company == null
              ? const Center(child: Text('No company data'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼 Logo
                      if (company!.logo.isNotEmpty)
                        Center(
                          child: Image.network(
                            company!.logo,
                            height: 60,
                          ),
                        ),

                      const SizedBox(height: 16),

                      Text(
                        company!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text('Industry: ${company!.industry}'),
                      Text('Country: ${company!.country}'),

                      const SizedBox(height: 12),

                    InkWell(
                      onTap: () => _launchWebsite(company?.website),
                      child: Text(
                        company?.website ?? '',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                      const SizedBox(height: 24),

                      // 🔜 tukaj pridejo:
                      // - current price
                      // - change %
                      // - chart
                      // - add to watchlist
                    ],
                  ),
                ),
    );
  }
}
