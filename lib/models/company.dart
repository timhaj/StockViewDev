class Company {
  final String name;
  final String ticker;
  final String logo;
  final String industry;
  final String country;
  final String website;

  Company({
    required this.name,
    required this.ticker,
    required this.logo,
    required this.industry,
    required this.country,
    required this.website,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      ticker: json['ticker'] ?? '',
      logo: json['logo'] ?? '',
      industry: json['finnhubIndustry'] ?? '',
      country: json['country'] ?? '',
      website: json['weburl'] ?? '',
    );
  }
}
