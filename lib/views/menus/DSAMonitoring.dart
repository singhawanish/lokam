import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:ioclcustomerconnect/utils/networkUtil.dart';
import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import '../../main.dart';
import '../loginPage.dart';
import '../userVerification.dart';
import 'DSAMonitoringHelper/dsa_activities_list_view.dart';

class DSAMonitoringPage extends StatefulWidget {
  final String period;
  final String id;
  final VoidCallback callback;

  DSAMonitoringPage({Key key, this.period, this.id, this.callback})
      : super(key: key);

  @override
  _DSAMonitoringPageState createState() => _DSAMonitoringPageState();
}

class _DSAMonitoringPageState extends State<DSAMonitoringPage>
    with TickerProviderStateMixin {
  AnimationController animationController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<DSAActivityListData> openActivitiesList = [];
  List<DSAActivityListData> closeActivitiesList = [];
  List<DSAActivityListData> notesList = [];

  bool openActivitiesListPresent = true;
  bool closeActivitiesListPresent = true;
  bool notesListPresent = true;

  String jwt;
  bool _DSARole = false;
  int tab = 1;

  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
  }

  void getActivities() async {
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
      var response = await http.post(
          Uri.parse(BASE_URI +
              (_DSARole
                  ? '/DSA/getLeadDSAOpenActivities'
                  : '/HMOFMO/getLeadDSAOpenActivities')),
          headers: {
            "Accept": "application/json",
            "Authorization": jwt,
            'Content-type': 'application/json'
          },
          body: jsonEncode({
            "leadID": widget.id,
          }));
      if (response.statusCode == 200) {
        setState(() {
          List<DSAActivityListData> std = [];
          Map<String, dynamic> map = jsonDecode(response.body);
          List<dynamic> data = map['data'];
          data.forEach((element) {
            std.add(DSAActivityListData(
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
          // if (std.length == 0) {
          //   setState(() {
          //     widget.callback();
          //     Navigator.pop(context);
          //   });
          // }
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
      response = await http.post(
          Uri.parse(BASE_URI +
              (_DSARole
                  ? '/DSA/getLeadDSACloseActivities'
                  : '/HMOFMO/getLeadDSACloseActivities')),
          headers: {
            "Accept": "application/json",
            "Authorization": jwt,
            'Content-type': 'application/json'
          },
          body: jsonEncode({
            "leadID": widget.id,
          }));
      if (response.statusCode == 200) {
        setState(() {
          List<DSAActivityListData> std = [];
          Map<String, dynamic> map = jsonDecode(response.body);
          List<dynamic> data = map['data'];
          data.forEach((element) {
            std.add(DSAActivityListData(
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
              activityCloseTime: element['activityCloseTime'] == null
                  ? ''
                  : element['activityCloseTime'] as String,
              activityCloseRemark: element['activityCloseRemark'] == null
                  ? ''
                  : element['activityCloseRemark'] as String,
              activityCloseBy: element['activityCloseBy'] == null
                  ? ''
                  : element['activityCloseBy'] as String,
              activityClosingLat: element['activityClosingLat'] == null
                  ? ''
                  : element['activityClosingLat'] as String,
              activityClosingLong: element['activityClosingLong'] == null
                  ? ''
                  : element['activityClosingLong'] as String,
            ));
          });
          // if (std.length == 0) {
          //   setState(() {
          //     widget.callback();
          //     Navigator.pop(context);
          //   });
          // }
          closeActivitiesList = std;
          if (closeActivitiesList.length == 0) {
            closeActivitiesListPresent = false;
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
      response = await http.post(
          Uri.parse(BASE_URI +
              (_DSARole ? '/DSA/getLeadDSANotes' : '/HMOFMO/getLeadDSANotes')),
          headers: {
            "Accept": "application/json",
            "Authorization": jwt,
            'Content-type': 'application/json'
          },
          body: jsonEncode({
            "leadID": widget.id,
          }));
      if (response.statusCode == 200) {
        setState(() {
          List<DSAActivityListData> std = [];
          Map<String, dynamic> map = jsonDecode(response.body);
          List<dynamic> data = map['data'];
          data.forEach((element) {
            std.add(DSAActivityListData(
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
            ));
          });
          // if (std.length == 0) {
          //   setState(() {
          //     widget.callback();
          //     Navigator.pop(context);
          //   });
          // }
          notesList = std;
          if (notesList.length == 0) {
            notesListPresent = false;
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
    getActivities();
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
                          child: tab == 1
                              ? (openActivitiesList.length != 0
                                  ? RefreshIndicator(
                                      onRefresh: () async {
                                        setState(() {
                                          getActivities();
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
                                          return DSAActivityListView(
                                            callback: getActivities,
                                            activityData:
                                                openActivitiesList[index],
                                            animation: animation,
                                            animationController:
                                                animationController,
                                            parentContext:
                                                _scaffoldKey.currentContext,
                                            refreshCall: getActivities,
                                            tab: this.tab.toString(),
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
                                            )))
                              : tab == 2
                                  ? (closeActivitiesList.length != 0
                                      ? RefreshIndicator(
                                          onRefresh: () async {
                                            setState(() {
                                              getActivities();
                                            });
                                          },
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            primary: false,
                                            itemCount:
                                                closeActivitiesList.length,
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final int count =
                                                  // hotelList.length > 10 ? 10 : hotelList.length;
                                                  closeActivitiesList.length;
                                              final Animation<
                                                  double> animation = Tween<
                                                          double>(
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
                                              return DSAActivityListView(
                                                callback: getActivities,
                                                activityData:
                                                    closeActivitiesList[index],
                                                animation: animation,
                                                animationController:
                                                    animationController,
                                                parentContext:
                                                    _scaffoldKey.currentContext,
                                                refreshCall: getActivities,
                                              );
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: closeActivitiesListPresent
                                              ? CircularProgressIndicator()
                                              : Text(
                                                  'No Entry Present.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 22,
                                                  ),
                                                )))
                                  : (notesList.length != 0
                                      ? RefreshIndicator(
                                          onRefresh: () async {
                                            setState(() {
                                              getActivities();
                                            });
                                          },
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            primary: false,
                                            itemCount: notesList.length,
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final int count =
                                                  // hotelList.length > 10 ? 10 : hotelList.length;
                                                  notesList.length;
                                              final Animation<
                                                  double> animation = Tween<
                                                          double>(
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
                                              return DSAActivityListView(
                                                callback: getActivities,
                                                activityData: notesList[index],
                                                animation: animation,
                                                animationController:
                                                    animationController,
                                                parentContext:
                                                    _scaffoldKey.currentContext,
                                                refreshCall: getActivities,
                                              );
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: notesListPresent
                                              ? CircularProgressIndicator()
                                              : Text(
                                                  'No Entry Present.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 22,
                                                  ),
                                                ))),
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
      height: 170,
      decoration: BoxDecoration(
        color: CustomTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: CustomTheme.buildLightTheme().backgroundColor,
            ),
          ),
          ListView(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    tab = 1;
                  });
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 12),
                  child: Container(
                    width: 110,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tab == 1
                          ? Color(0xFF8BC34A)
                          : CustomTheme.buildLightTheme().backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x1F000000),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open Activities',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    tab = 2;
                  });
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 12),
                  child: Container(
                    width: 110,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tab == 2
                          ? Color(0xFF8BC34A)
                          : CustomTheme.buildLightTheme().backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x1F000000),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Closed Activities',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    tab = 3;
                  });
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 12),
                  child: Container(
                    width: 110,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tab == 3
                          ? Color(0xFF8BC34A)
                          : CustomTheme.buildLightTheme().backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x1F000000),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                    'DSA Activities',
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
