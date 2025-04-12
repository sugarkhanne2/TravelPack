class Trip {
  String id;
  String title;
  String destination;
  DateTime startDate;
  DateTime endDate;
  String tripType;
  double progress; // NEW FIELD

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'tripType': tripType,
        'progress': progress,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'],
        title: json['title'],
        destination: json['destination'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        tripType: json['tripType'],
        progress: (json['progress'] ?? 0.0).toDouble(),
      );
}
