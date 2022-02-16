class CompanyDetailArgs {
  final int favouritesId;
  final int companyId;
  final String companyName;
  final bool companyFavourite;

  CompanyDetailArgs({required this.companyId, required this.companyName, required this.companyFavourite, required this.favouritesId});
}