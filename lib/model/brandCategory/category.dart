class Category {
  String? category_id;
  String? category_name;

  Category(
      {this.category_id,
        this.category_name,
      });

  Category.fromJson(dynamic json) {
    category_id = json["category_id"];
    category_name = json["category_name"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["category_id"] = category_id;
    map["category_name"] = category_name;
    return map;
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Category && runtimeType == other.runtimeType && category_id == other.category_id;

  @override
  int get hashCode => super.hashCode;
}
