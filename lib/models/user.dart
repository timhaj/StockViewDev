import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String passwordHash;

  @HiveField(3)
  List<String> watchlist;

  User({
    required this.name,
    required this.email,
    required this.passwordHash,
    List<String>? watchlist,
  }) : watchlist = watchlist ?? [];

  // Add stock to watchlist
  void addToWatchlist(String ticker) {
    if (!watchlist.contains(ticker)) {
      watchlist.add(ticker);
      save(); // Save to Hive
    }
  }

  // Remove stock from watchlist
  void removeFromWatchlist(String ticker) {
    watchlist.remove(ticker);
    save(); // Save to Hive
  }

  // Check if stock is in watchlist
  bool isInWatchlist(String ticker) {
    return watchlist.contains(ticker);
  }
}