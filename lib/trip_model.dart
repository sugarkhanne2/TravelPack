class Trip {
  String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String tripType;
  final String destination;
  double? progress;

  Trip({
    this.id = '',
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    required this.destination,
    this.progress,
  });

Trip copyWith({
  String? id,
  String? title,
  DateTime? startDate,
  DateTime? endDate,
  String? tripType,
  String? destination,
  double? progress,
}) {
  return Trip(
    id: id ?? this.id,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    tripType: tripType ?? this.tripType,
    destination: destination ?? this.destination,
    progress: progress ?? this.progress,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tripType': tripType,
      'destination': destination,
      'progress': progress,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      tripType: json['tripType'],
      destination: json['destination'],
      progress: json['progress'],
    );
  }
}
