class Trip {
  String id;
  String title;
  String destination;
  DateTime startDate;
  DateTime endDate;
  String tripType;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.tripType,
  });

  // Convert Trip to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'destination': destination,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'tripType': tripType,
  };

  // Create Trip from JSON
  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'],
    title: json['title'],
    destination: json['destination'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    tripType: json['tripType'],
  );
}