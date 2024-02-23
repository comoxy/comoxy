class Transaction {
  String? processName;
  String? trandocId;
  String? transId;
  String? docPhoto;
  String? docType;
  String? isApproved;
  String? createdDate;
  String? paymentAmt;
  String? photoName;

  Transaction({this.processName,
    this.trandocId,
    this.transId,
    this.docPhoto,
    this.docType,
    this.isApproved,
    this.createdDate,
    this.paymentAmt,
    this.photoName});


  Transaction.fromJson(Map<String, dynamic> json) {
    processName = json['processName'];
    trandocId = json['trandoc_id'];
    transId = json['trans_id'];
    docPhoto = json['doc_photo'];
    docType = json['doc_type'];
    isApproved = json['is_approved'];
    createdDate = json['created_date'];
    paymentAmt = json['payment_amt'];
    photoName = json['photo_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['processName'] = processName;
    data['trandoc_id'] = trandocId;
    data['trans_id'] = transId;
    data['doc_photo'] = docPhoto;
    data['doc_type'] = docType;
    data['is_approved'] = isApproved;
    data['created_date'] = createdDate;
    data['payment_amt'] = paymentAmt;
    data['photo_name'] = photoName;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          trandocId == other.trandocId &&
          docType == other.docType;

  @override
  int get hashCode =>
      trandocId.hashCode ^
      docType.hashCode;
}