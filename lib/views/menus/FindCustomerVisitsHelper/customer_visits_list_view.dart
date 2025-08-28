import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import 'package:flutter/material.dart';

import '../../../main.dart';
import '../GoogleMap.dart';

class CustomerVisitsListView extends StatefulWidget {
  const CustomerVisitsListView({
    Key key,
    this.customerVisitsData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.id,
    this.tab,
  }) : super(key: key);

  final VoidCallback callback;
  final CustomerVisitsListData customerVisitsData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String id;
  final String tab;
  @override
  _CustomerVisitsListViewState createState() => _CustomerVisitsListViewState();
}

class CustomerVisitsListData {
  CustomerVisitsListData(
      {this.customerID,
      this.customerName,
      this.minutesOfMeeting,
      this.visitDatetime,
      this.visitLat,
      this.visitLong,
      this.createdBy,
      this.dateCreated,
      this.customerAvgMonthlyVol,
      this.typeOfCustomer,
      this.mobileOfCustomerPersonContacted,
      this.currentPurchaseFromWhichOMC,
      this.iocShare,
      this.ifIbCustomerApproahedByIbOfficer});
  String customerID;
  String customerName;
  String minutesOfMeeting;
  String visitDatetime;
  String visitLat;
  String visitLong;
  String createdBy;
  String dateCreated;
  String customerAvgMonthlyVol;
  String typeOfCustomer;
  String mobileOfCustomerPersonContacted;
  String currentPurchaseFromWhichOMC;
  String iocShare;
  String ifIbCustomerApproahedByIbOfficer;
}

class _CustomerVisitsListViewState extends State<CustomerVisitsListView> {
  String jwt;
  String name;
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
                                              widget.customerVisitsData
                                                  .minutesOfMeeting,
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
                                          "Customer ID - " +
                                              widget.customerVisitsData
                                                  .customerID,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Customer Name - " +
                                              widget.customerVisitsData
                                                  .customerName,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Visit DateTime - " +
                                              widget.customerVisitsData
                                                  .visitDatetime,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Created By - " +
                                              widget
                                                  .customerVisitsData.createdBy,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Date Created - " +
                                              widget.customerVisitsData
                                                  .dateCreated,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Customer Potential (KLPM) - " +
                                              widget.customerVisitsData
                                                  .customerAvgMonthlyVol,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Type of Customer - " +
                                              widget.customerVisitsData
                                                  .typeOfCustomer,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Contact Person Mobile - " +
                                              widget.customerVisitsData
                                                  .mobileOfCustomerPersonContacted,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "IOC Share(%) - " +
                                              widget
                                                  .customerVisitsData.iocShare,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Current Purchase from OMC(%) - " +
                                              widget.customerVisitsData
                                                  .currentPurchaseFromWhichOMC,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    4, 0, 4, 0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Location'),
                                                ],
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => GoogleMapPage(
                                                          lat: double.parse(widget
                                                              .customerVisitsData
                                                              .visitLat),
                                                          long: double.parse(widget
                                                              .customerVisitsData
                                                              .visitLong))),
                                                );
                                              },
                                            ),
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
