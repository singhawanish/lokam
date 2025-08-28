import 'dart:convert';

import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../../../main.dart';
import 'package:flutter/material.dart';

import '../../../../utils/MyPdfViewer.dart';
import '../../../loginPage.dart';
import '../../../userVerification.dart';
import 'customer_meet_photos.dart';
import 'package:http/http.dart' as http;

class CustomerMeetRecordsListView extends StatefulWidget {
  const CustomerMeetRecordsListView({
    Key key,
    this.customerMeetRecordsData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.id,
    this.tab,
  }) : super(key: key);

  final VoidCallback callback;
  final CustomerMeetRecordsListData customerMeetRecordsData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String id;
  final String tab;
  @override
  _CustomerMeetRecordsListViewState createState() =>
      _CustomerMeetRecordsListViewState();
}

class CustomerMeetRecordsListData {
  CustomerMeetRecordsListData({
    this.id,
    this.soCreated,
    this.organizingSo,
    this.participatingSo,
    this.noOfOfficers,
    this.noOfCustomers,
    this.venueName,
    this.venueLocation,
    this.feedback,
    this.hub,
    this.createdBy,
    this.dateCreated,
    this.type,
  });
  String id;
  String soCreated;
  String organizingSo;
  String participatingSo;
  String noOfOfficers;
  String noOfCustomers;
  String venueName;
  String venueLocation;
  String feedback;
  String hub;
  String createdBy;
  String dateCreated;
  String type;
}

class _CustomerMeetRecordsListViewState
    extends State<CustomerMeetRecordsListView> {
  String jwt;
  String name;
  bool reopenComplaintenabled = true;
  double lat;
  double long;
  bool grant = false;
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  void fetchPdfData(String number) async {
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
      if ((element as String) == 'EFMSVENDOR') {
        // _EFMSVENDORRole = true;
      }
    });
    var response = await http.post(
        Uri.parse(BASE_URI + ('/HMOFMO/getCustomerMeetDetailsPdf')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
        body: jsonEncode({
          "ID": number,
        }));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      bool status = map['status'] as bool;
      String code = map['code'] as String;
      String msg = map['msg'] as String;
      if (status) {
        if (code == '001') {
          String pdfUrl = map['data'] as String;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyPdfViewer(base64Pdf: pdfUrl),
              // MyPdfViewer(base64Pdf: 'data:application/pdf;base64,$pdfUrl'),
            ),
          );
          setState(() {});
        } else if (code == '900' && msg != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: WillPopScope(
                    onWillPop: () async {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      return true;
                    },
                    child: Text(msg),
                  ),
                ),
              )
              .closed
              .then((reason) {
            setState(() {});
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: WillPopScope(
                    onWillPop: () async {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      return true;
                    },
                    child: Text('Data Fetch Failed'),
                  ),
                ),
              )
              .closed
              .then((reason) {
            setState(() {});
          });
        }
      }
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - widget.animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  widget.callback();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        offset: const Offset(4, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: CustomTheme.buildLightTheme().backgroundColor,
                          child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                              child: Row(
                                // mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_right_rounded),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MarketIntelligencePhotosPage(
                                                  ID: widget
                                                      .customerMeetRecordsData
                                                      .id,
                                                )),
                                      );
                                    },
                                    iconSize: 24,
                                    color: Colors.black,
                                  ),
                                ],
                              )),
                        ),
                        Container(
                            color:
                                CustomTheme.buildLightTheme().backgroundColor,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 16,
                                            top: 8,
                                            bottom: 8,
                                            left: 16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              widget.customerMeetRecordsData
                                                  .feedback,
                                              textAlign: TextAlign.left,
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
                                ])),
                        Container(
                            color:
                                CustomTheme.buildLightTheme().backgroundColor,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 16,
                                            top: 8,
                                            bottom: 8,
                                            left: 16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "SO Created - " +
                                                  widget.customerMeetRecordsData
                                                      .soCreated,
                                              textAlign: TextAlign.left,
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
                                ])),
                        Container(
                          color: CustomTheme.buildLightTheme().backgroundColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 8, bottom: 8, right: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "ID - " +
                                              widget.customerMeetRecordsData.id,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Organizing State - " +
                                              widget.customerMeetRecordsData
                                                  .organizingSo,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Participating State - " +
                                              widget.customerMeetRecordsData
                                                  .participatingSo,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Hub - " +
                                              widget
                                                  .customerMeetRecordsData.hub,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Customer Meet Type - " +
                                              widget
                                                  .customerMeetRecordsData.type,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "No. of Officers Participated - " +
                                              widget.customerMeetRecordsData
                                                  .noOfOfficers,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "No. of Customers Participated - " +
                                              widget.customerMeetRecordsData
                                                  .noOfCustomers,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Venue Name - " +
                                              widget.customerMeetRecordsData
                                                  .venueName,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Venue Location - " +
                                              widget.customerMeetRecordsData
                                                  .venueLocation,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Created By - " +
                                              widget.customerMeetRecordsData
                                                  .createdBy,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Date Created - " +
                                              widget.customerMeetRecordsData
                                                  .dateCreated,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Center(
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: CustomTheme
                                                            .buildLightTheme()
                                                        .primaryColor),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.file_copy),
                                                    Text(
                                                        'View List of Participants PDF'),
                                                  ],
                                                ),
                                                // onPressed: _pickImage,
                                                onPressed: () {
                                                  fetchPdfData(widget
                                                      .customerMeetRecordsData
                                                      .id);
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
