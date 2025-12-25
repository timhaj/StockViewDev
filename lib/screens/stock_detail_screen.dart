import 'package:flutter/material.dart';
import '../models/company.dart';
import '../services/finhub_service.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/sp500_chart.dart';
import '../services/stock_service.dart';
import '../models/stock.dart';

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
  bool isInWatchlist = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadCompany();
    _checkWatchlistStatus();
  }

  Future<void> _checkWatchlistStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    final inWatchlist = await AuthService.isInWatchlist(widget.symbol);
    setState(() {
      isLoggedIn = loggedIn;
      isInWatchlist = inWatchlist;
    });
  }

  Future<void> _toggleWatchlist() async {
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to use watchlist')),
      );
      return;
    }

    if (isInWatchlist) {
      await AuthService.removeFromWatchlist(widget.symbol);
    } else {
      await AuthService.addToWatchlist(widget.symbol);
    }

    await _checkWatchlistStatus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isInWatchlist
                ? 'Added to watchlist'
                : 'Removed from watchlist',
          ),
        ),
      );
    }
  }

  String formatMarketCap(num value) {
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(2)} T';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(2)} B';
    } else {
      return value.toString();
    }
  }
  
  String formatFinancialValue(num value, String unit) {
    final u = unit.toLowerCase();

    if (value == 0) return '0';

    if (u.contains('usd')) {
      if (value.abs() >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)} T';
      if (value.abs() >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)} B';
      if (value.abs() >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)} M';
      if (value.abs() >= 1e3) return '\$${(value / 1e3).toStringAsFixed(2)} K';
      return '\$${value.toStringAsFixed(2)}';
    }

    if (u.contains('share') || u.contains('shares')) {
      if (value.abs() >= 1e9) return '${(value / 1e9).toStringAsFixed(2)} B';
      if (value.abs() >= 1e6) return '${(value / 1e6).toStringAsFixed(2)} M';
      if (value.abs() >= 1e3) return '${(value / 1e3).toStringAsFixed(2)} K';
      return value.toStringAsFixed(0);
    }

    if (u.contains('%')) return '${value.toStringAsFixed(2)}%';

    if (value.abs() >= 1e12) return '${(value / 1e12).toStringAsFixed(2)} T';
    if (value.abs() >= 1e9) return '${(value / 1e9).toStringAsFixed(2)} B';
    if (value.abs() >= 1e6) return '${(value / 1e6).toStringAsFixed(2)} M';
    if (value.abs() >= 1e3) return '${(value / 1e3).toStringAsFixed(2)} K';

    return value.toStringAsFixed(2);
  }

  Future<void> _loadCompany() async {
    try {
      final data = await _finService.getCompanyProfile(widget.symbol);
      setState(() {
        company = Company.fromJson(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading company: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchWebsite(String? website) async {
    if (website == null || website.trim().isEmpty) return;

    final url = website.trim().startsWith('http')
        ? website.trim()
        : 'https://${website.trim()}';

    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          // Watchlist star icon
          IconButton(
            icon: Icon(
              isInWatchlist ? Icons.star : Icons.star_border,
              color: isInWatchlist ? Colors.yellow : null,
            ),
            onPressed: _toggleWatchlist,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : company == null
              ? const Center(child: Text('No company data'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildWebsite(),
                    const SizedBox(height: 16),
                    _buildQuoteSection(),
                    const SizedBox(height: 16),
                    _buildChartSection(),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _finService.getCompanyBasicFinancials(widget.symbol),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text('Unable to load company metrics');
                        }

                        final metrics = snapshot.data!['metric'] ?? {};
                        return _buildBasicFinancials(metrics);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    _buildFinancialsReportedSection(),
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (company!.logo.isNotEmpty)
          Image.network(company!.logo, height: 50),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${company!.industry} • ${company!.country}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebsite() {
    return InkWell(
      onTap: () => _launchWebsite(company?.website),
      child: Text(
        company?.website ?? '',
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildQuoteSection() {
    return FutureBuilder<Stock>(
      future: _finService.getStockQuote(widget.symbol),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Unable to load stock quote');
        }

        final stock = snapshot.data!;
        final isUp = stock.change_p.startsWith('-') ? false : true;
        final IconData changeIcon =
        isUp ? Icons.arrow_upward : Icons.arrow_downward;
        final Color changeColor = isUp ? Colors.green : Colors.red;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${stock.price}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(
                      changeIcon,
                      size: 16,
                      color: changeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stock.change_p + ' (Daily)',
                      style: TextStyle(fontSize: 16, color: changeColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FutureBuilder<MarketData>(
        future: StockService.fetchMarketData(widget.symbol),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.points.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Unable to load chart data'),
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
              currency: snapshot.data!.currency,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicFinancials(Map<String, dynamic> metrics) {
    final financialMetrics = <Map<String, dynamic>>[
      {'label': 'Beta', 'value': metrics['beta'], 'unit': ''},
      {'label': 'EPS (TTM)', 'value': metrics['epsTTM'] ?? metrics['eps'], 'unit': 'USD'},
      {'label': 'Current Dividend Yield', 'value': metrics['currentDividendYieldTTM'], 'unit': '%'},
      {'label': 'Dividend per Share (Annual)', 'value': metrics['dividendPerShareAnnual'], 'unit': 'USD'},
      {'label': 'Dividend Growth Rate 5Y', 'value': metrics['dividendGrowthRate5Y'], 'unit': '%'},
      {'label': 'Gross Margin', 'value': metrics['grossMargin'], 'unit': '%'},
      {'label': 'Operating Margin', 'value': metrics['operatingMargin'], 'unit': '%'},
      {'label': 'Net Margin', 'value': metrics['netMargin'], 'unit': '%'},
      {'label': 'Total Debt', 'value': metrics['totalDebt'], 'unit': 'USD'},
      {'label': 'Debt to Equity', 'value': metrics['debtToEquity'], 'unit': ''},
      {'label': 'Market Cap', 'value': metrics['marketCapitalization'], 'unit': 'USD'},
      {'label': 'Shares Outstanding', 'value': metrics['sharesOutstanding'], 'unit': ''},
      {'label': 'Book Value per Share', 'value': metrics['bookValuePerShareAnnual'], 'unit': 'USD'},
      {'label': 'Cash Flow per Share (TTM)', 'value': metrics['cashFlowPerShareTTM'], 'unit': 'USD'},
      {'label': 'Current Ratio', 'value': metrics['currentRatioAnnual'] ?? metrics['currentRatioQuarterly'], 'unit': ''},
      {'label': 'EV / Free Cash Flow', 'value': metrics['currentEv/freeCashFlowTTM'], 'unit': ''},
      {'label': '52 Week High', 'value': metrics['52WeekHigh'], 'unit': 'USD'},
      {'label': '52 Week Low', 'value': metrics['52WeekLow'], 'unit': 'USD'},
      {'label': '52 Week Price Return', 'value': metrics['52WeekPriceReturnDaily'], 'unit': '%'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Basic Financials', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...financialMetrics.map((m) {
              final value = m['value'];
              if (value == null) return const SizedBox.shrink();
              String formattedValue = value is double ? value.toStringAsFixed(2) : value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m['label']),
                    Text(
                      m['label'] == 'Market Cap' 
                        ? '${formatMarketCap(value)} ${m['unit']}' 
                        : '$formattedValue ${m['unit']}'
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialsReportedSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _finService.getFinancialsReported(widget.symbol),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Unable to load financials reported');
        }

        final data = snapshot.data!['data'] ?? [];
        if (data.isEmpty) return const Text('No financial reports available');

        final latestReport = data.first;
        final bs = latestReport['report']['bs'] ?? [];
        final ic = latestReport['report']['ic'] ?? [];
        final cf = latestReport['report']['cf'] ?? [];
        final bsKeys = [
          'Cash and cash equivalents',
          'Marketable securities',
          'Accounts receivable, net',
          'Total current assets',
          'Property, plant and equipment, net',
          'Total assets',
          'Total current liabilities',
          'Long-term debt',
          'Total liabilities',
          'Total shareholders equity',
        ];

        final icKeys = [
          'Net sales',
          'Cost of sales',
          'Gross margin',
          'Operating income',
          'Net income',
          'EPS, basic',
          'EPS, diluted',
        ];

        final cfKeys = [
          'Net Cash Provided by (Used in) Operating Activities',
          'Payments to Acquire Property, Plant, and Equipment',
          'Net Cash Provided by (Used in) Financing Activities',
        ];

        Widget buildSection(String title, List<dynamic> items, List<String> keysToShow) {
          final filteredItems = items.where((i) {
            final label = i['label'] ?? i['concept'] ?? '';
            return keysToShow.contains(label);
          }).toList();

          if (filteredItems.isEmpty) return const SizedBox.shrink();

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...filteredItems.map((i) {
                    final label = i['label'] ?? i['concept'] ?? '';
                    final rawValue = i['value'];
                    final unit = (i['unit'] ?? '').toString();

                    num? numValue;
                    if (rawValue is num) {
                      numValue = rawValue;
                    } else if (rawValue is String) {
                      numValue = num.tryParse(rawValue);
                    }

                    final formattedValue = (numValue != null)
                        ? formatFinancialValue(numValue, unit)
                        : '-';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(label)),
                          Text(formattedValue),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection('Balance Sheet', bs, bsKeys),
            const SizedBox(height: 16),
            buildSection('Income Statement', ic, icKeys),
            const SizedBox(height: 16),
            buildSection('Cash Flow', cf, cfKeys),
          ],
        );
      },
    );
  }
}