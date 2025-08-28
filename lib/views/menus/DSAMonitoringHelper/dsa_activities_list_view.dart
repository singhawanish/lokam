import 'package:geolocator/geolocator.dart';
import 'package:ioclcustomerconnect/views/menus/FindLeadHelper/close_activity.dart';

import '../../themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../GoogleMap.dart';

class DSAActivityListView extends StatefulWidget {
  const DSAActivityListView({
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
  final DSAActivityListData activityData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String id;
  final String tab;
  @override
  _DSAActivityListViewState createState() => _DSAActivityListViewState();
}

class DSAActivityListData {
  DSAActivityListData({
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

class _DSAActivityListViewState extends State<DSAActivityListView> {
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
}
