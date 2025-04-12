import 'package:flutter/material.dart';
import 'generated_packing_list_page.dart';
import 'trip_model.dart';
import 'trip_service.dart';

class AllTripsPage extends StatelessWidget {
  final TripsService _tripsService = TripsService();

  Future<List<Trip>> _fetchTrips() => _tripsService.getTrips();

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
    
    if (daysUntil < -30) return SizedBox();
    
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
      body: FutureBuilder<List<Trip>>(
        future: _fetchTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final trips = (snapshot.data ?? [])
              .where((trip) => trip.startDate.isAfter(DateTime.now().subtract(Duration(days: 30))))
              .toList()
            ..sort((a, b) => a.startDate.compareTo(b.startDate));

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return GestureDetector(
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
              );
            },
          );
        },
      ),
    );
  }
}
