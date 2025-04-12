import 'package:flutter/material.dart';
import 'package:travelpack/generated_packing_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_trip_page.dart';
import 'trip_service.dart';
import 'trip_model.dart';
import 'all_trips_page.dart';
import 'packing_item.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  final TripsService _tripsService = TripsService();
  List<Trip> _trips = [];
  Map<String, double> _packingPercentages = {};
  Trip? mostSoonTrip;
  List<Trip> upcomingTrips = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTrips();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTrips();
    }
  }

  void _loadTrips() async {
  final trips = await _tripsService.getTrips();

  Map<String, double> packingPercentages = {};
  for (var trip in trips) {
    double progress = await _calculateTripProgress(trip);
    packingPercentages[trip.id] = progress;
    trip.progress = progress;
    await _tripsService.saveTrip(trip);
  }

  Trip? soonTrip;
  List<Trip> upcoming = [];
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  Trip? closestTrip;
  int? minDaysAway;
  
  for (var trip in trips) {
    final tripStartDate = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
    final tripEndDate = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
    
    final daysUntil = tripStartDate.difference(today).inDays;
    
    if ((minDaysAway == null || daysUntil < minDaysAway) && 
        (daysUntil >= -tripEndDate.difference(tripStartDate).inDays)) {
      closestTrip = trip;
      minDaysAway = daysUntil;
    }
  }
  
  soonTrip = closestTrip;
  
  for (var trip in trips) {
    final tripEndDate = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
    
    if (trip != closestTrip && !tripEndDate.isBefore(today)) {
      upcoming.add(trip);
    }
  }
  
  upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
  
  setState(() {
    _trips = trips;
    _packingPercentages = packingPercentages;
    mostSoonTrip = soonTrip;
    upcomingTrips = upcoming;
  });
}

  Future<double> _calculateTripProgress(Trip trip) async {
    final prefs = await SharedPreferences.getInstance();
    
    final allItems = _getItemsForTrip(trip);
    
    if (allItems.isEmpty) return 0.0;

    int totalItems = allItems.length;
    int packedItems = 0;

    for (var item in allItems) {
      if (prefs.getBool('${trip.id}-${item.name}') == true) {
        packedItems++;
      }
    }

    return totalItems > 0 ? packedItems / totalItems : 0.0;
  }

  List<PackingItem> _getItemsForTrip(Trip trip) {
    final Map<String, List<Map<String, dynamic>>> packingCategories = {
      'Clothes': [
        {'item': 'Underwear', 'weight': 0.1},
        {'item': 'Socks', 'weight': 0.1},
        {'item': 'T-shirts', 'weight': 0.2},
        {'item': 'Pants/Shorts', 'weight': 0.5},
        {'item': 'Sweater/Jacket', 'weight': 0.8},
        {'item': 'Sleepwear', 'weight': 0.3},
        {'item': 'Casual outfits', 'weight': 0.7},
        {'item': 'Formal wear', 'weight': 1.0},
        {'item': 'Belt', 'weight': 0.2},
        {'item': 'Shoes', 'weight': 0.8},
      ],
      'Toiletries': [
        {'item': 'Toothbrush', 'weight': 0.05},
        {'item': 'Toothpaste', 'weight': 0.1},
        {'item': 'Deodorant', 'weight': 0.15},
        {'item': 'Shampoo', 'weight': 0.3},
        {'item': 'Conditioner', 'weight': 0.3},
        {'item': 'Soap/Body Wash', 'weight': 0.2},
        {'item': 'Skincare Products', 'weight': 0.3},
        {'item': 'Razor/Shaving cream', 'weight': 0.2},
        {'item': 'Hairbrush/Comb', 'weight': 0.1},
        {'item': 'Hair products', 'weight': 0.2},
        {'item': 'Cotton swabs/pads', 'weight': 0.05},
        {'item': 'Makeup/Makeup remover', 'weight': 0.3},
        {'item': 'Nail clippers', 'weight': 0.05},
        {'item': 'Medications', 'weight': 0.2},
        {'item': 'First aid kit', 'weight': 0.4},
      ],
      'Electronics': [
        {'item': 'Phone Charger', 'weight': 0.1},
        {'item': 'Power Bank', 'weight': 0.3},
        {'item': 'Headphones', 'weight': 0.2},
        {'item': 'Travel Adapter', 'weight': 0.2},
        {'item': 'Laptop/Tablet', 'weight': 1.5},
      ],
      'Business Trip Extras': [
        {'item': 'Business Cards', 'weight': 0.1},
        {'item': 'Laptop Charger', 'weight': 0.4},
        {'item': 'Professional Attire', 'weight': 1.2},
        {'item': 'Notebook/Planner', 'weight': 0.3},
        {'item': 'Pens/Stationery', 'weight': 0.2},
        {'item': 'Presentation materials', 'weight': 0.5},
        {'item': 'Business documents', 'weight': 0.3},
        {'item': 'Portfolio/Briefcase', 'weight': 1.0},
      ],
      'Vacation Extras': [
        {'item': 'Swimwear', 'weight': 0.2},
        {'item': 'Beach Towel', 'weight': 0.5},
        {'item': 'Sunscreen', 'weight': 0.2},
        {'item': 'Sunglasses', 'weight': 0.1},
        {'item': 'Hat', 'weight': 0.2},
        {'item': 'Beach bag', 'weight': 0.3},
        {'item': 'Flip flops/sandals', 'weight': 0.3},
      ],
      'Essentials': [
        {'item': 'Passport(if needed)', 'weight': 0.1},
        {'item': 'ID', 'weight': 0.1},
        {'item': 'Credit Card/Wallet', 'weight': 0.2},
        {'item': 'Travel Insurance Documents', 'weight': 0.05},
        {'item': 'Travel tickets/boarding passes', 'weight': 0.05},
        {'item': 'Maps/Travel guide', 'weight': 0.3},
      ],
    };

    final List<PackingItem> allItems = [];
    
    _addItemsFromCategory(allItems, 'Essentials', packingCategories);
    _addItemsFromCategory(allItems, 'Clothes', packingCategories);
    _addItemsFromCategory(allItems, 'Toiletries', packingCategories);
    _addItemsFromCategory(allItems, 'Electronics', packingCategories);
    
    if (trip.tripType == 'Business') {
      _addItemsFromCategory(allItems, 'Business Trip Extras', packingCategories);
    } else if (trip.tripType == 'Vacation') {
      _addItemsFromCategory(allItems, 'Vacation Extras', packingCategories);
    }
    
    return allItems;
  }
  
  void _addItemsFromCategory(List<PackingItem> items, String category, Map<String, List<Map<String, dynamic>>> categories) {
    final categoryItems = categories[category];
    if (categoryItems != null) {
      for (var item in categoryItems) {
        items.add(PackingItem(
          name: item['item'] as String,
          weight: item['weight'] as double,
          category: category,
        ));
      }
    }
  }

  void _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTripPage()),
    );

    if (result != null) {
      _loadTrips();
    }
  }

  void _navigateToAllTrips() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllTripsPage()),
    ).then((_) => _loadTrips());
  }

  void _deleteTrip(Trip trip) async {
    await _tripsService.deleteTrip(trip.id);
    _loadTrips();
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${_monthDay(start)} - ${_monthDay(end)}';
  }

  String _monthDay(DateTime date) {
    return '${_monthName(date.month)} ${date.day}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  int _daysUntilTrip(DateTime startDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripStart = DateTime(startDate.year, startDate.month, startDate.day);
    return tripStart.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TripPack',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF242649),
      ),
      body: _trips.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No trips added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Click + to create a new trip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
            padding: EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mostSoonTrip != null) _buildTripCard(mostSoonTrip!, isUpcoming: false),
                
                if (upcomingTrips.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Trips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToAllTrips,
                        child: Text(
                          'Show All',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...upcomingTrips.map((trip) => _buildTripCard(trip, isUpcoming: true)).toList(),
                ],
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTrip,
        backgroundColor: Color(0xFF242649),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        shape: CircleBorder(),
      ),
    );
  }
  
  Widget _buildTripCard(Trip trip, {required bool isUpcoming}) {
    final daysUntil = _daysUntilTrip(trip.startDate);
    final packingPercentage = _packingPercentages[trip.id] ?? 0;
    
    String daysText;
    Color daysBadgeColor;
  
    if (daysUntil < 0) {
      final daysElapsed = daysUntil.abs();
      daysText = 'Day $daysElapsed';
      daysBadgeColor = Color(0xFF4CAF50); 
    } else if (daysUntil == 0) {
      daysText = 'Today';
      daysBadgeColor = Color(0xFF4CAF50);
    } else if (daysUntil == 1) {
      daysText = 'Tomorrow';
      daysBadgeColor = Color(0xFF386CAF);
    } else {
      daysText = 'In $daysUntil days';
      daysBadgeColor = Color(0xFF386CAF);
    }
    
    Color cardColor = Colors.grey[100]!;
    Color progressColor = Color(0xFF386CAF);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeneratedPackingListPage(trip: trip),
          ),
        ).then((_) => _loadTrips());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Dismissible(
          key: Key(trip.id),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteTrip(trip),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        trip.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: daysBadgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        daysText,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  _formatDateRange(trip.startDate, trip.endDate),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: packingPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${(packingPercentage * 100).toInt()}% packed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}