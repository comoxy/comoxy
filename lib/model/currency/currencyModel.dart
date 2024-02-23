class CurrencyModel {
  final String? currency;
  final String? currencyName;
  final String? currencySymbol;
  final bool? isSelect;

  const CurrencyModel({
    this.currency,
    this.currencyName,
    this.currencySymbol,
    this.isSelect,
  });

  static CurrencyModel fromJson(Map<String, dynamic> json) => CurrencyModel(
        currency: json['currency'],
        currencyName: json['currencyName'],
        currencySymbol: json['currencySymbol'],
        isSelect: json['isSelect'],
      );

  Map<String, Object?> toJson() => {
        'currency': currency,
        'currencyName': currencyName,
        'currencySymbol': currencySymbol,
        'isSelect': isSelect,
      };
}
