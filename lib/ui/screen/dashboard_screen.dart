import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/notification_service.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import '../../helper/post_controller.dart';
import '../../model/brandCategory/brandCategory.dart';
import '../../model/brandCategory/category.dart';
import '../../model/brandFilter/AllBrandResponse.dart';
import '../../model/brandFilter/brand.dart';
import '../../service/auth.dart';
import 'mail_screen.dart';
import 'post_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

PostScreen? postscreen;
String? dropDownValue = '0';
String? categoryDropDownValue = '0';
final List<Brand> filterAllBrandList = [];
final List<Category> filterCategoryList = [];
int currVal = 1;
//TODO 08/04/2022 currentValue
String currentValue = 'Most Recent';
Locale? devLocale = Get.locale;
//TODO 08/04/2022 currentValue

final GlobalKey<MailScreenState> _mailKey = GlobalKey();
List<GroupModel> group = [
  GroupModel(
    key: resource.sortMostRecent,
    value: 'Most Recent',
    index: 1,
  ),
  GroupModel(
    key: resource.sortPopularity,
    value: 'Popularity',
    index: 2,
  ),
  GroupModel(
    key: resource.sortRelevance,
    value: 'Relevance',
    index: 3,
  ),
  GroupModel(
    key: resource.sortLastChance,
    value: 'Last Chance',
    index: 4,
  ),
];
bool? isLanguageSwitch = false;

class DashboardScreen extends StatefulWidget {
  int? initialPage;
  bool? isFirstTime;

  DashboardScreen({Key? key, this.initialPage, this.isFirstTime})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey<PostScreenState> _myKey = GlobalKey();
  late final TabController _tabController = TabController(
      length: 4, vsync: this, initialIndex: widget.initialPage ?? 0);

  //final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final AuthModel _authModel = Get.find();
  UserDefault userDefault = Get.find();
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  final PostController postController = Get.find();
  bool allDataLoaded = false;
  int pageCount = 0;
  late bool showIcon = false;

  //TODO 06/04/2022 remove tr here
  String currentTitle = resource.tabHome;
  final List<String> titleList = [
    resource.tabHome,
    resource.tabMail,
    resource.tabWallet,
    resource.tabProfile
  ];

  @override
  void initState() {
    NotificationService().requestPermissions();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if (widget.isFirstTime ?? false) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(resource.welcomeMessage.tr)));
      }
      //TODO 30/03/2022
      await generateBrandList(context);
      await generateCategoryList(context);
      setState(() {});
      //TODO Over
    });
    if (widget.initialPage != null) {
      currentTitle = titleList[widget.initialPage!];
    }
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _tabController.addListener(changeTitle);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              headerStartColor,
              headerEndColor,
            ],
          ),
        ),

        //TODO 16/03/2022 put toolbar here
        child: Material(
          child: Column(
            children: [
              ...AppToolbar(context,
                  children: [
                    Visibility(
                      visible: showIcon,
                      child: IconButton(
                          onPressed: () {
                            showFilterByDailog(
                                buildContext, resource.sortByTitle.tr,
                                (bool action) {
                              if (action) {
                                // Navigator.pop(context);
                              }
                            });
                          },
                          icon: Image(
                              image: ImageRes.menuImg, height: 25, width: 25)),
                    ),
                    Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              currentTitle.tr.toUpperCase(),
                              style: headerStyle,
                            ))),
                    Visibility(
                      visible: showIcon,
                      child: IconButton(
                          onPressed: () {
                            showFilterDailog(
                                buildContext, resource.filterTitle.tr,
                                (bool action) {
                              //TODO 08/04/2022 currentValue
                              setState(() {
                                if (action) {
                                  postController.clearPost();
                                  PostScreenState.filterPost(
                                      context,
                                      dropDownValue!,
                                      categoryDropDownValue!,
                                      currentValue);
                                } else {
                                  postController.clearPost();
                                  PostScreenState.filterPost(
                                      context, '0', '0', currentValue);
                                  dropDownValue = '0';
                                  categoryDropDownValue = '0';
                                }
                              });
                            });
                          },
                          icon: dropDownValue == '0' &&
                                  categoryDropDownValue == '0'
                              ? Image(
                                  image: ImageRes.filterOutlinedImg,
                                  height: 25,
                                  width: 25)
                              : Image(
                                  image: ImageRes.filterOutlinedFilledImg,
                                  height: 25,
                                  width: 25)),
                    ),
                  ],
                  showStatusBar: true),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    extendBody: true,
                    backgroundColor: CupertinoColors.white,
                    body: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        PostScreen(
                          key: _myKey,
                          onback: (cons) {
                            if (cons == 1) {
                              _tabController.animateTo(1);
                            } else if (cons == 0) {
                              _tabController.animateTo(0);
                            }
                          },
                        ),
                         MailScreen(
                          key: _mailKey,
                        ),
                        const WalletScreen(),
                        const ProfileScreen(),
                      ],
                    ),
                    bottomNavigationBar: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: tabshadowcolor,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 10), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TabBar(
                            controller: _tabController,
                            indicatorColor: headerStartColor,
                            onTap: (index) {
                              _tabController.animateTo(index);
                              showIcon = (index == 0) ? true : false;
                              if(_tabController.index == 0){
                                _myKey.currentState!.onRefresh(context);
                              }
                              setState(() {});
                            },
                            tabs: [
                              // TODO 14/03/2022 change post to missions
                              Tab(
                                icon: Image(
                                    image: ImageRes.postImg,
                                    height: 20,
                                    width: 20),
                                child: Text(titleList[0].tr,
                                    style: TextStyle(
                                        fontFamily: narrowmedium,
                                        color: tablablecolor,
                                        fontSize: 18),
                                    softWrap: false,
                                    overflow: TextOverflow.fade),
                              ),
                              Tab(
                                icon: Image(
                                    image: ImageRes.mailImg,
                                    height: 20,
                                    width: 20),
                                child: Text(titleList[1].tr,
                                    style: TextStyle(
                                        fontFamily: narrowmedium,
                                        color: tablablecolor,
                                        fontSize: 18),
                                    softWrap: false,
                                    overflow: TextOverflow.fade) ,
                              ),
                              Tab(
                                icon: Image(
                                    image: ImageRes.walletImg,
                                    height: 20,
                                    width: 20),
                                child: Text(titleList[2].tr,
                                    style: TextStyle(
                                        fontFamily: narrowmedium,
                                        color: tablablecolor,
                                        fontSize: 18),
                                    softWrap: false,
                                    overflow: TextOverflow.fade),
                              ),
                              Tab(
                                icon: Image(
                                    image: ImageRes.profileImg,
                                    height: 20,
                                    width: 20),
                                child: Text(titleList[3].tr,
                                    style: TextStyle(
                                        fontFamily: narrowmedium,
                                        color: tablablecolor,
                                        fontSize: 18),
                                    softWrap: false,
                                    overflow: TextOverflow.fade),
                              ),
                            ],
                          ),

                          /*CurvedNavigationBar(
                            key: _bottomNavigationKey,
                            index: 2,
                            height: 60.0,
                            items: <Widget>[
                              Tab(
                                child: Text('posts'.tr,
                                    style: TextStyle(fontFamily: narrowmedium,color: tablablecolor), softWrap: false, overflow: TextOverflow.fade),
                                icon: Image(image: ImageRes.postImg, height: 20, width: 20),
                              ),
                              Tab(
                                child: Text('mail'.tr,
                                    style: TextStyle(fontFamily: narrowmedium,color: tablablecolor), softWrap: false, overflow: TextOverflow.fade),
                                icon: Image(image: ImageRes.mailImg, height: 20, width: 20),
                              ),
                              DecoratedBox(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [btnStartColor, btnEndColor],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  height: 65,
                                  width: 65,
                                  child: IconButton(
                                    icon: Image(image: ImageRes.buttonlogoImg, height: 30, width: 30),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text('wallet'.tr,
                                    style: TextStyle(fontFamily: narrowmedium,color: tablablecolor), softWrap: false, overflow: TextOverflow.fade),
                                icon: Image(image: ImageRes.walletImg, height: 20, width: 20),
                              ),
                              Tab(
                                child: Text('profile'.tr,
                                    style: TextStyle(fontFamily: narrowmedium,color: tablablecolor), softWrap: false, overflow: TextOverflow.fade),
                                icon: Image(image: ImageRes.profileImg, height: 20, width: 20),
                              ),
                            ],
                            color: Colors.white,
                            buttonBackgroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            animationCurve: Curves.easeInOut,
                            animationDuration: const Duration(milliseconds: 10),
                            onTap: (index) {
                              if (index != 2) {
                                _tabController.index = index;
                              }else{
                                print('Logo Pressed'); // TODO handle on Logo press
                              }
                            },
                            letIndexChange: (index) => true,
                          ),*/
                          Container(
                            color: CupertinoColors.white,
                            height: MediaQuery.of(context).viewPadding.bottom,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showFilterDailog(
      BuildContext context, String title, Function(bool action) action) {
    Text titleText = Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, height: 1.4),
      textAlign: TextAlign.start,
    );

    // show the dialog
    showDialog(
      //barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: titleText,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    //TODO 06/04/2022
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(resource.filterCategory.tr,
                          style: TextStyle(
                              fontSize: 20,
                              color: lablecolor,
                              fontFamily: narrowbook)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all()),
                          child: DropdownButtonHideUnderline(
                            child: SizedBox(
                              height: 50.0,
                              width: 170.0,
                              child: DropdownButton<String>(
                                  value: categoryDropDownValue,
                                  isExpanded: true,
                                  items: filterCategoryList
                                      .map((categoryName) => DropdownMenuItem(
                                          value: categoryName.category_id,
                                          child: Text(
                                              "${categoryName.category_name}")))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      categoryDropDownValue = value;
                                    });
                                  }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    //TODO 06/04/2022
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(resource.filterBrand.tr,
                          style: TextStyle(
                              fontSize: 20,
                              color: lablecolor,
                              fontFamily: narrowbook)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all()),
                          child: DropdownButtonHideUnderline(
                            child: SizedBox(
                              height: 50.0,
                              width: 170.0,
                              child: DropdownButton<String>(
                                value: dropDownValue,
                                isExpanded: true,
                                items: filterAllBrandList
                                    .map((brandName) => DropdownMenuItem(
                                        value: brandName.brand_id,
                                        child: Text("${brandName.brand_name}",softWrap: false,)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    dropDownValue = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            Row(
              //TODO 06/04/2022
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      action(false);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            yellowStartColor,
                            yellowEndColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 1),
                          child: Text(
                            resource.reset.tr.toUpperCase(),
                            style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 2,
                                fontFamily: narrowbold,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      action(true);
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 0, right: 10, bottom: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            btnEndColor,
                            btnStartColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 1),
                          child: Text(
                            resource.apply.tr.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 2,
                                fontFamily: narrowbold,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showFilterByDailog(
      BuildContext context, String title, Function(bool action) action) {
    Text titleText = Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, height: 1.4),
      textAlign: TextAlign.start,
    );

    // show the dialog
    showDialog(
      //barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: titleText,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: group
                    .map((t) => RadioListTile(
                          //TODO 06/04/2022 put tr here
                          title: Text(t.key.tr,
                              style: TextStyle(
                                  fontSize: 20, fontFamily: narrowbook)),
                          groupValue: currVal,
                          value: t.index,
                          onChanged: (int? val) {
                            setState(() {
                              currVal = val!;
                              //TODO 08/04/2022 currentValue
                              currentValue = t.value;
                              //TODO 08/04/2022 currentValue
                              PostScreenState.sortPost(context, currentValue,
                                  dropDownValue!, categoryDropDownValue!);
                            });
                          },
                        ))
                    .toList(),
              );
            },
          ),
          actions: [
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      action(true);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 50, right: 50, bottom: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              btnEndColor,
                              btnStartColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              resource.cancel.tr.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  fontFamily: narrowbold,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> generateBrandList(BuildContext? buildContext) async {
    Map<String, dynamic> getAllFilterBrandListRequestJson = {};

    log('generatePost $getAllFilterBrandListRequestJson');
    AllBrandResponse result = await _authModel.getAllFilterBrandList(
        context: buildContext,
        keyLoader: _globalKey,
        getAllFilterBrandRequestJson: getAllFilterBrandListRequestJson,
        apiName: ServiceUrl.kFilterAllBrandList);

    postController.postLoadState.value = 1;
    if (result == null) {
      allDataLoaded = true;
    }
    postController.isPageLoading = false;
    if (filterAllBrandList.isNotEmpty) {
      filterAllBrandList.clear();
    }
    if (result != null) {
      filterAllBrandList
          .add(Brand(brand_id: '0', brand_name: 'All', photo_name: ''));
      filterAllBrandList.addAll(result.data!);
      //TODO 30/03/2022
      if (_tabController.index == 0) {
        showIcon = true;
      }
      //TODO Over
    }
  }

  Future<void> generateCategoryList(BuildContext? buildContext) async {
    Map<String, dynamic> getAllCategoryListRequestJson = {};

    log('generatePost $getAllCategoryListRequestJson');
    brandCategory result = await _authModel.getCategoryList(
        context: buildContext,
        keyLoader: _globalKey,
        getAllCategoryRequestJson: getAllCategoryListRequestJson,
        apiName: ServiceUrl.kFilterCategoryList);

    postController.postLoadState.value = 1;
    if (result == null) {
      allDataLoaded = true;
    }
    postController.isPageLoading = false;
    if (filterCategoryList.isNotEmpty) {
      filterCategoryList.clear();
    }
    if (result != null) {
      filterCategoryList.add(Category(category_id: '0', category_name: 'All'));
      filterCategoryList.addAll(result.data!);
      //TODO 30/03/2022
      if (_tabController.index == 0) {
        showIcon = true;
      }
      //TODO Over
    }
  }

  void changeTitle() {
    setState(() {
      // get index of active tab & change current appbar title
      currentTitle = titleList[_tabController.index];
      showIcon = (_tabController.index == 0) ? true : false;
      if (_tabController.index == 0 && isLanguageSwitch!) {
        _myKey.currentState!.onRefresh(context);
      }
      if (_tabController.index == 1) {
        _mailKey.currentState!.onRefresh(context);
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_tabController.index == 0) {
      await SystemNavigator.pop();
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      _tabController.index = 0;
    });
    return _tabController.index == 0;
  }
}

class GroupModel {
  //TODO 08/04/2022 currentValue
  String key;
  String value;
  int index;

  GroupModel({required this.key, required this.value, required this.index});
}
