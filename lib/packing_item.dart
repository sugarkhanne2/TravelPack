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
