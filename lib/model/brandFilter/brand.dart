class Brand {
  String? brand_id;
  String? brand_name;
  String? photo_name;

  Brand(
      {this.brand_id,
        this.brand_name,
        this.photo_name,
        });

  Brand.fromJson(dynamic json) {
    brand_id = json["brand_id"];
    brand_name = json["brand_name"];
    photo_name = json["photo_name"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["brand_id"] = brand_id;
    map["brand_name"] = brand_name;
    map["photo_name"] = photo_name;
    return map;
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Brand && runtimeType == other.runtimeType && brand_id == other.brand_id;

  @override
  int get hashCode => super.hashCode;
}

