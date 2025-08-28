import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:ioclcustomerconnect/utils/networkUtil.dart';

import '../../themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:remove_emoji/remove_emoji.dart';

import '../../../main.dart';
import '../../loginPage.dart';
import 'package:http/http.dart' as http;
import '../../userVerification.dart';
import '../GoogleMap.dart';
import 'close_activity.dart';
import 'feedback_popup_view.dart';

class ActivityListView extends StatefulWidget {
  const ActivityListView({
    Key key,
    this.activityData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.id,
    this.tab,
  }) : super(key: key);

  final VoidCallback callback;
  final ActivityListData activityData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String id;
  final String tab;
  @override
  _ActivityListViewState createState() => _ActivityListViewState();
}

class ActivityListData {
  ActivityListData({
    this.description,
    this.type,
    this.dueDate,
    this.fromDate,
    this.toDate,
    this.callStartTime,
    this.activityOwner,
    this.dateUpdated,
    this.activityCreationLat,
    this.activityCreationLong,
    this.activityCloseTime,
    this.activityCloseRemark,
    this.activityCloseBy,
    this.activityClosingLat,
    this.activityClosingLong,
    this.activityID,
  });
  String description;
  String type;
  String dueDate;
  String fromDate;
  String toDate;
  String callStartTime;
  String activityOwner;
  String dateUpdated;
  String activityCreationLat;
  String activityCreationLong;
  String activityCloseTime;
  String activityCloseRemark;
  String activityCloseBy;
  String activityClosingLat;
  String activityClosingLong;
  String activityID;
}

class _ActivityListViewState extends State<ActivityListView> {
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

  Future<void> _checkGPSAccess() async {
    bool servicestatus = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!servicestatus) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Enable Location Service'),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        grant = false;
      });
    } else {
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('Enable Permission'),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          grant = false;
        });
      } else {
        // while (permission != LocationPermission.always &&
        //     permission != LocationPermission.whileInUse) {
        //   permission = await Geolocator.requestPermission();
        // }
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        setState(() {
          lat = position.latitude;
          long = position.longitude;
          grant = true;
        });
      }
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
                                              widget.activityData.description,
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
                                              "Activity Type - " +
                                                  widget.activityData.type,
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
                                          "Activity Owner - " +
                                              widget.activityData.activityOwner,
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
                            ],
                          ),
                        ),
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
                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "Due Date - " +
                                                    widget.activityData.dueDate,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "From Date - " +
                                                    widget
                                                        .activityData.fromDate,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "To Date - " +
                                                    widget.activityData.toDate,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "Call Start Time - " +
                                                    widget.activityData
                                                        .callStartTime,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                        Text(
                                          "Date Modified - " +
                                              widget.activityData.dateUpdated,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),

                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : widget.activityData
                                                        .activityCloseTime ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Close Time - " +
                                                        widget.activityData
                                                            .activityCloseTime,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : widget.activityData
                                                        .activityCloseRemark ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Close Remark - " +
                                                        widget.activityData
                                                            .activityCloseRemark,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : widget.activityData
                                                        .activityCloseBy ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Close By - " +
                                                        widget.activityData
                                                            .activityCloseBy,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),

                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : Center(
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(4, 0, 4, 0),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        primary: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            'Activity Creation Location'),
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => GoogleMapPage(
                                                                lat: double.parse(widget
                                                                    .activityData
                                                                    .activityCreationLat),
                                                                long: double.parse(widget
                                                                    .activityData
                                                                    .activityCreationLong))),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                        // widget.activityData.type == 'NOTE'
                                        //     ? Container()
                                        //     : Text(
                                        //         "Activity Creation Lat - " +
                                        //             widget.activityData
                                        //                 .activityCreationLat,
                                        //         textAlign: TextAlign.left,
                                        //         style: TextStyle(
                                        //           color: Colors.grey
                                        //               .withOpacity(0.8),
                                        //           fontSize: 14,
                                        //         ),
                                        //       ),
                                        // widget.activityData.type == 'NOTE'
                                        //     ? Container()
                                        //     : Text(
                                        //         "Activity Creation Long - " +
                                        //             widget.activityData
                                        //                 .activityCreationLong,
                                        //         textAlign: TextAlign.left,
                                        //         style: TextStyle(
                                        //           color: Colors.grey
                                        //               .withOpacity(0.8),
                                        //           fontSize: 14,
                                        //         ),
                                        //       ),
                                        widget.activityData.type == 'NOTE'
                                            ? Container()
                                            : widget.activityData
                                                        .activityClosingLong ==
                                                    null
                                                ? Container()
                                                : Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  4, 0, 4, 0),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            primary: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                'Activity Closing Location'),
                                                          ],
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => GoogleMapPage(
                                                                    lat: double.parse(widget
                                                                        .activityData
                                                                        .activityClosingLat),
                                                                    long: double.parse(widget
                                                                        .activityData
                                                                        .activityClosingLong))),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                        // widget.activityData.type == 'NOTE'
                                        //     ? Container()
                                        //     : widget.activityData
                                        //                 .activityClosingLat ==
                                        //             null
                                        //         ? Container()
                                        //         : Text(
                                        //             "Activity Closing Lat - " +
                                        //                 widget.activityData
                                        //                     .activityClosingLat,
                                        //             textAlign: TextAlign.left,
                                        //             style: TextStyle(
                                        //               color: Colors.grey
                                        //                   .withOpacity(0.8),
                                        //               fontSize: 14,
                                        //             ),
                                        //           ),
                                        // widget.activityData.type == 'NOTE'
                                        //     ? Container()
                                        //     : widget.activityData
                                        //                 .activityClosingLong ==
                                        //             null
                                        //         ? Container()
                                        //         : Text(
                                        //             "Activity Closing Long - " +
                                        //                 widget.activityData
                                        //                     .activityClosingLong,
                                        //             textAlign: TextAlign.left,
                                        //             style: TextStyle(
                                        //               color: Colors.grey
                                        //                   .withOpacity(0.8),
                                        //               fontSize: 14,
                                        //             ),
                                        //           ),
                                        // ignore: unrelated_type_equality_checks
                                        widget.tab != "1"
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(4, 4, 4, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  4, 0, 4, 0),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            primary: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .add_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 15),
                                                            Text(
                                                                'Close Activity'),
                                                          ],
                                                        ),
                                                        onPressed: () async {
                                                          await _checkGPSAccess();
                                                          if (grant) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CloseActivityPage(
                                                                            id: widget.activityData.activityID,
                                                                            lat:
                                                                                this.lat,
                                                                            long:
                                                                                this.long,
                                                                            callback:
                                                                                widget.callback,
                                                                          )),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                )),
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

  void showFeedbackDialog(
      {BuildContext context,
      String compId,
      BuildContext parentContext,
      Function parentGetComplaints,
      String type}) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => FeedbackPopupView(
        type: type,
        barrierDismissible: true,
        onApplyClick: (int rating, String remarks) async {
          await initializeData();
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
                Uri.parse(BASE_URI + '/HardwareComplaints/userAckComplaint'),
                headers: {
                  'Content-type': 'application/json',
                  "Accept": "application/json",
                  "Authorization": jwt
                },
                body: jsonEncode({
                  "compId": compId,
                  "ack": type == 'UP' ? 'Satisfied' : 'Not Satisfied',
                  "remark":
                      type == 'UP' ? rating : RemoveEmoji().removemoji(remarks),
                  "name": name,
                }));
            if (response.statusCode == 200) {
              Map<String, dynamic> map = jsonDecode(response.body);
              bool status = map['status'] as bool;
              setState(() {});
              if (status) {
                final snackBar = SnackBar(
                  content: Text('Complaint Acknowledged Successfully.'),
                );
                ScaffoldMessenger.of(parentContext).showSnackBar(snackBar);
              } else {
                final snackBar = SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Complaint Acknowledgement Failed.'),
                );
                ScaffoldMessenger.of(parentContext).showSnackBar(snackBar);
              }
              parentGetComplaints();
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
        },
        onCancelClick: () {},
      ),
    );
  }

  reopenComplaint(String compId) async {
    reopenComplaintenabled = false;
    setState(() {});
    await initializeData();
    var internet = await checkInternet();
    if (!internet) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('No Internet Connectivity.'),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      reopenComplaintenabled = true;
      setState(() {});
    } else {
      var response = await http.post(
          Uri.parse(BASE_URI + '/HardwareComplaints/Admin/reopenComplaint'),
          headers: {
            'Content-type': 'application/json',
            "Accept": "application/json",
            "Authorization": jwt
          },
          body: jsonEncode({
            "compId": compId,
          }));
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        bool status = map['status'] as bool;
        String count = map['data'] as String;
        if (status && count == "1") {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: WillPopScope(
                    onWillPop: () async {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      return true;
                    },
                    child: Text('Complaint Re-Opened.'),
                  ),
                ),
              )
              .closed
              .then((reason) {
            setState(() {
              widget.callback();
              Navigator.pop(context);
            });
          });
        } else {
          final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to Re-Open.'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          reopenComplaintenabled = false;
          setState(() {});
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
        reopenComplaintenabled = false;
        setState(() {});
      }
    }
  }
}
