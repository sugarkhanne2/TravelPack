import 'package:flutter/material.dart';
import 'generated_packing_list_page.dart';
import 'trip_model.dart';
import 'trip_service.dart';

class AllTripsPage extends StatefulWidget {
  @override
  _AllTripsPageState createState() => _AllTripsPageState();
}

class _AllTripsPageState extends State<AllTripsPage> {
  final TripsService _tripsService = TripsService();
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() {
      _isLoading = true;
    });

    final trips = await _tripsService.getTrips();

    // Calculate and update packing progress for each trip
    for (var trip in trips) {
      final progress = await _calculateTripProgress(trip);
      trip.progress = progress;
      await _tripsService.saveTrip(trip);
    }

    final filteredTrips = trips
        .where((trip) =>
            trip.startDate.isAfter(DateTime.now().subtract(Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    setState(() {
      _trips = filteredTrips;
      _isLoading = false;
    });
  }

  Future<double> _calculateTripProgress(Trip trip) async {
    return await _tripsService.calculateTripProgress(trip);
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

  Widget _buildCountdownBadge(DateTime startDate) {
    final daysUntil = _daysUntilTrip(startDate);

    if (daysUntil < 0) return SizedBox();

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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }

  // Method to handle trip deletion
  Future<void> _deleteTrip(Trip trip) async {
    try {
      await _tripsService.deleteTrip(trip.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip "${trip.title}" deleted'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchTrips();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Trips",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF242649),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _trips.isEmpty
              ? Center(
                  child: Text(
                    "No upcoming trips",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
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
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GeneratedPackingListPage(trip: trip),
                              ),
                            ).then((_) {
                              _fetchTrips();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          trip.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      _buildCountdownBadge(trip.startDate),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatDateRange(
                                        trip.startDate, trip.endDate),
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: trip.progress ?? 0.0,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.lightBlue,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '${((trip.progress ?? 0.0) * 100).toInt()}% packed',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
