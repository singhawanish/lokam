import '../../themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

import '../GoogleMap.dart';

class EscalationsListView extends StatefulWidget {
  const EscalationsListView({
    Key key,
    this.escalationsData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.id,
    this.tab,
  }) : super(key: key);

  final VoidCallback callback;
  final EscalationsListData escalationsData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String id;
  final String tab;
  @override
  _EscalationsListViewState createState() => _EscalationsListViewState();
}

class EscalationsListData {
  EscalationsListData({
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
    this.leadID,
    this.companyName,
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
  String leadID;
  String companyName;
}

class _EscalationsListViewState extends State<EscalationsListView> {
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
                                              widget
                                                  .escalationsData.description,
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
                                              "Lead ID - " +
                                                  widget.escalationsData.leadID,
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
                                              "Company Name - " +
                                                  widget.escalationsData
                                                      .companyName,
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
                                                  widget.escalationsData.type,
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
                                              widget.escalationsData
                                                  .activityOwner,
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
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "Due Date - " +
                                                    widget.escalationsData
                                                        .dueDate,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "From Date - " +
                                                    widget.escalationsData
                                                        .fromDate,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "To Date - " +
                                                    widget
                                                        .escalationsData.toDate,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : Text(
                                                "Call Start Time - " +
                                                    widget.escalationsData
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
                                              widget
                                                  .escalationsData.dateUpdated,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        // widget.escalationsData.type == 'NOTE'
                                        //     ? Container()
                                        //     : Text(
                                        //         "Activity Creation Lat - " +
                                        //             widget.escalationsData
                                        //                 .activityCreationLat,
                                        //         textAlign: TextAlign.left,
                                        //         style: TextStyle(
                                        //           color: Colors.grey
                                        //               .withOpacity(0.8),
                                        //           fontSize: 14,
                                        //         ),
                                        //       ),
                                        // widget.escalationsData.type == 'NOTE'
                                        //     ? Container()
                                        //     : Text(
                                        //         "Activity Creation Long - " +
                                        //             widget.escalationsData
                                        //                 .activityCreationLong,
                                        //         textAlign: TextAlign.left,
                                        //         style: TextStyle(
                                        //           color: Colors.grey
                                        //               .withOpacity(0.8),
                                        //           fontSize: 14,
                                        //         ),
                                        //       ),
                                        widget.escalationsData.type == 'NOTE'
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
                                                                    .escalationsData
                                                                    .activityCreationLat),
                                                                long: double.parse(widget
                                                                    .escalationsData
                                                                    .activityCreationLong))),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : widget.escalationsData
                                                        .activityCloseTime ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Close Time - " +
                                                        widget.escalationsData
                                                            .activityCloseTime,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : widget.escalationsData
                                                        .activityCloseRemark ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Close Remark - " +
                                                        widget.escalationsData
                                                            .activityCloseRemark,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : widget.escalationsData
                                                        .activityCloseBy ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Close By - " +
                                                        widget.escalationsData
                                                            .activityCloseBy,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : widget.escalationsData
                                                        .activityClosingLat ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Closing Lat - " +
                                                        widget.escalationsData
                                                            .activityClosingLat,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                        widget.escalationsData.type == 'NOTE'
                                            ? Container()
                                            : widget.escalationsData
                                                        .activityClosingLong ==
                                                    null
                                                ? Container()
                                                : Text(
                                                    "Activity Closing Long - " +
                                                        widget.escalationsData
                                                            .activityClosingLong,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withOpacity(0.8),
                                                      fontSize: 14,
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
