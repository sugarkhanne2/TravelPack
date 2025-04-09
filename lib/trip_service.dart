import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip_model.dart';
import 'package:uuid/uuid.dart';

class TripsService {
  static const String _tripsKey = 'trips';
  final Uuid _uuid = Uuid();

  // Save a new trip
  Future<Trip> saveTrip(Trip trip) async {
    final prefs = await SharedPreferences.getInstance();

    // If no ID, generate one
    if (trip.id.isEmpty) {
      trip.id = _uuid.v4();
    }

    // Get existing trips
    List<Trip> trips = await getTrips();

    // Check if trip already exists (update)
    int existingIndex = trips.indexWhere((t) => t.id == trip.id);
    if (existingIndex != -1) {
      trips[existingIndex] = trip;
    } else {
      // Add new trip
      trips.add(trip);
    }

    // Save updated trips list
    await prefs.setStringList(
        _tripsKey, trips.map((trip) => json.encode(trip.toJson())).toList());

    return trip;
  }

  // Get all trips
  Future<List<Trip>> getTrips() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve trips
    List<String>? tripsJson = prefs.getStringList(_tripsKey);

    if (tripsJson == null) return [];

    // Convert back to Trip objects
    return tripsJson
        .map((tripJson) => Trip.fromJson(json.decode(tripJson)))
        .toList();
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing trips
    List<Trip> trips = await getTrips();

    // Remove the trip
    trips.removeWhere((trip) => trip.id == tripId);

    // Save updated trips list
    await prefs.setStringList(
        _tripsKey, trips.map((trip) => json.encode(trip.toJson())).toList());
  }
}
