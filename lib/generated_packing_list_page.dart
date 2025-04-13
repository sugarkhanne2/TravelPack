import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip_model.dart';
import 'packing_item.dart';

class GeneratedPackingListPage extends StatefulWidget {
  final Trip trip;

  const GeneratedPackingListPage({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  _GeneratedPackingListPageState createState() =>
      _GeneratedPackingListPageState();
}

class _GeneratedPackingListPageState extends State<GeneratedPackingListPage> {
  static const Color _darkBlueColor = Color(0xFF003366);
  static const Color _primaryColor = Color(0xFF0D47A1);
  int _selectedTabIndex = 0;
  late final Map<String, List<PackingItem>> _filteredCategories;
  late final List<PackingItem> _allItems;
  
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  
  static const Map<String, List<Map<String, dynamic>>> _packingCategories = {
    'Clothes': [
      {'item': 'Underwear', 'weight': 0.1},
      {'item': 'Socks', 'weight': 0.1},
      {'item': 'T-shirts', 'weight': 0.2},
      {'item': 'Pants/Shorts', 'weight': 0.5},
      {'item': 'Sweater/Jacket', 'weight': 0.8},
      {'item': 'Sleepwear', 'weight': 0.3},
      {'item': 'Casual outfits', 'weight': 0.7},
      {'item': 'Formal wear', 'weight': 1.0},
      {'item': 'Belt', 'weight': 0.2},
      {'item': 'Shoes', 'weight': 0.8},
    ],
    'Toiletries': [
      {'item': 'Toothbrush', 'weight': 0.05},
      {'item': 'Toothpaste', 'weight': 0.1},
      {'item': 'Deodorant', 'weight': 0.15},
      {'item': 'Shampoo', 'weight': 0.3},
      {'item': 'Conditioner', 'weight': 0.3},
      {'item': 'Soap/Body Wash', 'weight': 0.2},
      {'item': 'Skincare Products', 'weight': 0.3},
      {'item': 'Razor/Shaving cream', 'weight': 0.2},
      {'item': 'Hairbrush/Comb', 'weight': 0.1},
      {'item': 'Hair products', 'weight': 0.2},
      {'item': 'Cotton swabs/pads', 'weight': 0.05},
      {'item': 'Makeup/Makeup remover', 'weight': 0.3},
      {'item': 'Nail clippers', 'weight': 0.05},
      {'item': 'Medications', 'weight': 0.2},
      {'item': 'First aid kit', 'weight': 0.4},
    ],
    'Electronics': [
      {'item': 'Phone Charger', 'weight': 0.1},
      {'item': 'Power Bank', 'weight': 0.3},
      {'item': 'Headphones', 'weight': 0.2},
      {'item': 'Travel Adapter', 'weight': 0.2},
      {'item': 'Laptop/Tablet', 'weight': 1.5},
    ],
    'Business Trip Extras': [
      {'item': 'Business Cards', 'weight': 0.1},
      {'item': 'Laptop Charger', 'weight': 0.4},
      {'item': 'Professional Attire', 'weight': 1.2},
      {'item': 'Notebook/Planner', 'weight': 0.3},
      {'item': 'Pens/Stationery', 'weight': 0.2},
      {'item': 'Presentation materials', 'weight': 0.5},
      {'item': 'Business documents', 'weight': 0.3},
      {'item': 'Portfolio/Briefcase', 'weight': 1.0},
    ],
    'Vacation Extras': [
      {'item': 'Swimwear', 'weight': 0.2},
      {'item': 'Beach Towel', 'weight': 0.5},
      {'item': 'Sunscreen', 'weight': 0.2},
      {'item': 'Sunglasses', 'weight': 0.1},
      {'item': 'Hat', 'weight': 0.2},
      {'item': 'Beach bag', 'weight': 0.3},
      {'item': 'Flip flops/sandals', 'weight': 0.3},
    ],
    'Essentials': [
      {'item': 'Passport(if needed)', 'weight': 0.1},
      {'item': 'ID', 'weight': 0.1},
      {'item': 'Credit Card/Wallet', 'weight': 0.2},
      {'item': 'Travel Insurance Documents', 'weight': 0.05},
      {'item': 'Travel tickets/boarding passes', 'weight': 0.05},
      {'item': 'Maps/Travel guide', 'weight': 0.3},
    ],
  };

  @override
  void initState() {
    super.initState();
    _filteredCategories = _getFilteredCategories();
    _allItems = _filteredCategories.values.expand((items) => items).toList();
    _loadCheckedItems();
  }

  Map<String, List<PackingItem>> _getFilteredCategories() {
    final categories = {
      'Essentials': _createItemsFromCategory('Essentials'),
      'Clothes': _createItemsFromCategory('Clothes'),
      'Toiletries': _createItemsFromCategory('Toiletries'),
      'Electronics': _createItemsFromCategory('Electronics'),
    };

    if (widget.trip.tripType == 'Business') {
      categories['Business Trip Extras'] = _createItemsFromCategory('Business Trip Extras');
    } else if (widget.trip.tripType == 'Vacation') {
      categories['Vacation Extras'] = _createItemsFromCategory('Vacation Extras');
    } else if (widget.trip.destination == 'Beach') {
      categories['Beach Essentials'] = _createItemsFromCategory('Beach Essentials');
    }

    return categories;
  }

  List<PackingItem> _createItemsFromCategory(String category) {
    final items = _packingCategories[category];
    if (items == null) return [];
    
    return items.map((item) => PackingItem(
      name: item['item'] as String,
      weight: item['weight'] as double,
      category: category,
      isChecked: false,
    )).toList();
  }

  String _formatDateRange() {
    final start = widget.trip.startDate;
    final end = widget.trip.endDate;
    return '${_months[start.month - 1]} ${start.day} - ${_months[end.month - 1]} ${end.day}';
  }

  double get _luggageWeight => 
    _allItems.where((item) => item.isChecked).fold(0.0, (sum, item) => sum + item.weight);

  void _updateItemStatus(String category, String itemName, bool value) {
    setState(() {
      for (final item in _allItems) {
        if (item.name == itemName && item.category == category) {
          item.isChecked = value;
          break;
        }
      }
    });
    _saveCheckedItems();
  }

  Future<void> _saveCheckedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final tripId = widget.trip.id;

    for (var item in _allItems) {
      await prefs.setBool('$tripId-${item.name}', item.isChecked);
    }
  }

  Future<void> _loadCheckedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final tripId = widget.trip.id;

    setState(() {
      for (var item in _allItems) {
        item.isChecked = prefs.getBool('$tripId-${item.name}') ?? false;
      }
    });
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  List<Widget> _getItemsForSelectedCategory() {
    if (_selectedTabIndex == 0) {
      final widgets = <Widget>[];
      final Map<String, List<PackingItem>> groupedItems = {};
      
      for (final item in _allItems) {
        (groupedItems[item.category] ??= []).add(item);
      }
      
      groupedItems.forEach((category, items) {
        widgets.add(_buildCategoryContainer(
          title: category,
          children: items.map((item) => _buildItemTile(item)).toList(),
        ));
      });
      
      return widgets;
    } else {
      final categoryNames = _filteredCategories.keys.toList();
      final category = categoryNames[_selectedTabIndex - 1];
      final items = _filteredCategories[category]!;
      
      return [
        _buildCategoryContainer(
          title: category,
          children: items.map((item) => _buildItemTile(item)).toList(),
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: _darkBlueColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.trip.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              _formatDateRange(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: _buildLuggageEstimationSection(),
          ),
          
          SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTab('All Items', 0),
                  ..._filteredCategories.keys.toList().asMap().entries.map(
                        (e) => _buildTab(e.value, e.key + 1),
                      ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: _getItemsForSelectedCategory(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuggageEstimationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.luggage, color: Colors.black, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Luggage Estimation: ${_luggageWeight.toStringAsFixed(2)} kg',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => _selectCategory(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryColor),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemTile(PackingItem item) {
    return CheckboxListTile(
      title: Text(item.name),
      subtitle: Text(
        '${item.weight} kg',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
      value: item.isChecked,
      onChanged: (bool? value) {
        _updateItemStatus(item.category, item.name, value ?? false);
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.grey[600],
    );
  }

  Widget _buildCategoryContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}