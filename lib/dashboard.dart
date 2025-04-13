import 'package:flutter/material.dart';
import 'package:travelpack/generated_packing_list_page.dart';
import 'create_trip_page.dart';
import 'trip_service.dart';
import 'trip_model.dart';
import 'all_trips_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  final TripsService _tripsService = TripsService();
  List<Trip> _trips = [];
  Trip? mostSoonTrip;
  List<Trip> upcomingTrips = [];
  bool _isLoading = true;

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

  /// Loads all trips from storage and calculates their progress
  void _loadTrips() async {
    setState(() {
      _isLoading = true;
    });
    
    final trips = await _tripsService.getTrips();

    // Update progress for all trips
    for (var trip in trips) {
      double progress = await _tripsService.calculateTripProgress(trip);
      trip.progress = progress;
      await _tripsService.saveTrip(trip);
    }

    // Find the closest upcoming or current trip
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    Trip? closestTrip;
    int? minDaysAway;
    
    for (var trip in trips) {
      final tripStartDate = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
      final tripEndDate = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
      
      // Calculate how many days until the trip starts
      final daysUntil = tripStartDate.difference(today).inDays;
      
      // Find the closest upcoming trip or a trip that's currently happening
      if ((minDaysAway == null || daysUntil < minDaysAway) && 
          (daysUntil >= -tripEndDate.difference(tripStartDate).inDays)) {
        closestTrip = trip;
        minDaysAway = daysUntil;
      }
    }
    
    // Separate other upcoming trips
    List<Trip> upcoming = [];
    for (var trip in trips) {
      final tripEndDate = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
      
      if (trip != closestTrip && !tripEndDate.isBefore(today)) {
        upcoming.add(trip);
      }
    }
    
    // Sort upcoming trips by start date
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    
    setState(() {
      _trips = trips;
      mostSoonTrip = closestTrip;
      upcomingTrips = upcoming;
      _isLoading = false;
    });
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

  /// Calculate how many days until a trip starts
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
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : _trips.isEmpty
              ? _buildEmptyState()
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
  
  Widget _buildEmptyState() {
    return Center(
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
    );
  }
  
  Widget _buildTripCard(Trip trip, {required bool isUpcoming}) {
    final daysUntil = _daysUntilTrip(trip.startDate);
    
    String daysText;
    Color daysBadgeColor;
  
    if (daysUntil == 0) {
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
    Color progressColor = Colors.lightBlue;
    
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
                    value: trip.progress ?? 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${((trip.progress ?? 0.0) * 100).toInt()}% packed',
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