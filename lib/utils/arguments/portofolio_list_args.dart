class PortofolioListArgs {
  final String title;
  final double value;
  final double cost;
  final String type;
  String? subType;

  PortofolioListArgs({required this.title, required this.value, required this.cost, required this.type, this.subType});
}