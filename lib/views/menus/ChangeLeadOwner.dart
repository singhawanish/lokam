import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:ioclcustomerconnect/utils/networkUtil.dart';
import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import '../../main.dart';
import '../loginPage.dart';
import '../userVerification.dart';
import 'ChangeLeadOwnerHelper/own_leads_list_view.dart';

class ChangeLeadOwnerPage extends StatefulWidget {
  final String period;
  final String type;
  final VoidCallback callback;

  ChangeLeadOwnerPage({Key key, this.period, this.type, this.callback})
      : super(key: key);

  @override
  _ChangeLeadOwnerPageState createState() => _ChangeLeadOwnerPageState();
}

class _ChangeLeadOwnerPageState extends State<ChangeLeadOwnerPage>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<OwnLeadsListData> ownLeadsList = [];
  List<OwnLeadsListData> searchOwnLeadsList = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = new TextEditingController();
  bool leadListPresent = true;

  String jwt;
  bool _DSARole = false;

  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
  }

  void getLeads() async {
    searchController.clear();
    onSearchTextChanged('');
    searchOwnLeadsList.clear();
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
        Uri.parse(
            BASE_URI + (_DSARole ? '/DSA/getOwnLeads' : '/HMOFMO/getOwnLeads')),
        headers: {
          "Accept": "application/json",
          "Authorization": jwt,
          'Content-type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          List<OwnLeadsListData> std = [];
          Map<String, dynamic> map = jsonDecode(response.body);
          List<dynamic> data = map['data'];
          data.forEach((element) {
            std.add(OwnLeadsListData(
              id: element['id'] == null ? '' : element['id'] as String,
              leadOwner: element['leadOwner'] == null
                  ? ''
                  : element['leadOwner'] as String,
              companyName: element['companyName'] == null
                  ? ''
                  : element['companyName'] as String,
              contactPersonName: element['contactPersonName'] == null
                  ? ''
                  : element['contactPersonName'] as String,
              pinCode: element['pinCode'] == null
                  ? ''
                  : element['pinCode'] as String,
              emailId: element['emailId'] == null
                  ? ''
                  : element['emailId'] as String,
              mobileNo: element['mobileNo'] == null
                  ? ''
                  : element['mobileNo'] as String,
              website: element['website'] == null
                  ? ''
                  : element['website'] as String,
              leadSource: element['leadSource'] == null
                  ? ''
                  : element['leadSource'] as String,
              leadStatus: element['leadStatus'] == null
                  ? ''
                  : element['leadStatus'] as String,
              industry: element['industry'] == null
                  ? ''
                  : element['industry'] as String,
              convertedToOpportunity: element['convertedToOpportunity'] == null
                  ? ''
                  : element['convertedToOpportunity'] as String,
              city: element['city'] == null ? '' : element['city'] as String,
              location: element['location'] == null
                  ? ''
                  : element['location'] as String,
              vehicles: element['vehicles'] == null
                  ? ''
                  : element['vehicles'] as String,
              diesel:
                  element['diesel'] == null ? '' : element['diesel'] as String,
              def: element['def'] == null ? '' : element['def'] as String,
              lubricant: element['lubricant'] == null
                  ? ''
                  : element['lubricant'] as String,
            ));
          });

          ownLeadsList = std;
          if (ownLeadsList.length == 0) {
            leadListPresent = false;
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
    getLeads();
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
                          child: ownLeadsList.length != 0
                              ? searchOwnLeadsList.length != 0 ||
                                      searchController.text.isNotEmpty
                                  ? RefreshIndicator(
                                      onRefresh: () async {
                                        setState(() {
                                          getLeads();
                                        });
                                      },
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: searchOwnLeadsList.length,
                                        padding: const EdgeInsets.only(top: 8),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final int count =
                                              // hotelList.length > 10 ? 10 : hotelList.length;
                                              searchOwnLeadsList.length;
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
                                          return OwnLeadsListView(
                                              callback: getLeads,
                                              ownLeadData:
                                                  searchOwnLeadsList[index],
                                              animation: animation,
                                              animationController:
                                                  animationController,
                                              parentContext:
                                                  _scaffoldKey.currentContext,
                                              refreshCall: getLeads,
                                              type: widget.type);
                                        },
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: () async {
                                        setState(() {
                                          getLeads();
                                        });
                                      },
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: ownLeadsList.length,
                                        padding: const EdgeInsets.only(top: 8),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final int count =
                                              // hotelList.length > 10 ? 10 : hotelList.length;
                                              ownLeadsList.length;
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
                                          return OwnLeadsListView(
                                              callback: getLeads,
                                              ownLeadData: ownLeadsList[index],
                                              animation: animation,
                                              animationController:
                                                  animationController,
                                              parentContext:
                                                  _scaffoldKey.currentContext,
                                              refreshCall: getLeads,
                                              type: widget.type);
                                        },
                                      ),
                                    )
                              : Center(
                                  child: leadListPresent
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
    searchOwnLeadsList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    ownLeadsList.forEach((userDetail) {
      if (userDetail.id.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.leadOwner.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.companyName.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.contactPersonName
              .toUpperCase()
              .contains(text.toUpperCase()) ||
          userDetail.pinCode.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.emailId.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.mobileNo.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.website.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.leadSource.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.leadStatus.toUpperCase().contains(text.toUpperCase()) ||
          userDetail.industry.toUpperCase().contains(text.toUpperCase())) {
        searchOwnLeadsList.add(userDetail);
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
                    'Change Lead Owner',
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
