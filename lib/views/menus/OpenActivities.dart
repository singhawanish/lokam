import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:ioclcustomerconnect/utils/networkUtil.dart';
import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import '../../main.dart';
import '../loginPage.dart';
import '../userVerification.dart';
import 'OpenActivitiesHelper/open_activities_list_view.dart';

class OpenActivitiesPage extends StatefulWidget {
  final String period;
  final String type;
  final VoidCallback callback;

  OpenActivitiesPage({Key key, this.period, this.type, this.callback})
      : super(key: key);

  @override
  _OpenActivitiesPageState createState() => _OpenActivitiesPageState();
}

class _OpenActivitiesPageState extends State<OpenActivitiesPage>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<OpenActivityListData> openActivitiesList = [];
  List<OpenActivityListData> searchOpenActivitiesList = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = new TextEditingController();
  bool openActivitiesListPresent = true;

  String jwt;
  bool _DSARole = false;

  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
  }

  void getOpenActivities() async {
    searchController.clear();
    onSearchTextChanged('');
    searchOpenActivitiesList.clear();
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
      if ((element as String) == 'DSA') {
        _DSARole = true;
      }
    });
    var internet = await checkInternet();
    if (!internet) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('No Internet Connectivity.'),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      var response = await http.get(
        Uri.parse(BASE_URI +
            (_DSARole
                ? '/DSA/getOpenActivities'
                : '/HMOFMO/getOpenActivities')),
        headers: {
          "Accept": "application/json",
          "Authorization": jwt,
          'Content-type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          List<OpenActivityListData> std = [];
          Map<String, dynamic> map = jsonDecode(response.body);
          List<dynamic> data = map['data'];
          data.forEach((element) {
            std.add(OpenActivityListData(
              companyName: element['companyName'] == null
                  ? ''
                  : element['companyName'] as String,
              leadID:
                  element['leadId'] == null ? '' : element['leadId'] as String,
              activityID: element['activityId'] == null
                  ? ''
                  : element['activityId'] as String,
              description: element['description'] == null
                  ? ''
                  : element['description'] as String,
              type: element['type'] == null ? '' : element['type'] as String,
              dueDate: element['dueDate'] == null
                  ? ''
                  : element['dueDate'] as String,
              fromDate: element['fromDate'] == null
                  ? ''
                  : element['fromDate'] as String,
              toDate:
                  element['toDate'] == null ? '' : element['toDate'] as String,
              callStartTime: element['callStartTime'] == null
                  ? ''
                  : element['callStartTime'] as String,
              activityOwner: element['activityOwner'] == null
                  ? ''
                  : element['activityOwner'] as String,
              dateUpdated: element['dateUpdated'] == null
                  ? ''
                  : element['dateUpdated'] as String,
              activityCreationLat: element['activityCreationLat'] == null
                  ? ''
                  : element['activityCreationLat'] as String,
              activityCreationLong: element['activityCreationLong'] == null
                  ? ''
                  : element['activityCreationLong'] as String,
            ));
          });

          openActivitiesList = std;
          if (openActivitiesList.length == 0) {
            openActivitiesListPresent = false;
          }
        });
      } else if (response.statusCode == 403) {
        await storage.delete(key: 'jwt');
        await storage.delete(key: 'name');
        await storage.delete(key: 'designation');
        await storage.delete(key: 'empCode');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UserVerificationPage()),
          (_) => false,
        );
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('Server Not Reachable.'),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    getOpenActivities();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CustomTheme.buildLightTheme(),
      child: Container(
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: <Widget>[
                    getAppBarUI(),
                    getTimeDateUI(),
                    Expanded(
                      child: NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      color: CustomTheme.buildLightTheme()
                                          .backgroundColor,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 1, bottom: 1),
                                        //Here you can add date selection in Row Widget
                                        child: Row(),
                                      ),
                                    ),
                                  ],
                                );
                              }, childCount: 1),
                            ),
                          ];
                        },
                        body: Container(
                          color: CustomTheme.buildLightTheme().backgroundColor,
                          child: openActivitiesList.length != 0
                              ? searchOpenActivitiesList.length != 0 ||
                                      searchController.text.isNotEmpty
                                  ? RefreshIndicator(
                                      onRefresh: () async {
                                        setState(() {
                                          getOpenActivities();
                                        });
                                      },
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount:
                                            searchOpenActivitiesList.length,
                                        padding: const EdgeInsets.only(top: 8),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final int count =
                                              // hotelList.length > 10 ? 10 : hotelList.length;
                                              searchOpenActivitiesList.length;
                                          final Animation<double>
                                              animation = Tween<double>(
                                                      begin: 0.0, end: 1.0)
                                                  .animate(CurvedAnimation(
                                                      parent:
                                                          animationController,
                                                      curve: Interval(
                                                          (1 / count) * index,
                                                          1.0,
                                                          curve: Curves
                                                              .fastOutSlowIn)));
                                          animationController.forward();
                                          return OpenActivityListView(
                                              callback: getOpenActivities,
                                              openActivityData:
                                                  searchOpenActivitiesList[
                                                      index],
                                              animation: animation,
                                              animationController:
                                                  animationController,
                                              parentContext:
                                                  _scaffoldKey.currentContext,
                                              refreshCall: getOpenActivities,
                                              tab: "1");
                                        },
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: () async {
                                        setState(() {
                                          getOpenActivities();
                                        });
                                      },
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: openActivitiesList.length,
                                        padding: const EdgeInsets.only(top: 8),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final int count =
                                              // hotelList.length > 10 ? 10 : hotelList.length;
                                              openActivitiesList.length;
                                          final Animation<double>
                                              animation = Tween<double>(
                                                      begin: 0.0, end: 1.0)
                                                  .animate(CurvedAnimation(
                                                      parent:
                                                          animationController,
                                                      curve: Interval(
                                                          (1 / count) * index,
                                                          1.0,
                                                          curve: Curves
                                                              .fastOutSlowIn)));
                                          animationController.forward();
                                          return OpenActivityListView(
                                            callback: getOpenActivities,
                                            openActivityData:
                                                openActivitiesList[index],
                                            animation: animation,
                                            animationController:
                                                animationController,
                                            parentContext:
                                                _scaffoldKey.currentContext,
                                            refreshCall: getOpenActivities,
                                            tab: "1",
                                          );
                                        },
                                      ),
                                    )
                              : Center(
                                  child: openActivitiesListPresent
                                      ? CircularProgressIndicator()
                                      : Text(
                                          'No Entry Present.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22,
                                          ),
                                        )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTimeDateUI() {
    return Container(
        color: CustomTheme.buildLightTheme().backgroundColor,
        child: _buildSearchBox());
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: new Card(
        child: new ListTile(
          leading: new Icon(Icons.search,
              color: CustomTheme.buildLightTheme().primaryColor),
          title: new TextField(
            controller: searchController,
            decoration: new InputDecoration(
                hintText: 'Search', border: InputBorder.none),
            onChanged: onSearchTextChanged,
          ),
          trailing: new IconButton(
            icon: new Icon(Icons.cancel,
                color: CustomTheme.buildLightTheme().primaryColor),
            onPressed: () {
              searchController.clear();
              onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    searchOpenActivitiesList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    openActivitiesList.forEach((userDetail) {
      if (userDetail.description.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.type.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.companyName.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.activityOwner.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.leadID.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.companyName.toUpperCase().contains(text.toUpperCase())) {
        searchOpenActivitiesList.add(userDetail);
      }
    });

    setState(() {});
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: AppBar().preferredSize.height,
                child: Center(
                  child: Text(
                    'Open Activities',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
