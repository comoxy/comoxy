class DocumentData {
  String? documentId;
  String? userEmail;
  String? documentName;
  String? isVerified;
  String? docOrd;

  DocumentData(
      {this.documentId,
        this.userEmail,
        this.documentName,
        this.isVerified,
        this.docOrd});

  DocumentData.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'];
    userEmail = json['user_email'];
    documentName = json['document_name'];
    isVerified = json['is_verified'];
    docOrd = json['doc_ord'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['document_id'] = documentId;
    data['user_email'] = userEmail;
    data['document_name'] = documentName;
    data['is_verified'] = isVerified;
    data['doc_ord'] = docOrd;
    return data;
  }
}