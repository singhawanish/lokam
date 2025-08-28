import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:ioclcustomerconnect/utils/networkUtil.dart';
import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import '../../main.dart';
import '../loginPage.dart';
import '../userVerification.dart';
import 'MarketIntelligenceRecordsHelper/EscalationsHelper/market_intelligence_records_list_view.dart';

class MarketIntelligenceRecordsPage extends StatefulWidget {
  final String period;
  final String type;
  final VoidCallback callback;

  MarketIntelligenceRecordsPage(
      {Key key, this.period, this.type, this.callback})
      : super(key: key);

  @override
  _MarketIntelligenceRecordsPageState createState() =>
      _MarketIntelligenceRecordsPageState();
}

class _MarketIntelligenceRecordsPageState
    extends State<MarketIntelligenceRecordsPage> with TickerProviderStateMixin {
  AnimationController animationController;
  List<MarketIntelligenceRecordsListData> marketIntelligenceRecordsList = [];
  List<MarketIntelligenceRecordsListData> searchMarketIntelligenceRecordsList =
      [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = new TextEditingController();
  bool marketIntelligenceRecordsListPresent = true;

  String jwt;
  bool _DSARole = false;

  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
  }

  void getOpenActivities() async {
    searchController.clear();
    onSearchTextChanged('');
    searchMarketIntelligenceRecordsList.clear();
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
                ? '/DSA/getMarketIntelligenceRecords'
                : '/HMOFMO/getMarketIntelligenceRecords')),
        headers: {
          "Accept": "application/json",
          "Authorization": jwt,
          'Content-type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          List<MarketIntelligenceRecordsListData> std = [];
          Map<String, dynamic> map = jsonDecode(response.body);
          List<dynamic> data = map['data'];
          data.forEach((element) {
            std.add(MarketIntelligenceRecordsListData(
              id: element['id'] == null ? '' : element['id'] as String,
              information: element['information'] == null
                  ? ''
                  : element['information'] as String,
              hub: element['hub'] == null ? '' : element['hub'] as String,
              partyInvolved: element['partyInvolved'] == null
                  ? ''
                  : element['partyInvolved'] as String,
              createdBy: element['createdBy'] == null
                  ? ''
                  : element['createdBy'] as String,
              dateCreated: element['dateCreated'] == null
                  ? ''
                  : element['dateCreated'] as String,
            ));
          });

          marketIntelligenceRecordsList = std;
          if (marketIntelligenceRecordsList.length == 0) {
            marketIntelligenceRecordsListPresent = false;
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
                          child: marketIntelligenceRecordsList.length != 0
                              ? searchMarketIntelligenceRecordsList.length !=
                                          0 ||
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
                                            searchMarketIntelligenceRecordsList
                                                .length,
                                        padding: const EdgeInsets.only(top: 8),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final int count =
                                              // hotelList.length > 10 ? 10 : hotelList.length;
                                              searchMarketIntelligenceRecordsList
                                                  .length;
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
                                          return MarketIntelligenceRecordsListView(
                                              callback: getOpenActivities,
                                              marketIntelligenceRecordsData:
                                                  searchMarketIntelligenceRecordsList[
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
                                        itemCount: marketIntelligenceRecordsList
                                            .length,
                                        padding: const EdgeInsets.only(top: 8),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final int count =
                                              // hotelList.length > 10 ? 10 : hotelList.length;
                                              marketIntelligenceRecordsList
                                                  .length;
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
                                          return MarketIntelligenceRecordsListView(
                                            callback: getOpenActivities,
                                            marketIntelligenceRecordsData:
                                                marketIntelligenceRecordsList[
                                                    index],
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
                                  child: marketIntelligenceRecordsListPresent
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
    searchMarketIntelligenceRecordsList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    marketIntelligenceRecordsList.forEach((userDetail) {
      if (userDetail.information.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.hub.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.partyInvolved.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.createdBy.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.dateCreated.toUpperCase().contains(text.toUpperCase())) {
        searchMarketIntelligenceRecordsList.add(userDetail);
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
                    'Market Intelligence Records',
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
