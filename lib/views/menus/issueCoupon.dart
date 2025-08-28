import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:ioclcustomerconnect/utils/networkUtil.dart';
import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import '../../main.dart';
import '../loginPage.dart';
import '../userVerification.dart';
import 'aboutUsPage.dart';
import 'homeScreen.dart';
import 'home_drawer.dart';

class IssueCouponPage extends StatefulWidget {
  const IssueCouponPage({Key key, this.lat, this.long}) : super(key: key);

  final double lat;
  final double long;
  @override
  _IssueCouponState createState() => _IssueCouponState();
}

class _IssueCouponState extends State<IssueCouponPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final _descriptionFieldController = TextEditingController();
  final _customerMobileFieldController = TextEditingController();
  final _customerMobileOTPFieldController = TextEditingController();
  final _locationNameFieldController = TextEditingController();
  TextEditingController _controller2 =
      new TextEditingController(text: DateTime.now().toString());
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(40.7128, -74.0060));
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();
  String displayDueDate = "";
  String dueDate = "";
  String _campaignsDropdownSelection;
  String _campaignsLocationDropdownSelection;
  List<Map> campaignMap = [];
  List<Map> campaignLocationMap = [];
  String prefix = "";

  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  bool _DSARole = false;
  bool _buttonEnabled = true;
  bool _OTPbuttonEnabled = true;
  String OTPButtonText = 'Get OTP';
  String jwt;
  String name;

  List<String> wing = [];
  List<Map<String, String>> floor = [];
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _goToLatLong();
  }

  Future<void> _goToLatLong() async {
    double lat = widget.lat;
    double long = widget.long;
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, long), 15));
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
            markerId: MarkerId('myLocation'),
            position: LatLng(lat, long),
            infoWindow: InfoWindow(
                title: 'Present Location', snippet: 'It will be captured.')),
      );
    });
  }

  @override
  void initState() {
    getDropdownValues();
    super.initState();
  }

  Future<void> getDropdownValues() async {
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
            (_DSARole ? '/DSA/getCampaignList' : '/HMOFMO/getCampaignList')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        bool status = map['status'] as bool;

        if (status) {
          List<dynamic> data = map['data'];

          data.forEach((element) {
            var temp = Map();
            temp['key'] = element['key'] as String;
            temp['value'] = element['value'] as String;
            campaignMap.add(temp);
          });
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
      }
      response = await http.get(
        Uri.parse(BASE_URI +
            (_DSARole
                ? '/DSA/getCampaignLocationList'
                : '/HMOFMO/getCampaignLocationList')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        bool status = map['status'] as bool;

        if (status) {
          List<dynamic> data = map['data'];

          data.forEach((element) {
            var temp = Map();
            temp['key'] = element['key'] as String;
            temp['value'] = element['value'] as String;
            campaignLocationMap.add(temp);
          });
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
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
                            'Issue Coupon',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: CustomTheme.buildLightTheme().backgroundColor,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                padding: EdgeInsets.only(top: 30),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16, top: 0),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  '*Campaign Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Theme(
                                    data: ThemeData(
                                        primaryColor:
                                            CustomTheme.buildLightTheme()
                                                .primaryColor),
                                    child: DropdownButtonFormField(
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 16,
                                          color: Colors.black),
                                      items: campaignMap.map((map) {
                                        return DropdownMenuItem(
                                          child: Container(
                                            width: width * 0.7,
                                            child: Text(
                                              map['value'],
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          value: map['key'],
                                        );
                                      }).toList(),
                                      onChanged: (newVal) async {
                                        setState(() {
                                          _campaignsDropdownSelection = newVal;
                                        });
                                      },
                                      // value: _industryDropdownSelection,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  '*Campaign Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Theme(
                                    data: ThemeData(
                                        primaryColor:
                                            CustomTheme.buildLightTheme()
                                                .primaryColor),
                                    child: DropdownButtonFormField(
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 16,
                                          color: Colors.black),
                                      items: campaignLocationMap.map((map) {
                                        return DropdownMenuItem(
                                          child: Container(
                                            width: width * 0.7,
                                            child: Text(
                                              map['value'],
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          value: map['key'],
                                        );
                                      }).toList(),
                                      onChanged: (newVal) async {
                                        setState(() {
                                          _campaignsLocationDropdownSelection =
                                              newVal;
                                          for (var i = 0;
                                              i < campaignLocationMap.length;
                                              i++) {
                                            if (campaignLocationMap[i]['key'] ==
                                                newVal) {
                                              prefix = campaignLocationMap[i]
                                                  ['value'];
                                            }
                                          }
                                        });
                                      },
                                      // value: _industryDropdownSelection,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  '*' + prefix + ' Location Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30, right: 30),
                                  child: Theme(
                                    data: ThemeData(
                                        primaryColor:
                                            CustomTheme.buildLightTheme()
                                                .primaryColor),
                                    child: TextFormField(
                                      validator: (value) => value.length == 0
                                          ? 'Enter Proper Location Name'
                                          : null,
                                      controller: _locationNameFieldController,
                                      // inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),],
                                      decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor)),
                                          enabledBorder: UnderlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            borderSide: BorderSide(
                                              color:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor,
                                            ),
                                          ),
                                          counterText: "",
                                          hintText: 'Campaign Location Name',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.name,
                                      maxLength: 100,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  '*Mobile Number',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30, right: 30),
                                  child: Theme(
                                    data: ThemeData(
                                        primaryColor:
                                            CustomTheme.buildLightTheme()
                                                .primaryColor),
                                    child: TextFormField(
                                      validator: (value) => value.length != 10
                                          ? 'Enter Proper Mobile No.'
                                          : null,
                                      controller:
                                          _customerMobileFieldController,
                                      // inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),],
                                      decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor)),
                                          enabledBorder: UnderlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            borderSide: BorderSide(
                                              color:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor,
                                            ),
                                          ),
                                          counterText: "",
                                          hintText:
                                              'Lead / Customer Mobile Number',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.number,
                                      minLines: 1,
                                      maxLength: 10,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: CustomTheme.buildLightTheme()
                                              .primaryColor),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(OTPButtonText),
                                        ],
                                      ),
                                      onPressed: _OTPbuttonEnabled == true
                                          ? () {
                                              if (_customerMobileFieldController
                                                      .text.length ==
                                                  10) {
                                                setState(() {
                                                  _OTPbuttonEnabled = false;
                                                });
                                                Timer(Duration(seconds: 10),
                                                    () {
                                                  setState(() {
                                                    _OTPbuttonEnabled = true;
                                                    OTPButtonText =
                                                        'Re-send OTP';
                                                  });
                                                });
                                                _onGetOTPButton();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                      SnackBar(
                                                        content: WillPopScope(
                                                          onWillPop: () async {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .removeCurrentSnackBar();
                                                            return true;
                                                          },
                                                          child: Text(
                                                              'Set Proper Mobile Number'),
                                                        ),
                                                      ),
                                                    )
                                                    .closed
                                                    .then((reason) {
                                                  setState(() {
                                                    // _buttonEnabled = true;
                                                  });
                                                });
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  '*Enter OTP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30, right: 30),
                                  child: Theme(
                                    data: ThemeData(
                                        primaryColor:
                                            CustomTheme.buildLightTheme()
                                                .primaryColor),
                                    child: TextFormField(
                                      validator: (value) => value.length == 0
                                          ? 'Enter Proper OTP'
                                          : null,
                                      controller:
                                          _customerMobileOTPFieldController,
                                      // inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),],
                                      decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor)),
                                          enabledBorder: UnderlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            borderSide: BorderSide(
                                              color:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor,
                                            ),
                                          ),
                                          counterText: "",
                                          hintText:
                                              'OTP on Lead / Customer Mobile Number',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.number,
                                      minLines: 1,
                                      maxLength: 10,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 30.0,
                        ),
                        Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: GoogleMap(
                              markers: _markers,
                              myLocationEnabled: true,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: _initialPosition,
                            ),
                          ),
                        ),
                        Container(
                          child: const SizedBox(
                            height: 10,
                          ),
                        ),
                        Text(
                          '*Present Location(' +
                              widget.lat.toString() +
                              ', ' +
                              widget.long.toString() +
                              ') will be Captured.',
                        ),

                        // Center(
                        //     child: FutureBuilder<void>(
                        //   future: retriveLostData(),
                        //   builder: (BuildContext context,
                        //       AsyncSnapshot<void> snapshot) {
                        //     switch (snapshot.connectionState) {
                        //       case ConnectionState.none:
                        //       case ConnectionState.waiting:
                        //         return const Text('Picked an image');
                        //       case ConnectionState.done:
                        //         return _previewImage();
                        //       default:
                        //         return const Text('Picked an image');
                        //     }
                        //   },
                        // )),

                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: CustomTheme.buildLightTheme()
                                      .primaryColor),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Submit'),
                                ],
                              ),
                              onPressed:
                                  _buttonEnabled ? _onSubmitLoginButton : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValidated() {
    final FormState form = formKey.currentState;
    return form.validate();
  }

  _onSubmitLoginButton() async {
    setState(() {});
    if (_isFormValidated()) {
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
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_DSARole ? '/DSA/issueCoupon' : '/HMOFMO/issueCoupon')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "campaignName": _campaignsDropdownSelection,
              "campaignLocationName": _campaignsLocationDropdownSelection,
              "locationName": _locationNameFieldController.text,
              "mobileNumber": _customerMobileFieldController.text,
              "otp": _customerMobileOTPFieldController.text,
              "lat": widget.lat.toString(),
              "lng": widget.long.toString(),
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NavigationHomeScreen(
                            drawerIndex: DrawerIndex.AboutUs,
                            screenView: AboutUsPage(),
                          )),
                  (_) => false,
                );
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
                      child: Text('Error'),
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

  _onGetOTPButton() async {
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
          _OTPbuttonEnabled = true;
        });
      });
    } else {
      final rsa = await http.post(
        Uri.parse(BASE_URI + '/getRSAKey'),
      );
      if (rsa.statusCode == 200) {
        String jsonkey = rsa.body;
        Map<String, dynamic> map = jsonDecode(jsonkey);
        String key = map['key'];

        String encryptedMobile = RSAPublicKey.fromString(key)
            .encrypt(_customerMobileFieldController.text);
        String body = jsonEncode({"username": encryptedMobile});
        var res = await http.post(
          Uri.parse(
              BASE_URI + (_DSARole ? '/DSA/userGetOTP' : '/HMOFMO/userGetOTP')),
          body: body,
          // headers: {'Content-type': 'application/json'},
          headers: {
            "Accept": "application/json",
            "Authorization": jwt,
            'Content-type': 'application/json'
          },
        );
        if (res.statusCode == 200) {
          String auth = res.body;
          Map<String, dynamic> map = jsonDecode(auth);

          bool data = map['data'];
          bool status = map['status'];
          if (status == true) {
            if (data == true) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                    SnackBar(
                      content: WillPopScope(
                        onWillPop: () async {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          return true;
                        },
                        child: Text("OTP Sent"),
                      ),
                    ),
                  )
                  .closed;
            } else {
              String snackBarMsg = 'Error';
              final snackBar = SnackBar(
                backgroundColor: Colors.red,
                content: Text(snackBarMsg),
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
        } else {
          String snackBarMsg = 'Server Not Reachable.';
          final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text(snackBarMsg),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        String snackBarMsg = 'Server Not Reachable.';
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(snackBarMsg),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
