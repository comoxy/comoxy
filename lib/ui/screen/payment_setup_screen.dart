import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/payment/payment_detail.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';

class PaymentSetupScreen extends StatefulWidget {
  const PaymentSetupScreen({Key? key}) : super(key: key);

  @override
  _PaymentSetupScreenState createState() => _PaymentSetupScreenState();
}
enum PaymentMode { Paypal, BankDetail }

class _PaymentSetupScreenState extends State<PaymentSetupScreen> {
  PaymentMode? _character;
  late User _user;

  final TextEditingController _paypalidController = TextEditingController();
  final TextEditingController _banknameController = TextEditingController();
  final TextEditingController _accnumberController = TextEditingController();
  final TextEditingController _ifsccodeController = TextEditingController();

  String? paypalidError;
  String? bankControllerError;
  String? accountControllerError;
  String? ifscControllerError;
  final AuthModel _authModel = Get.find();
  final UserDefault userDefault = Get.find();

  final GlobalKey<State> _globalKey = GlobalKey<State>();
  PaymentDetail? paymentDetail;

  @override
  void initState() {
    userDefault.getUser().then((value) {
      _user = value!;
      if (mounted) {
        setState(() {});
      }
      setupExiestingData();
    });
    super.initState();
  }

  void setupExiestingData() {
    _character = PaymentMode.Paypal;
    if (_user.payment != null && _user.payment!.isNotEmpty) {
      paymentDetail = _user.payment!.first;
      // TODO paymentDetail.paymentType == '1' paypal
      _paypalidController.text = paymentDetail!.paypalId??'';

      if (paymentDetail!.paymentType != null && paymentDetail!.paymentType == '2') {
        _character = PaymentMode.BankDetail;
      }
      else {
        _character = PaymentMode.Paypal;
      }
      _banknameController.text = paymentDetail!.bankName??'';
      _accnumberController.text = paymentDetail!.accountNo??'';
      _ifsccodeController.text = paymentDetail!.bankCode??'';
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    double height = size(context).height;
    return Scaffold(
        backgroundColor: backgroundColor,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              ... AppToolbar(buildContext,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Image(
                            image: ImageRes.backIcon, height: 25, width: 25)),
                     Expanded(
                       child: Padding(
                         padding: const EdgeInsets.only(right: 25),
                         child: Align( alignment: Alignment.center,child: Text(resource.paymentMethod.tr,
                          style: TextStyle(
                              color: CupertinoColors.white,
                              fontFamily: narrowmedium,
                              fontSize: 20,
                              letterSpacing: 4.0))),
                       ),
                     ),
                  ],
                  showStatusBar: true),

              Expanded(
                child: Form(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                children: [
                                  SizedBox(
                                    height: height* 0.01,
                                  ),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
                                    title: Text(resource.paypal.tr, style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: narrowbook,
                                      color: lablecolor
                                    )),
                                    leading: Radio<PaymentMode>(
                                      value: PaymentMode.Paypal,
                                      groupValue: _character,
                                      onChanged: (PaymentMode? value) {
                                        if (value != null) {
                                          _character = value;
                                          // _paypalidController.text = '';
                                          paypalidError = null;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height* 0.01,
                                  ),
                                  Visibility(
                                    visible: paypaldetailshow(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        cursorColor: Colors.blue,
                                        onChanged: (text) {
                                          if (paypalidError != null) {
                                            setState(() {
                                              paypalidError = null;
                                            });
                                          }
                                        },
                                        decoration: inputInputDecoration(placeholder: resource.paypalIdPlaceholder.tr).copyWith(errorText: paypalidError),
                                        style: mTextFieldTS,
                                        controller: _paypalidController,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
                                    title: Text(resource.bankTransfer.tr, style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: narrowbook,
                                        color: lablecolor
                                    ),),
                                    leading: Radio<PaymentMode>(
                                      value: PaymentMode.BankDetail,
                                      groupValue: _character,
                                      onChanged: (PaymentMode? value) {
                                        if (value != null) {
                                          _character = value;

                                          // _banknameController.text = '';
                                          // _accnumberController.text = '';
                                          // _ifsccodeController.text = '';

                                          bankControllerError = null;
                                          accountControllerError = null;
                                          ifscControllerError = null;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  Visibility(
                                    visible: bankDetailshow(),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            cursorColor: Colors.blue,
                                            onChanged: (text) {
                                              if (bankControllerError != null) {
                                                setState(() {
                                                  bankControllerError = null;
                                                });
                                              }
                                            },
                                            decoration: inputInputDecoration(placeholder: resource.bankNamePlaceholder.tr).copyWith(errorText: bankControllerError),
                                            style: mTextFieldTS,
                                            controller: _banknameController,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            cursorColor: Colors.blue,
                                            onChanged: (text) {
                                              if (accountControllerError != null) {
                                                setState(() {
                                                  accountControllerError = null;
                                                });
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: inputInputDecoration(placeholder: resource.accNumberPlaceholder.tr).copyWith(errorText: accountControllerError),
                                            style: mTextFieldTS,
                                            controller: _accnumberController,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            cursorColor: Colors.blue,
                                            onChanged: (text) {
                                              if (ifscControllerError != null) {
                                                setState(() {
                                                  ifscControllerError = null;
                                                });
                                              }
                                            },
                                            decoration: inputInputDecoration(placeholder: resource.bankCodePlaceholder.tr).copyWith(errorText: ifscControllerError),
                                            style: mTextFieldTS,
                                            obscureText: false,
                                            controller: _ifsccodeController,
                                            autocorrect: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: size(context).height * 0.4,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: GestureDetector(
                                              onTap: (){
                                                bool isValid = hasValidValue();
                                                if (isValid) {
                                                  handlePaymentMethod(buildContext);
                                                }
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  borderRadius : BorderRadius.all(
                                                    Radius.circular(50.0),
                                                  ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                    colors: [
                                                      btnEndColor,
                                                      btnStartColor,
                                                    ],
                                                  ),
                                                ),
                                                height: 80,
                                                width: size(buildContext).width,
                                                child: Center(
                                                  child: Text(
                                                    resource.save.tr,
                                                    style: boldBtnStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: bottomViewPad(buildContext),),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),
        ));
  }

  void handlePaymentMethod(BuildContext buildContext) {

    Map<String, dynamic> setupPaymentMethodRequestJson = {
      RequestParam.kUserEmail : _user.userEmail,
      RequestParam.kPaymentType : (_character!.index + 1).toString(),
      RequestParam.kPaymentid: paymentDetail != null ? paymentDetail!.paymentDetailId : '',
      RequestParam.kPaypalid : _paypalidController.text,
      RequestParam.kBankName : _banknameController.text,
      RequestParam.kAccountNumber : _accnumberController.text,
      RequestParam.kBankCode : _ifsccodeController.text,
    };

     _authModel
        .setupPaymentMethod(
        context: buildContext,
        keyLoader: _globalKey,
        apiName: ServiceUrl.kUpdatePaymentTransactionDetail,
        setupPaymentMethodRequestJson: setupPaymentMethodRequestJson)
        .then((response) async {
    
          if (response != null) {
            _user.payment ??=[];
            if(paymentDetail == null){
              AppUtil.toast(response.message);
              await response.data.forEach((v) {
                _user.payment!.add(PaymentDetail.fromJson(v));
              });

              // _user.payment = response.data as List<PaymentDetail>;
              userDefault.saveUser(_user);
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.pop(buildContext);
              });
            }
            else{
              AppUtil.toast(response.message);

              PaymentDetail pd = _user.payment!.first;
              PaymentDetail paymentDetail = PaymentDetail();
              paymentDetail.paymentDetailId = pd.paymentDetailId;
              paymentDetail.userEmail = pd.userEmail;
              paymentDetail.paymentType = (_character!.index + 1).toString();

              paymentDetail.paypalId = _paypalidController.text.trim().toString();
              paymentDetail.bankName = _banknameController.text.trim().toString();
              paymentDetail.accountNo = _accnumberController.text.trim().toString();
              paymentDetail.bankCode = _ifsccodeController.text.trim().toString();

              _user.payment =[];
              _user.payment!.add(paymentDetail);

              userDefault.saveUser(_user);
              await Future.delayed(const Duration(milliseconds: 500));
              Navigator.pop(buildContext);
              Get.back();
            }
          }
    });
  }

  bool bankDetailshow() {
    if (_character == PaymentMode.Paypal) {
      return false;
    } else {
      return true;
    }
  }

  bool paypaldetailshow() {
    if (_character == PaymentMode.BankDetail) {
      return false;
    } else {
      return true;
    }
  }

  bool hasValidValue() {
    bool isValid = false;

    RegExp paypalidExp =  RegExp(r'^[\w.-]+@[\w-]+$');
    RegExp banknameExp =  RegExp(r'^[a-z A-Z,.\-]+$');
    RegExp accnoExp =  RegExp(r'^\d{9,18}$');
    RegExp ifscExp =  RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

    if (_character == PaymentMode.Paypal) {
      if (_paypalidController.text.isEmpty) {
        paypalidError = resource.paypalIDValidation.tr;
      }
      else if(!paypalidExp.hasMatch(_paypalidController.text)){
        paypalidError = resource.paypalIDValidValidation.tr;
      }
      else {
        isValid = true;
      }

      setState(() {});
      return isValid;

    } else {

      if (_banknameController.text.isEmpty) {
        bankControllerError = resource.bankNameValidation.tr;
      }
      else if(_accnumberController.text.isEmpty) {
        accountControllerError = resource.accNumberValidation.tr;
      }
      else if(_ifsccodeController.text.isEmpty){
        ifscControllerError = resource.bankCodeValidation.tr;
      }
      else if(!banknameExp.hasMatch(_banknameController.text)){
        bankControllerError = resource.bankNameValidValidation.tr;
      }
      /*else if(!accnoExp.hasMatch(_accnumberController.text)){
        accountControllerError = 'Please Enter Valid Account Number!';
      }
      else if(!ifscExp.hasMatch(_ifsccodeController.text)){
        ifscControllerError = 'Please Enter Valid IFSC Code!';
      }*/
      else {
        isValid = true;
      }

      setState(() {});
      return isValid;
    }
  }

}
