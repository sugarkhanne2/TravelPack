import 'package:flutter/material.dart';
import 'create_trip_page.dart';
import 'trip_service.dart';
import 'trip_model.dart';

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
    setState(() {
      _trips = trips;
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
        : ListView.builder(
            itemCount: _trips.length,
            itemBuilder: (context, index) {
              final trip = _trips[index];
              return Dismissible(
                key: Key(trip.id),
                background: Container(
                  color: Colors.red,
                  child: Icon(
                    Icons.delete, 
                    color: Colors.white,
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                      ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteTrip(trip);
                },
                child: ListTile(
                  title: Text(trip.title),
                  subtitle: Text('${trip.destination} | ${trip.tripType}'),
                  trailing: Text('${trip.startDate.day}/${trip.startDate.month} - ${trip.endDate.day}/${trip.endDate.month}'),
                ),
              );
            },
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
}