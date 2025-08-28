import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../../utils/networkUtil.dart';
import '../../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../main.dart';
import '../../loginPage.dart';
import '../UpdateLead.dart';
import '../ViewDetail.dart';
import 'activities.dart';
import 'convert_to_opportunity.dart';
import 'create_call.dart';
import 'create_event.dart';
import 'create_note.dart';
import 'create_task.dart';

class LeadsListView extends StatefulWidget {
  const LeadsListView({
    Key key,
    this.leadData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.type,
  }) : super(key: key);

  final VoidCallback callback;
  final LeadsListData leadData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String type;
  @override
  _LeadsListViewState createState() => _LeadsListViewState();
}

class LeadsListData {
  LeadsListData(
      {this.id,
      this.leadOwner,
      this.companyName,
      this.contactPersonName,
      this.pinCode,
      this.emailId,
      this.mobileNo,
      this.website,
      this.leadSource,
      this.leadStatus,
      this.industry,
      this.convertedToOpportunity,
      this.location,
      this.city,
      this.vehicles,
      this.diesel,
      this.def,
      this.lubricant,
      this.monthlyRequirement,
      this.presentlySourcingFrom,
      this.remarkForIOC,
      this.productCategory,
      this.leadFunction,
      this.whetherOMCCustomer});
  String id;
  String leadOwner;
  String companyName;
  String contactPersonName;
  String pinCode;
  String emailId;
  String mobileNo;
  String website;
  String leadSource;
  String leadStatus;
  String industry;
  String convertedToOpportunity;
  String location;
  String city;
  String vehicles;
  String diesel;
  String def;
  String lubricant;
  String monthlyRequirement;
  String presentlySourcingFrom;
  String remarkForIOC;
  String productCategory;
  String leadFunction;
  String whetherOMCCustomer;
}

class _LeadsListViewState extends State<LeadsListView> {
  String jwt;
  String name;
  bool reopenComplaintenabled = true;
  double lat;
  double long;
  bool grant = false;
  bool showUpdate = true;

  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  Future<void> getDropdownValues() async {
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
    //  debugPrint('(element as String)::$element');
      if ((element as String) == 'SRH' ||
          (element as String) == 'SIBH' ||
          (element as String) == 'SLUH' ||
          (element as String) == 'SLH') {
        showUpdate = false;
      }
    });
  }

  @override
  void initState() {
    getDropdownValues();
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
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_right_rounded),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ActivitiesPage(
                                                    id: widget.leadData.id)),
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
                                              "Lead ID - " + widget.leadData.id,
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
                                                  widget.leadData.companyName,
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
                                          "Lead Source - " +
                                              widget.leadData.leadSource,
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
                                          "Requirements - " +
                                              widget.leadData.remarkForIOC,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Location - " +
                                              widget.leadData.location,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "City - " + widget.leadData.city,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        showUpdate
                                            ? Padding(
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
                                                                size: 10),
                                                            Text('Task'),
                                                          ],
                                                        ),
                                                        onPressed: () async {
                                                          await _checkGPSAccess();
                                                          if (grant) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => CreateTaskPage(
                                                                      id: widget
                                                                          .leadData
                                                                          .id,
                                                                      lat: this
                                                                          .lat,
                                                                      long: this
                                                                          .long)),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
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
                                                                size: 10),
                                                            Text('Note'),
                                                          ],
                                                        ),
                                                        onPressed: () async {
                                                          await _checkGPSAccess();
                                                          if (grant) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => CreateNotePage(
                                                                      id: widget
                                                                          .leadData
                                                                          .id,
                                                                      lat: this
                                                                          .lat,
                                                                      long: this
                                                                          .long)),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
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
                                                                    .border_color,
                                                                color: Colors
                                                                    .white,
                                                                size: 10),
                                                            Text('Update'),
                                                          ],
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        UpdateLeadPage(
                                                                          id: widget
                                                                              .leadData
                                                                              .id,
                                                                          callback:
                                                                              widget.callback,
                                                                        )),
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                    // Padding(
                                                    //   padding: EdgeInsetsDirectional
                                                    //       .fromSTEB(4, 0, 4, 0),
                                                    //   child: ElevatedButton(
                                                    //     style: ElevatedButton.styleFrom(
                                                    //         primary: CustomTheme
                                                    //                 .buildLightTheme()
                                                    //             .primaryColor),
                                                    //     child: Row(
                                                    //       children: [
                                                    //         Icon(Icons.add_rounded,
                                                    //             color: Colors.white,
                                                    //             size: 15),
                                                    //         Text('Event'),
                                                    //       ],
                                                    //     ),
                                                    //     onPressed: () async {
                                                    //       await _checkGPSAccess();
                                                    //       if (grant) {
                                                    //         Navigator.push(
                                                    //           context,
                                                    //           MaterialPageRoute(
                                                    //               builder: (context) =>
                                                    //                   CreateEventPage(
                                                    //                       id: widget
                                                    //                           .leadData
                                                    //                           .id,
                                                    //                       lat: this
                                                    //                           .lat,
                                                    //                       long: this
                                                    //                           .long)),
                                                    //         );
                                                    //       }
                                                    //     },
                                                    //   ),
                                                    // ),
                                                    // Padding(
                                                    //   padding: EdgeInsetsDirectional
                                                    //       .fromSTEB(4, 0, 4, 0),
                                                    //   child: ElevatedButton(
                                                    //     style: ElevatedButton.styleFrom(
                                                    //         primary: CustomTheme
                                                    //                 .buildLightTheme()
                                                    //             .primaryColor),
                                                    //     child: Row(
                                                    //       children: [
                                                    //         Icon(Icons.add_rounded,
                                                    //             color: Colors.white,
                                                    //             size: 15),
                                                    //         Text('Call'),
                                                    //       ],
                                                    //     ),
                                                    //     onPressed: () async {
                                                    //       await _checkGPSAccess();
                                                    //       if (grant) {
                                                    //         Navigator.push(
                                                    //           context,
                                                    //           MaterialPageRoute(
                                                    //               builder: (context) =>
                                                    //                   CreateCallPage(
                                                    //                       id: widget
                                                    //                           .leadData
                                                    //                           .id,
                                                    //                       lat: this
                                                    //                           .lat,
                                                    //                       long: this
                                                    //                           .long)),
                                                    //         );
                                                    //       }
                                                    //     },
                                                    //   ),
                                                    // ),
                                                  ],
                                                ))
                                            : Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(4, 4, 4, 0),
                                                child: Row()),
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
                                                        Text('View Detail'),
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ViewDetailPage(
                                                                  id: widget
                                                                      .leadData
                                                                      .id,
                                                                  leadData: widget
                                                                      .leadData,
                                                                  callback: widget
                                                                      .callback,
                                                                )),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(4, 0, 4, 0),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: HexColor(
                                                          '#D35465'), // Background color
                                                      onPrimary: Color(
                                                          0xFFFFFFFF), // Text color
                                                      shadowColor: Color(
                                                          0xFF000000), // Shadow color
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Assign Lead',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                    onPressed: widget.leadData
                                                                .convertedToOpportunity ==
                                                            'Y'
                                                        ? null
                                                        : () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ConvertToOpportunityPage(
                                                                            id: widget.leadData.id,
                                                                            leadFunction: widget.leadData.leadFunction,
                                                                            callback:
                                                                                widget.callback,
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
