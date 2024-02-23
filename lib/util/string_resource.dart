import 'package:flutter/widgets.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

///String resources
class resource {

  static String ok = 'Ok';
  static String cancel = 'Cancel';
  static String yes = 'Yes';
  static String somethingWentWrong = 'somethingWentWrong';
  static String internetConnection = 'internetConnection';
  static String noInternetMessage = 'noInternetMessage';
  static String unableToConnect = 'unableToConnect';
  static String login = 'login';
  static String signIn = 'signIn';
  static String newAccountLinkTitle = 'newAccountLinkTitle';
  static String signInLink = 'signInLink';
  static String resetPassword = 'resetPassword';
  static String sentOtp = 'sentOtp';
  static String errorDuringCommunication = 'errorDuringCommunication';
  static String invalidRequest = 'invalidRequest';
  static String unauthorised = 'unauthorised';
  static String invalidInput = 'invalidInput';
  static String invalid = 'invalid';
  static String done = 'done';
  static String notFoundException = 'notFoundException';
  static String serverError = 'serverError';
  static String error = 'error';
  static String loginScreenTitle1 = 'loginScreenTitle1';
  static String isRequired = 'isRequired';
  static String enter = 'enter';
  static String userNotFound = 'userNotFound';
  static String emailNotFound = 'emailNotFound';
  static String contactAdministrator = 'contactAdministrator';
  static String emailNotActive = 'emailNotActive';
  static String socketException = 'socketException';
  static String status = 'status';
  static String responseCode = 'response_code';
  static String codeMessage = 'codemessage';
  static String iOSCodeMessage = 'ios_codemessage';
  static String notFound = 'notFound';
  static String message = 'message';
  static String submit = 'submit';
  static String reset = 'reset';
  static String apply = 'apply';
  static String save = 'save';
  static String signup = 'signup';
  static String otp = 'sendOtp';
  static String upload = 'upload';
  static String noSuitableAppFound = 'noSuitableAppFound';
  static String photoPermission = 'photoPermission';
  static String preview = 'preview';
  static String otpverification = 'otpverification';
  static String server_error = 'server_error';
  static String connectionTimeout = 'connectionTimeout';
  static String verifyAccount = 'verifyAccount';
  static String verify = 'verify';
  static String otpVerifiedSuccessfully = 'otpVerifiedSuccessfully';
  static String accountDeletedSuccessfully = 'accountDeletedSuccessfully';
  static String resendOtp = 'resendOtp';
  static String permanentAccDelete = 'permanentAccDelete';
  static String permanentAccDeleteDesc = 'permanentAccDeleteDesc';
  static String checkstatus = 'checkstatus';
  static String sureDelete = 'sureDelete';
  static String productpurchaseuploadscreenshot = 'productpurchaseuploadscreenshot';
  static String productreviewuploadscreenshot = 'productreviewuploadscreenshot';
  static String pendingverifyAccount = 'pendingverifyAccount';
  static String uploaddocumentsizetoast = 'uploaddocumentsizetoast';
  static String deleteTitle = 'deleteTitle';
  static String deleteContent = 'deleteContent';
  static String switchlanguagecontent = 'switchlanguagecontent';
  static String deleteUserDocTitle = 'deleteUserDocTitle';
  static String deleteUserDocContent = 'deleteUserDocContent';
  static String documentForVerification = 'documentForVerification';
  static String uploadUserDocTitle = 'uploadUserDocTitle';
  static String uploadUserDocContent = 'uploadUserDocContent';
  static String logoutTitle = 'logoutTitle';
  static String firstNamePlaceholder = 'firstNamePlaceholder';
  static String lastNamePlaceholder = 'lastNamePlaceholder';
  static String mobilePlaceholder = 'mobilePlaceholder';
  static String emailPlaceholder = 'emailPlaceholder';
  static String genderPlaceholder = 'genderPlaceholder';
  static String detailTitle = 'detailTitle';
  static String missingTitle = 'missingTitle';
  static String agreementTitle = 'agreementTitle';
  static String agreeTermsCondition = 'agreeTermsCondition';
  static String ethnicityPlaceholder = 'ethnicityPlaceholder';
  static String dateOfBirthPlaceholder = 'dateOfBirthPlaceholder';
  static String homeCountryPlaceholder = 'homeCountryPlaceholder';
  static String paypalIdPlaceholder = 'paypalIdPlaceholder';
  static String bankNamePlaceholder = 'bankNamePlaceholder';
  static String accNumberPlaceholder = 'accNumberPlaceholder';
  static String bankCodePlaceholder = 'bankCodePlaceholder';
  static String genderValidation = 'genderValidation';
  static String nameValidation = 'nameValidation';
  static String paypalIDValidation = 'paypalIDValidation';
  static String paypalIDValidValidation = 'paypalIDValidValidation';
  static String bankNameValidValidation = 'Please Enter Valid Bank Name';
  static String bankNameValidation = 'bankNameValidation';
  static String accNumberValidation = 'accNumberValidation';
  static String bankCodeValidation = 'bankCodeValidation';
  static String firstNameValidation = 'firstNameValidation';
  static String lastNameValidation = 'lastNameValidation';
  static String birthDateValidation = 'birthDateValidation';
  static String dateOfBirthValidation = 'dateOfBirthValidation';
  static String ethinicityValidation = 'ethinicityValidation';
  static String currencyValidation = 'currencyValidation';
  static String homeCountryValidation = 'homeCountryValidation';
  static String otpValidation = 'otpValidation';
  static String emailValidation = 'emailValidation';
  static String passwordValidation = 'passwordValidation';
  static String verifyOtp = 'verifyOtp';
  static String passwordValidValidation = 'passwordValidValidation';
  static String confirmPasswordValidation = 'confirmPasswordValidation';
  static String passwordMismatch = 'passwordMismatch';
  static String emailValidValidation = 'emailValidValidation';
  static String termsAndConditionValidation = 'termsAndConditionValidation';
  static String pickImagePermission = 'pickImagePermission';
  static String accessPhotoPermission = 'accessPhotoPermission';
  static String userDocumentTitle = 'userDocumentTitle';
  static String askToDocument = 'askToDocument';
  static String filterTitle = 'filterTitle';
  static String filterCategory = 'filterCategory';
  static String userDocTitleForUploading = 'userDocTitleForUploading';
  static String purchase = 'purchase';
  static String review = 'review';
  static String uploadPurchase = 'uploadPurchase';
  static String uploadReview = 'uploadReview';
  static String filterBrand = 'filterBrand';
  static String tabHome = 'tabHome';
  static String tabMail = 'tabMail';
  static String tabWallet = 'tabWallet';
  static String tabProfile = 'tabProfile';
  static String historyNotFound = 'historyNotFound';
  static String paymentHistory = 'paymentHistory';
  static String totalBalanceTitle = 'totalBalanceTitle';
  //TODO 15/04/2022
  static String totalPendingBalanceTitle = 'totalPendingBalanceTitle';

  static String sortByTitle = 'sortByTitle';
  static String deadline = 'deadline';
  static String productsLeft = 'productsLeft';
  static String sortMostRecent = 'sortMostRecent';
  static String sortPopularity = 'sortPopularity';
  static String sortRelevance = 'sortRelevance';
  static String sortLastChance = 'sortLastChance';
  static String userGreting = 'userGreting';
  static String buyTheProduct = 'buyTheProduct';
  static String buyTheProductDesc = 'buyTheProductDesc';
  static String uploadProofPurchase = 'uploadProofPurchase';
  static String uploadProofPurchaseDesc = 'uploadProofPurchaseDesc';
  static String writeReview = 'writeReview';
  static String writeReviewDesc = 'writeReviewDesc';
  static String getPaid = 'getPaid';
  static String getPaidDesc = 'getPaidDesc';
  static String followTitle = 'followTitle';
  static String followedTitle = 'followedTitle';
  static String followDesc = 'followDesc';
  static String followSteps = 'followSteps';
  static String step = 'step';
  static String getProductTitle = 'getProductTitle';
  static String interestedBtnTitle = 'interestedBtnTitle';
  static String notInterestedBtnTitle = 'notInterestedBtnTitle';
  static String cancelBtnTitle = 'cancelBtnTitle';
  static String paymentSetup = 'paymentSetup';
  static String talkToUS = 'talkToUS';
  static String feedback = 'feedback';
  static String termsAndConditions = 'termsAndConditions';
  static String deleteAccount = 'deleteAccount';
  static String switchLanguage = 'switchLanguage';
  static String logoutContent = 'logoutContent';
  static String buzzleTitle = 'buzzleTitle';
  static String family = 'family';
  static String emailPlacholder = 'emailPlacholder';
  static String passwordPlacholder = 'passwordPlacholder';
  static String namePlacholder = 'namePlacholder';
  static String forgotPassword = 'forgotPassword';
  static String changePassword = 'changePassword';
  static String confirmPassword = 'confirmPassword';
  static String passwordContain = 'passwordContain';
  static String recoverPassword = 'recoverPassword';
  static String forgotPasswordLinkTitle = 'forgotPasswordLinkTitle';
  static String splashScreenTitle1 = 'splashScreenTitle1';
  static String splashScreenTitle2 = 'splashScreenTitle2';
  static String splashScreenTitle3 = 'splashScreenTitle3';
  static String splashScreenTitle4 = 'splashScreenTitle4';
  static String termsAndConditionTitle = 'termsAndConditionTitle';
  static String ratingReviewContent = 'ratingReviewContent';
  static String elegibleContent = 'elegibleContent';
  static String emailBodyContent = 'emailBodyContent';
  static String emailSubjectContent = 'emailSubjectContent';
  static String welcomeMessage = 'welcomeMessage';
  static String mailNotFound = 'mailNotFound';
  static String postNotFound = 'postNotFound';
  static String eligible = 'eligible';
  static String purchaseReceipt = 'purchaseReceipt';
  static String productReview = 'productReview';
  static String postVerified = 'postVerified';
  static String spotAmount = 'spotAmount';
  static String paymentMethod = 'paymentMethod';
  static String paypal = 'paypal';
  static String bankTransfer = 'bankTransfer';
  static String personalDetails = 'personalDetails';
  static String uploadGovernmentDocument = 'uploadGovernmentDocument';
  static String optionalDocument = 'optionalDocument';
  static String close = 'close';
  static String tryAgain = 'tryAgain';
  static String retry = 'retry';
  static String pushNotification = 'pushNotification';
  static String pleaseWaitMessage = 'pleaseWaitMessage';
  static String laterBtnText = 'laterBtnText';
  static String writeFeedback = 'writeFeedback';

  static String termsAndCondition = 'https://docs.google.com/document/d/1RcCiF2r2OaAxXFVt1RdL1hu-vuVu0KGVpmgQ0N9e12w/edit?usp=sharing ';

}

class ServiceUrl {

  static const String SERVER_URL =  'https://buzzle.website/buzzle/rate_review_app/rate_review_api/';
  static const String DOC_IMAGE_DIR_URL =  'https://buzzle.website/buzzle/rate_review_app/rate_review_images/documents_images/';
  // static const String SERVER_URL =  'https://selfmentor.net/testapk/rate_review_app_production/rate_review_api/';
  // static const String DOC_IMAGE_DIR_URL =  'https://selfmentor.net/testapk/rate_review_app_production/rate_review_images/documents_images/';
  // static const String kSubHost = SERVER_URL;


  static const String simpleLoginRegister = 'simple_login_Register';
  static const String simpleLoginCheck = 'simple_login_check';
  static const String kVerifyOtpForSignUp = 'verifyOtpForSignUp';
  static const String kNewProfileUpdate = 'newProfileUpdate';


  /// Forget Password
  static const String kForgetPassword = 'forgetPassword';
  //TODO 08/04/2022
  static const String kResendSignUpOTP = 'resendSignUpOTP';
  static const String kVerifyForgetPasswordOtp = 'verifyForgetPasswordOtp';
  static const String kResetPassword = 'resetPassword';
  static const String kUserProfileUpdate = 'userProfileUpdate';


  /// Delete Account
  static const String kDeleteAccountPasswordOtp = 'verifyOtpForUserDelete';
  static const String kDeleteAccount = 'deleteUserOtpSend';

  
  static const String kGetUserProfile = 'getUserProfile';
  static const String kGetAllPostList = 'getAllPostList';
  static const String kNotInterestedPost = 'insertNotInterestedUser';
  static const String kCancelPost = 'cancelUserEligible';
  static const String kGetAllFollowUnfollowList = 'user_follower_insert';
  static const String kGetUserInterestedPostList = 'getUserInterestedPostList';
  static const String kGetAllPaymentHistoryList = 'getUserPaymentHistoryData';

  // UPDATE FIREBASE TOKEN
  static const String kUpdateFirebaseToken = 'updateFirebaseToken';

  static const String kGetUserDocumentList = 'getUserDocumentList';
  static const String kUploadUserDocuments = 'upload_user_documents';
  static const String kUpdatePaymentTransactionDetail = 'user_payment_update';
  static const String kUploadTransactionDocuments = 'product_transaction_upload';
  static const String kDeleteUserDocument = 'deleteUserDocument';

  // Filter
  static const String kFilterAllBrandList = 'getAllBrands';
  static const String kFilterCategoryList = 'getAllCategories';


  static const String kProductTransactionDelete = 'product_transaction_delete';
  static const String kGetUserWalletHistory = 'getUserWalletHistory';

  static const String kGetPostById = 'getPostById';


  static const String PRIVACY_POLICY = 'https://sites.google.com/view/';
  static const String TERMS_OF_SERVICE = 'https://sites.google.com/view/';


}

class RequestParam {
  static const String kToken = 'token';
  static const String kFirebaseToken = 'firebase_token';
  static const String kUserEmail = 'user_email';
  static const String kDocOrd = 'doc_ord';
  static const String kUserDocument = 'user_document';
  static const String kDocumentId = 'document_id';
  static const String kTranDocId = 'trandoc_id';
  static const String kTranId = 'tran_id';
  static const String kTransId = 'trans_id';
  static const String kDocType = 'doc_type';
  static const String kPostId = 'postid';
  static const String kUserName = 'user_name';
  static const String kFullName = 'full_name';
  static const String kMobile = 'mobile';
  static const String kGender = 'gender';
  static const String kEthnicity = 'ethnicity';
  static const String kDateOfBirth = 'dateof_birth';
  static const String kHomeCountry = 'home_country';
  static const String kCurrency = 'currency_code';
  static const String kAge = 'age';
  static const String kPaymentType = 'payment_type';
  static const String kPaymentid = 'payment_detail_id';
  static const String kPaypalid = 'paypal_id';
  static const String kBankName = 'bank_name';
  static const String kAccountNumber = 'account_no';
  static const String kBankCode = 'bank_code';
  static const String kPageCount = 'page_count';
  static const String kUserId = 'user_id';
}

class RequestTransaction {
  static const String kToken = 'token';
  static const String kUserEmail = 'user_email';
  static const String kUserDocument = 'user_document';
  static const String kUserDocumentType = 'doc_type';
  static const String kPostId = 'postid';
  static const String kPostTitle = 'post_title';
}

///Images resources
class ImageRes {
  static var appIcon = const AssetImage('assets/images/logo.png');
  static var otpImg = const AssetImage('assets/images/otp.png');
  static var pdfImg = const AssetImage('assets/images/pdf_img.png');
  static var noImageFound = const AssetImage('assets/images/image_not_found.png');
  static var postImg = const AssetImage('assets/images/posts.png');
  static var mailImg = const AssetImage('assets/images/mail.png');
  static var walletImg = const AssetImage('assets/images/wallet.png');
  static var profileImg = const AssetImage('assets/images/profile.png');
  static var buttonlogoImg = const AssetImage('assets/images/logo_button.png');
  static var discontImg = const AssetImage('assets/images/discount.png');
  static var heartImg = const AssetImage('assets/images/heart.png');
  static var coloredBGImg = const AssetImage('assets/images/bg.jpg');
  static var menuImg = const AssetImage('assets/images/menu.png');
  static var filterOutlinedImg = const AssetImage('assets/images/filter_outlined.png');
  static var filterOutlinedFilledImg = const AssetImage('assets/images/filter_filled.png');
  static var filterFilledImg = const AssetImage('assets/images/filter_filled.png');
  static var otpVerificationImg = const AssetImage('assets/images/otpverification.png');
  static var uploadimage = const AssetImage('assets/images/upload.png');
  static var shareIcon = const AssetImage('assets/images/share.png');
  static var backIcon = const AssetImage('assets/images/back.png');

  // svg files
  static String pendingSVG = 'assets/images/svg/pending.svg';
  static String verifiedSVG = 'assets/images/svg/verified.svg';
  static String unverifiedSVG = 'assets/images/svg/unverified.svg';

}
