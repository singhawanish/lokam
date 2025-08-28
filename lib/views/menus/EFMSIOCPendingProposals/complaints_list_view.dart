import 'package:geolocator/geolocator.dart';
import '../../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'close_complaint.dart';

import '../../../main.dart';

class ComplaintsListView extends StatefulWidget {
  const ComplaintsListView({
    Key key,
    this.complaintData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.type,
  }) : super(key: key);

  final VoidCallback callback;
  final ComplaintsListData complaintData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String type;
  @override
  _ComplaintsListViewState createState() => _ComplaintsListViewState();
}

class ComplaintsListData {
  ComplaintsListData({
    this.proposalNo,
    this.proposalName,
    this.roCode,
    this.subProposalId,
    this.proposalId,
    this.custName,
    this.proposalDate,
    this.estAmt,
    this.receiptDate,
  });
  String proposalNo;
  String proposalName;
  String roCode;
  String subProposalId;
  String proposalId;
  String custName;
  String proposalDate;
  String estAmt;
  String receiptDate;
}

class _ComplaintsListViewState extends State<ComplaintsListView> {
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
  void initState() {
    super.initState();
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
                          color: CustomTheme.buildLightTheme().backgroundColor,
                          child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                              child: Row(
                                // mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [],
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
                                              "Proposal No. - " +
                                                  widget
                                                      .complaintData.proposalNo,
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
                                              "Proposal Name - " +
                                                  widget.complaintData
                                                      .proposalName,
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
                                          "RO Code - " +
                                              widget.complaintData.roCode,
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
                                        Text(
                                          "RO Name - " +
                                              widget.complaintData.custName,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Date of Proposal - " +
                                              widget.complaintData.proposalDate,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Date of Receipt - " +
                                              widget.complaintData.receiptDate,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Amount - " +
                                              widget.complaintData.estAmt,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    4, 4, 4, 4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(4, 0, 4, 0),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        primary: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.work,
                                                            color: Colors.white,
                                                            size: 15),
                                                        Text('Initiate Action'),
                                                      ],
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CloseComplaintPage(
                                                                  complaintInfo:
                                                                      widget
                                                                          .complaintData,
                                                                  type: 'A',
                                                                  callback: widget
                                                                      .callback,
                                                                )),
                                                      );
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
