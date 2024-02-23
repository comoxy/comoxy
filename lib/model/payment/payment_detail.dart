class PaymentDetail {
  String? paymentId;
  String? userEmail;
  String? paymentAmount;
  String? paymentDate;
  String? paymentDetailId;
  String? paymentType;
  String? paypalId;
  String? bankName;
  String? accountNo;
  String? bankCode;

  PaymentDetail({this.paymentId, this.userEmail, this.paymentAmount, this.paymentDate});

  PaymentDetail.fromJson(Map<String, dynamic> json) {
    paymentId = json['payment_id'];
    userEmail = json['user_email'];
    paymentAmount = json['payment_amount'];
    paymentDate = json['payment_date'];
    paymentDetailId = json['payment_detail_id'];
    paymentType = json['payment_type'];
    paypalId = json['paypal_id'];
    bankName = json['bank_name'];
    accountNo = json['account_no'];
    bankCode = json['bank_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['payment_id'] = paymentId;
    data['user_email'] = userEmail;
    data['payment_amount'] = paymentAmount;
    data['payment_date'] = paymentDate;
    data['payment_detail_id'] = paymentDetailId;
    data['payment_type'] = paymentType;
    data['paypal_id'] = paypalId;
    data['bank_name'] = bankName;
    data['account_no'] = accountNo;
    data['bank_code'] = bankCode;
    return data;
  }
}