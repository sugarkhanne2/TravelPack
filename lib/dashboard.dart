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

class _DashboardPageState extends State<DashboardPage> {
  final TripsService _tripsService = TripsService();
  List<Trip> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() async {
    final trips = await _tripsService.getTrips();

    final upcomingTrips = trips
        .where((trip) => trip.startDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    setState(() {
      _trips = upcomingTrips;
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

  Widget _buildCountdownBadge(DateTime startDate) {
    final now = DateTime.now();
    final daysLeft = startDate.difference(now).inDays;

    if (daysLeft < 0) return SizedBox(); // Past trip

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'In $daysLeft days',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
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
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Text(
                  'Upcoming Trips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllTripsPage()),
                      );
                    },
                    child: Text('Show All'),
                  ),
                ),
                SizedBox(height: 8),
                // Display trips that start today ("In 0 days") at the top
                ..._buildCurrentTrips(),
                // Display the rest of the upcoming trips
                ..._trips
                    .where((trip) => trip.startDate.isAfter(DateTime.now()))
                    .take(3)
                    .map((trip) {
                  return Dismissible(
                    key: Key(trip.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteTrip(trip),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GeneratedPackingListPage(trip: trip),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  trip.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildCountdownBadge(trip.startDate),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatDateRange(trip.startDate, trip.endDate),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: trip.progress ?? 0.15,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.lightBlue,
                                ),
                                minHeight: 8,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '${((trip.progress ?? 0.15) * 100).toInt()}% packed',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
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

  List<Widget> _buildCurrentTrips() {
    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day); // Today's date without time

    // Get trips that are starting today (ignoring the time part)
    final currentTrips = _trips.where((trip) {
      final tripStartDate = DateTime(trip.startDate.year, trip.startDate.month,
          trip.startDate.day); // Normalize trip start date to ignore time
      return tripStartDate == today; // Compare only the date (day/month/year)
    }).toList();

    if (currentTrips.isEmpty) return [];

    return [
      Text(
        'Current Trip',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8),
      ...currentTrips.map((trip) {
        return Dismissible(
          key: Key(trip.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteTrip(trip),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneratedPackingListPage(trip: trip),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildCountdownBadge(trip.startDate),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatDateRange(trip.startDate, trip.endDate),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: trip.progress ?? 0.15,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '${((trip.progress ?? 0.15) * 100).toInt()}% packed',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ];
  }
}
