import 'package:flutter/material.dart';
import 'trip_model.dart';

class GeneratedPackingListPage extends StatefulWidget {
  final Trip trip;

  const GeneratedPackingListPage({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  _GeneratedPackingListPageState createState() => _GeneratedPackingListPageState();
}

class _GeneratedPackingListPageState extends State<GeneratedPackingListPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  // Static data structure for packing categories
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
      {'item': 'Credit Card/Wallet', 'weight': 0.2},
      {'item': 'Travel Insurance Documents', 'weight': 0.05},
      {'item': 'Travel tickets/boarding passes', 'weight': 0.05},
      {'item': 'Maps/Travel guide', 'weight': 0.3},
    ],
  };

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  // UI constants
  static const Color _primaryColor = Color(0xFF386CAF);
  static const Color _darkBlueColor = Color(0xFF242649);

  // Runtime data structures
  late final Map<String, List<PackingItem>> _filteredCategories;
  late final List<PackingItem> _allItems;

  @override
  void initState() {
    super.initState();
    _filteredCategories = _getFilteredCategories();
    _allItems = _getAllItems();
    _tabController = TabController(length: _filteredCategories.length + 1, vsync: this)
      ..addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index != _selectedTabIndex) {
      setState(() => _selectedTabIndex = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => '${_months[date.month - 1]} ${date.day}';

  String get _formattedDateRange => 
      '${_formatDate(widget.trip.startDate)} - ${_formatDate(widget.trip.endDate)}';

  double get _luggageWeight => _allItems
      .where((item) => item.isChecked)
      .fold(0.0, (sum, item) => sum + item.weight);

  Map<String, List<PackingItem>> _getFilteredCategories() {

    final filteredCategories = <String, List<PackingItem>>{
      'Essentials': _createItemsFromCategory('Essentials'),
      'Clothes': _createItemsFromCategory('Clothes'),
      'Toiletries': _createItemsFromCategory('Toiletries'),
      'Electronics': _createItemsFromCategory('Electronics'),
    };

    if (widget.trip.tripType == 'Business') {
      filteredCategories['Business Trip Extras'] = _createItemsFromCategory('Business Trip Extras');
    } else if (widget.trip.tripType == 'Vacation') {
      filteredCategories['Vacation Extras'] = _createItemsFromCategory('Vacation Extras');
    }
    
    return filteredCategories;
  }

  List<PackingItem> _createItemsFromCategory(String category) {
    return _packingCategories[category]!.map((item) => 
      PackingItem(
        name: item['item'] as String,
        weight: item['weight'] as double,
        category: category,
        isChecked: false,
      )
    ).toList();
        }

  List<PackingItem> _getAllItems() {
    final allItems = <PackingItem>[];
    for (final entry in _filteredCategories.entries) {
      allItems.addAll(entry.value);
    }
    return allItems;
  }

  void _updateItemStatus(String category, String itemName, bool value) {
    setState(() {

      for (final item in _filteredCategories[category]!) {
        if (item.name == itemName) {
          item.isChecked = value;
          break;
        }
      }
      
      for (final item in _allItems) {
        if (item.name == itemName && item.category == category) {
      item.isChecked = value;
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: _buildLuggageEstimationSection(),
                ),
                Expanded(
                  child: _buildTabsSection(),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
            _formattedDateRange,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTab('All Items', 0),
              ..._filteredCategories.keys.toList().asMap().entries.map(
                (entry) => _buildTab(entry.value, entry.key + 1)
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllItemsWithGroups(),
              ..._filteredCategories.entries.map((entry) => 
                _buildCategoryList(entry.key, entry.value)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _tabController.animateTo(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 36,
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

  Widget _buildCategoryList(String category, List<PackingItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => _buildItemTile(items[index]),
              ),
            ),
          ],
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
  
  Widget _buildAllItemsWithGroups() {
    // Group items by category
    final Map<String, List<PackingItem>> groupedItems = {};
    
    for (final item in _allItems) {
      (groupedItems[item.category] ??= []).add(item);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final items = groupedItems[category]!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, itemIndex) => _buildItemTile(items[itemIndex]),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Model class for packing items
class PackingItem {
  final String name;
  final double weight;
  final String category;
  bool isChecked;

  PackingItem({
    required this.name,
    required this.weight,
    required this.category,
    this.isChecked = false,
  });
}