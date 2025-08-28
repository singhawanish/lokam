import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:ioclcustomerconnect/views/menus/FindLeadHelper/activities.dart';
import 'package:ioclcustomerconnect/views/menus/FindLeadHelper/create_call.dart';
import 'package:ioclcustomerconnect/views/menus/FindLeadHelper/create_event.dart';
import 'package:ioclcustomerconnect/views/menus/FindLeadHelper/create_note.dart';
import 'package:ioclcustomerconnect/views/menus/FindLeadHelper/create_task.dart';
import 'package:ioclcustomerconnect/views/menus/ViewAssignedDetail.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../../utils/networkUtil.dart';
import '../../loginPage.dart';
import '../../themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../main.dart';
import '../../userVerification.dart';
import '../UpdateLead.dart';
import 'convert_to_account.dart';
import 'package:http/http.dart' as http;

class OpportunitiesListView extends StatefulWidget {
  const OpportunitiesListView({
    Key key,
    this.opportunityData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.type,
  }) : super(key: key);

  final VoidCallback callback;
  final OpportunitiesListData opportunityData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String type;
  @override
  _OpportunitiesListViewState createState() => _OpportunitiesListViewState();
}

class OpportunitiesListData {
  OpportunitiesListData(
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
      this.convertedToAccount,
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
      this.leadAssignedTo,
      this.leadFunction,
      this.selfAssignedYN,
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
  String convertedToAccount;
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
  String leadAssignedTo;
  String leadFunction;
  String selfAssignedYN;
  String whetherOMCCustomer;
}

class _OpportunitiesListViewState extends State<OpportunitiesListView> {
  String jwt;
  String name;
  bool reopenComplaintenabled = true;
  double lat;
  double long;
  bool grant = false;
  bool _buttonEnabled = true;
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  @override
  void initState() {
    getDropdownValues();
    super.initState();
  }

  bool showUpdate = true;

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
                                                    id: widget
                                                        .opportunityData.id)),
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
                                              "Lead ID - " +
                                                  widget.opportunityData.id,
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
                                                  widget.opportunityData
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
                                              widget.opportunityData.leadSource,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          child: const SizedBox(
                                            height: 10,
                                          ),
                                        ),
                                        Text(
                                          "Lead Assigned To - " +
                                              widget.opportunityData
                                                  .leadAssignedTo,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
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
                                              widget
                                                  .opportunityData.remarkForIOC,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Location - " +
                                              widget.opportunityData.location,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "City - " +
                                              widget.opportunityData.city,
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
                                                                          .opportunityData
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
                                                    //                           .opportunityData
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
                                                    //                           .opportunityData
                                                    //                           .id,
                                                    //                       lat: this
                                                    //                           .lat,
                                                    //                       long: this
                                                    //                           .long)),
                                                    //         );
                                                    //       }
                                                    //     },
                                                    //   ),
                                                    //, )
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
                                                                          .opportunityData
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
                                                                              .opportunityData
                                                                              .id,
                                                                          callback:
                                                                              widget.callback,
                                                                        )),
                                                          );
                                                        },
                                                      ),
                                                    ),
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
                                                                ViewAssignedDetailPage(
                                                                  id: widget
                                                                      .opportunityData
                                                                      .id,
                                                                  leadData: widget
                                                                      .opportunityData,
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
                                                  child: Center(
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Color.fromARGB(
                                                            255,
                                                            26,
                                                            84,
                                                            1), // Background color
                                                        onPrimary: Color(
                                                            0xFFFFFFFF), // Text color
                                                        shadowColor: Color(
                                                            0xFF000000), // Shadow color
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text('Unassign Lead'),
                                                        ],
                                                      ),
                                                      onPressed: (_buttonEnabled &&
                                                              widget.opportunityData
                                                                      .selfAssignedYN ==
                                                                  'Y')
                                                          ? _onUnlockLeadButton
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(10.0),
                                        //   child: Center(
                                        //     child: ElevatedButton(
                                        //       style: ElevatedButton.styleFrom(
                                        //         primary: Color.fromARGB(255, 26,
                                        //             84, 1), // Background color
                                        //         onPrimary: Color(
                                        //             0xFFFFFFFF), // Text color
                                        //         shadowColor: Color(
                                        //             0xFF000000), // Shadow color
                                        //       ),
                                        //       child: Row(
                                        //         mainAxisSize: MainAxisSize.min,
                                        //         children: [
                                        //           Text('Unassign Lead'),
                                        //         ],
                                        //       ),
                                        //       onPressed: (_buttonEnabled &&
                                        //               widget.opportunityData
                                        //                       .selfAssignedYN ==
                                        //                   'Y')
                                        //           ? _onUnlockLeadButton
                                        //           : null,
                                        //     ),
                                        //   ),
                                        // ),
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
                                                        Text(
                                                          'Convert To Account',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                    onPressed: widget
                                                                .opportunityData
                                                                .convertedToAccount ==
                                                            'Y'
                                                        ? null
                                                        : () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ConvertToAccountPage(
                                                                            id: widget.opportunityData.id,
                                                                            leadFunction: widget.opportunityData.leadFunction,
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

  _onUnlockLeadButton() async {
    setState(() {});
    setState(() {
      _buttonEnabled = false;
    });
    var internet = await checkInternet();
    if (!internet) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('No Internet Connectivity.'),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar)
          .closed
          .then((reason) {
        setState(() {
          _buttonEnabled = true;
        });
      });
    } else {
      var response =
          await http.post(Uri.parse(BASE_URI + ('/HMOFMO/leadUnlock')),
              headers: {
                "Accept": "application/json",
                "Authorization": jwt,
                'Content-type': 'application/json'
              },
              body: jsonEncode({
                "leadID": widget.opportunityData.id,
              }));
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        bool flag = map['status'] as bool;
        String code = map['code'] as String;
        String msg = map['msg'] as String;
        if (flag == true && code == '001') {
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
            setState(() {
              widget.callback();
            });
          });
        } else if (flag == true && code == '900' && msg != null) {
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
            setState(() {
              _buttonEnabled = true;
            });
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
                    child: Text('Unassigning Lead Failed'),
                  ),
                ),
              )
              .closed
              .then((reason) {
            setState(() {
              _buttonEnabled = true;
            });
          });
        }
      } else if (response.statusCode == 403) {
        await storage.delete(key: 'jwt');
        await storage.delete(key: 'name');
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
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar)
            .closed
            .then((reason) {
          setState(() {
            _buttonEnabled = true;
          });
        });
      }
    }
  }
}
