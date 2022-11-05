class PortofolioListArgs {
  final String title;
  final double value;
  final double cost;
  final double? realised;
  final double? unrealised;
  final String type;
  String? subType;

  PortofolioListArgs({required this.title, required this.value, required this.cost, this.realised, this.unrealised, required this.type, this.subType});
}