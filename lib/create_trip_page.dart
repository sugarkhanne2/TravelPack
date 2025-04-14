import 'package:flutter/material.dart';
import 'generated_packing_list_page.dart';
import 'trip_service.dart';
import 'trip_model.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({Key? key}) : super(key: key);

  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _tripsService = TripsService();

  String _tripTitle = '';
  String _destination = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _tripType;

  static const List<String> _tripTypes = ['Business', 'Casual', 'Vacation'];
  static const Color _primaryColor = Color(0xFF242649);
  static const TextStyle _headerStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // Show date picker for start or end date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final initialDate = isStartDate
        ? _startDate ?? today
        : _endDate ??
            (_startDate != null
                ? _startDate!.add(Duration(days: 1))
                : today.add(Duration(days: 1)));

    final firstDate = isStartDate
        ? today
        : (_startDate != null
            ? _startDate!.add(Duration(days: 1))
            : today.add(Duration(days: 1)));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    return date == null ? '' : '${date.month}/${date.day}/${date.year}';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Handles form validation and trip creation
  void _generatePackingList() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      _showErrorSnackBar('Please select both start and end dates');
      return;
    }

    // Check if start date is in the past
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_startDate!.isBefore(today)) {
      _showErrorSnackBar('Start date cannot be in the past');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showErrorSnackBar('End date must be after start date');
      return;
    }

    if (_tripType == null) {
      _showErrorSnackBar('Please select a trip type');
      return;
    }

    _formKey.currentState!.save();

    // Create a new trip
    final trip = Trip(
      id: '',
      title: _tripTitle,
      destination: _destination,
      startDate: _startDate!,
      endDate: _endDate!,
      tripType: _tripType!,
    );

    // Save the trip and navigate to the packing list page
    _tripsService.saveTrip(trip).then((savedTrip) {
      Navigator.pop(context, savedTrip);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedPackingListPage(trip: savedTrip),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: _primaryColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: const Text('New Trip',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Trip Title', style: _headerStyle),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _getInputDecoration('Enter trip title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a trip title' : null,
                  onSaved: (value) => _tripTitle = value!,
                ),
                const SizedBox(height: 16),
                const Text('Destination', style: _headerStyle),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _getInputDecoration('Enter destination'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a destination' : null,
                  onSaved: (value) => _destination = value!,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date', style: _headerStyle),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration:
                                _getInputDecoration('Select start date'),
                            readOnly: true,
                            onTap: () => _selectDate(context, true),
                            controller: TextEditingController(
                                text: _formatDate(_startDate)),
                            validator: (value) => _startDate == null
                                ? 'Please select start date'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Date', style: _headerStyle),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: _getInputDecoration('Select end date'),
                            readOnly: true,
                            onTap: () => _selectDate(context, false),
                            controller: TextEditingController(
                                text: _formatDate(_endDate)),
                            validator: (value) => _endDate == null
                                ? 'Please select end date'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Trip Type', style: _headerStyle),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: _getInputDecoration('Select an option'),
                  hint: const Text('Select an option',
                      style: TextStyle(color: Colors.grey)),
                  items: _tripTypes
                      .map((String type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Please select a trip type' : null,
                  onChanged: (value) => setState(() => _tripType = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _generatePackingList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Generate Packing List',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }
}
