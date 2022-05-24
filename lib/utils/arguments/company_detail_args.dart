class CompanyDetailArgs {
  final int favouritesId;
  final int companyId;
  final String companyName;
  final bool companyFavourite;
  final String type;

  CompanyDetailArgs({required this.companyId, required this.companyName, required this.companyFavourite, required this.favouritesId, required this.type});
}