import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
// import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../utils/networkUtil.dart';
import '../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../loginPage.dart';
import 'package:http/http.dart' as http;

import '../userVerification.dart';
import 'aboutUsPage.dart';
import 'homeScreen.dart';
import 'home_drawer.dart';

class CreateLeadV2Page extends StatefulWidget {
  const CreateLeadV2Page({Key key, this.assetId, this.lat, this.long})
      : super(key: key);

  final double lat;
  final double long;

  final String assetId;
  @override
  _CreateLeadV2State createState() => _CreateLeadV2State();
}

class _CreateLeadV2State extends State<CreateLeadV2Page> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  String _leadOwnerDropdownSelection;
  List<Map> leadOwnerMap = [];
  String _leadStatusDropdownSelection;
  List<Map> leadStatusMap = [];
  String _industryDropdownSelection;
  List<Map> industryMap = [];
  String _emailOptOutDropdownSelection;
  String _whetherOMCCustomerDropdownSelection;
  List<Map> emailOptOutMap = [];
  List<Map> whetherOMCCustomerMap = [];
  List<Map> soMap = [];
  List<Map> avMap = [];
  List<Map> productMap = [];

  String _soDropdownSelection;
  String _avDropdownSelection;
  String _productDropdownSelection = "";
  String functionValue;
  final _companyNameFieldController = TextEditingController();
  final _contactPersonNameFieldController = TextEditingController();
  final _locationFieldController = TextEditingController();
  final _cityFieldController = TextEditingController();
  final _pinCodeFieldController = TextEditingController();
  final _emailIdFieldController = TextEditingController();
  final _mobileFieldController = TextEditingController();
  final _websiteFieldController = TextEditingController();
  final _vehicleFieldController = TextEditingController();
  final _dieselKLPMFieldController = TextEditingController();
  final _DEFKLPMFieldController = TextEditingController();
  final _lubricantKLPMFieldController = TextEditingController();
  bool _DSARole = false;
  final _monthlyRequirementFieldController = TextEditingController();
  final _presentlySouringFromFieldController = TextEditingController();
  final _aircraftRegNoFieldController = TextEditingController();
  final _remarksForIOCFieldController = TextEditingController();
  final Set<Marker> _markers = Set();

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(40.7128, -74.0060));
  bool _buttonEnabled = true;
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

  Future<void> fetchDataBasedOnRole(functionValue) async {
    try {
      var response = await http.get(
        Uri.parse(BASE_URI +
            (_DSARole
                ? '/DSA/getProductList'
                : '/HMOFMO/getDeptWiseProductList')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        bool status = map['status'] as bool;
        if (status) {
          List<dynamic> data = map['data'];

          productMap.clear(); // Clear previous data
          var temp1 = Map();
          temp1['key'] = "";
          temp1['value'] = "Select Here";
          productMap.add(temp1);
          data.forEach((element) {
            if (element['dept'] == functionValue) {
              var temp = Map();
              temp['key'] = element['id'] as String;
              temp['value'] = element['name'] as String;
              productMap.add(temp);
            }
          });

          setState(() {
            _productDropdownSelection = "";
          }); // Update UI
        }
      } else if (response.statusCode == 403) {
        // Handle unauthorized error
        // Add your storage delete logic here
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UserVerificationPage()),
          (_) => false,
        );
      } else {
        // Handle server error
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('Server Not Reachable.'),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
    }
  }

  @override
  void initState() {
    var temp3 = Map();
    temp3['key'] = 'Y';
    temp3['value'] = 'Yes';
    emailOptOutMap.add(temp3);
    temp3 = Map();
    temp3['key'] = 'N';
    temp3['value'] = 'No';
    emailOptOutMap.add(temp3);
    temp3 = Map();
    temp3['key'] = 'Y';
    temp3['value'] = 'Yes';
    whetherOMCCustomerMap.add(temp3);
    temp3 = Map();
    temp3['key'] = 'N';
    temp3['value'] = 'No';
    whetherOMCCustomerMap.add(temp3);

    getDropdownValues();
    super.initState();
  }

  Future<void> fetchAvDropdownValues() async {
    if (avMap.isEmpty) {
      soMap.forEach((element) {
        var temp = Map();
        temp['key'] = element['key'] as String;
        temp['value'] = element['value'] as String;
        if (temp['key'] == "100") {
          avMap.add(temp);
        }
      });
    }
    setState(() {
      _avDropdownSelection = avMap[0]['key'];
    });
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
      if ((element as String) == 'LPG' || (element as String) == 'SLH') {
        functionValue = "LPG";
      } else if ((element as String) == 'IB' || (element as String) == 'SIBH') {
        functionValue = "IB";
      } else if ((element as String) == 'LUBE' ||
          (element as String) == 'SLUH') {
        functionValue = "LUBE";
      } else if ((element as String) == 'AVIATION' ||
          (element as String) == 'SAVH') {
        functionValue = "AVIATION";
      } else {
        functionValue = "RETAIL";
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
            BASE_URI + (_DSARole ? '/DSA/getSOList' : '/HMOFMO/getSOList')),
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
            soMap.add(temp);
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
      setState(() {
        _soDropdownSelection = soMap[0]['key'];
      });
      fetchDataBasedOnRole(functionValue);

      // response = await http.get(
      //   Uri.parse(BASE_URI +
      //       (_DSARole ? '/DSA/getProductList' : '/HMOFMO/getProductList')),
      //   headers: {
      //     'Content-type': 'application/json',
      //     "Accept": "application/json",
      //     "Authorization": jwt
      //   },
      // );
      // if (response.statusCode == 200) {
      //   Map<String, dynamic> map = jsonDecode(response.body);
      //   bool status = map['status'] as bool;

      //   if (status) {
      //     List<dynamic> data = map['data'];

      //     data.forEach((element) {
      //       var temp = Map();
      //       temp['key'] = element['key'] as String;
      //       temp['value'] = element['value'] as String;
      //       productMap.add(temp);
      //     });
      //     setState(() {});
      //   }
      // } else if (response.statusCode == 403) {
      //   await storage.delete(key: 'jwt');
      //   await storage.delete(key: 'name');
      //   await storage.delete(key: 'designation');
      //   await storage.delete(key: 'empCode');
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (context) => UserVerificationPage()),
      //     (_) => false,
      //   );
      // } else {
      //   final snackBar = SnackBar(
      //     backgroundColor: Colors.red,
      //     content: Text('Server Not Reachable.'),
      //   );
      //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // }
      response = await http.get(
        Uri.parse(BASE_URI +
            (_DSARole ? '/DSA/getLeadStatus' : '/HMOFMO/getLeadStatus')),
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
            leadStatusMap.add(temp);
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
            (_DSARole ? '/DSA/getLeadIndustry' : '/HMOFMO/getLeadIndustry')),
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
            industryMap.add(temp);
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
                            'Create Lead',
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
                                Text(
                                  'Lead Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Ensures equal spacing
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "AVIATION",
                                          groupValue: functionValue,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                functionValue = value;
                                              });
                                              fetchDataBasedOnRole(
                                                  functionValue);
                                              fetchAvDropdownValues();
                                            }
                                          },
                                        ),
                                        Text("AVIATION"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "RETAIL",
                                          groupValue: functionValue,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                functionValue = value;
                                              });
                                            }
                                          },
                                        ),
                                        Text("RETAIL"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "IB",
                                          groupValue: functionValue,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                functionValue = value;
                                              });
                                              fetchDataBasedOnRole(
                                                  functionValue);
                                            }
                                          },
                                        ),
                                        Text("IB"),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Ensures equal spacing
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "LPG",
                                          groupValue: functionValue,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                functionValue = value;
                                              });
                                              fetchDataBasedOnRole(
                                                  functionValue);
                                            }
                                          },
                                        ),
                                        Text("LPG"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "LUBE",
                                          groupValue: functionValue,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                functionValue = value;
                                              });
                                              fetchDataBasedOnRole(
                                                  functionValue);
                                            }
                                          },
                                        ),
                                        Text("LUBE"),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  '*Lead Creating For',
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
                                functionValue == 'AVIATION'
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Theme(
                                          data: ThemeData(
                                              primaryColor:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor),
                                          child: DropdownButtonFormField(
                                            value: _avDropdownSelection,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                                color: Colors.black),
                                            items: avMap.map((map) {
                                              return DropdownMenuItem(
                                                child: Container(
                                                  width: width * 0.7,
                                                  child: Text(
                                                    map['value'],
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                                value: map['key'],
                                              );
                                            }).toList(),
                                            onChanged: (newVal) async {
                                              setState(() {
                                                _avDropdownSelection = newVal;
                                              });
                                            },
                                            // value: _industryDropdownSelection,
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Theme(
                                          data: ThemeData(
                                              primaryColor:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor),
                                          child: DropdownButtonFormField(
                                            value: _soDropdownSelection,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                                color: Colors.black),
                                            items: soMap.map((map) {
                                              return DropdownMenuItem(
                                                child: Container(
                                                  width: width * 0.7,
                                                  child: Text(
                                                    map['value'],
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                                value: map['key'],
                                              );
                                            }).toList(),
                                            onChanged: (newVal) async {
                                              setState(() {
                                                _soDropdownSelection = newVal;
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
                                  '*Company Name',
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
                                    child: TextFormField(
                                      controller: _companyNameFieldController,
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
                                          hintText: 'Name of the Company',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.name,
                                      maxLength: 200,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Contact Person Name',
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
                                    child: TextFormField(
                                      controller:
                                          _contactPersonNameFieldController,
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
                                          hintText: 'Name of Contact Person',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.name,
                                      maxLength: 200,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Location',
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
                                    child: TextFormField(
                                      controller: _locationFieldController,
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
                                          hintText: 'Address of Company',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.text,
                                      maxLength: 200,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  '*City',
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
                                    child: TextFormField(
                                      controller: _cityFieldController,
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
                                          hintText: 'City of Company',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.text,
                                      maxLength: 200,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Pin Code',
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
                                    child: TextFormField(
                                      controller: _pinCodeFieldController,
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
                                          hintText: 'Pin Code of Company',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  '*Email ID',
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
                                    child: TextFormField(
                                      controller: _emailIdFieldController,
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
                                          hintText: 'Email ID of Company',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter email";
                                        }
                                        // Email validation regex
                                        final emailRegex = RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                        if (!emailRegex.hasMatch(value)) {
                                          return "Please enter a valid email address";
                                        }
                                        return null;
                                      },
                                      maxLength: 200,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  '*Mobile No',
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
                                    child: TextFormField(
                                      controller: _mobileFieldController,
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
                                          hintText: 'Mobile Numer of Company',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Website',
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
                                    child: TextFormField(
                                      controller: _websiteFieldController,
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
                                          hintText: 'Website of Company',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.text,
                                      maxLength: 2000,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                functionValue == 'RETAIL'
                                    ? Column(
                                        children: [
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            '*No. of Vehicles',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                controller:
                                                    _vehicleFieldController,
                                                decoration: InputDecoration(
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor)),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      borderSide: BorderSide(
                                                        color: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    counterText: "",
                                                    hintText:
                                                        'Number of Vehicles of Company',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            '*Diesel Monthly Consumption',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                controller:
                                                    _dieselKLPMFieldController,
                                                decoration: InputDecoration(
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor)),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      borderSide: BorderSide(
                                                        color: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    counterText: "",
                                                    hintText:
                                                        'Consumption (in KLPM)',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            'DEF Consumption',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                controller:
                                                    _DEFKLPMFieldController,
                                                decoration: InputDecoration(
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor)),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      borderSide: BorderSide(
                                                        color: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    counterText: "",
                                                    hintText:
                                                        'Consumption (in KLPM)',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            'Lubricant Consumption',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                controller:
                                                    _lubricantKLPMFieldController,
                                                decoration: InputDecoration(
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor)),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      borderSide: BorderSide(
                                                        color: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    counterText: "",
                                                    hintText:
                                                        'Consumption (in KLPM)',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            '*Lead Status',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: DropdownButtonFormField(
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items: leadStatusMap.map((map) {
                                                  return DropdownMenuItem(
                                                    child: Container(
                                                      width: width * 0.7,
                                                      child: Text(
                                                        map['value'],
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                    value: map['key'],
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) async {
                                                  setState(() {
                                                    _leadStatusDropdownSelection =
                                                        newVal;
                                                  });
                                                },
                                                // value: _leadStatusDropdownSelection,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            'Industry',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: DropdownButtonFormField(
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items: industryMap.map((map) {
                                                  return DropdownMenuItem(
                                                    child: Container(
                                                      width: width * 0.7,
                                                      child: Text(
                                                        map['value'],
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                    value: map['key'],
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) async {
                                                  setState(() {
                                                    _industryDropdownSelection =
                                                        newVal;
                                                  });
                                                },
                                                // value: _industryDropdownSelection,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            'Email Opt Out',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: DropdownButtonFormField(
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items:
                                                    emailOptOutMap.map((map) {
                                                  return DropdownMenuItem(
                                                    child: Container(
                                                      width: width * 0.7,
                                                      child: Text(
                                                        map['value'],
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                    value: map['key'],
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) async {
                                                  setState(() {
                                                    _emailOptOutDropdownSelection =
                                                        newVal;
                                                  });
                                                },
                                                // value: _leadStatusDropdownSelection,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          functionValue == 'AVIATION'
                                              ? Column(children: [
                                                  Container(
                                                    child: const SizedBox(
                                                      height: 40,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Aircraft Registration Number',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Container(
                                                    child: const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 20, right: 20),
                                                    child: Theme(
                                                      data: ThemeData(
                                                          primaryColor: CustomTheme
                                                                  .buildLightTheme()
                                                              .primaryColor),
                                                      child: TextFormField(
                                                        controller:
                                                            _aircraftRegNoFieldController,
                                                        decoration:
                                                            InputDecoration(
                                                                border: UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: CustomTheme.buildLightTheme()
                                                                            .primaryColor)),
                                                                enabledBorder:
                                                                    UnderlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20.0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: CustomTheme
                                                                            .buildLightTheme()
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                                counterText: "",
                                                                hintText:
                                                                    'Registration Number',
                                                                hintStyle: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic)),
                                                        keyboardType:
                                                            TextInputType.text,
                                                        maxLength: 100,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: const SizedBox(
                                                      height: 40,
                                                    ),
                                                  ),
                                                ])
                                              : Column(
                                                  children: [
                                                    Container(
                                                      child: const SizedBox(
                                                        height: 40,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          Text(
                                            'Product Category',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: DropdownButtonFormField(
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items: productMap.map((map) {
                                                  return DropdownMenuItem(
                                                    child: Container(
                                                      width: width * 0.7,
                                                      child: Text(
                                                        map['value'],
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                    value: map['key'],
                                                  );
                                                }).toList(),
                                                value:
                                                    _productDropdownSelection,
                                                onChanged: (newVal) async {
                                                  setState(() {
                                                    _productDropdownSelection =
                                                        newVal;
                                                  });
                                                },
                                                // value: _industryDropdownSelection,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            'Monthly Requirement',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                controller:
                                                    _monthlyRequirementFieldController,
                                                decoration: InputDecoration(
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor)),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      borderSide: BorderSide(
                                                        color: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    counterText: "",
                                                    hintText:
                                                        'Consumption (in standard UoM)',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 40,
                                            ),
                                          ),
                                          Text(
                                            'Presently Sourcing From',
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
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                controller:
                                                    _presentlySouringFromFieldController,
                                                decoration: InputDecoration(
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: CustomTheme
                                                                    .buildLightTheme()
                                                                .primaryColor)),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      borderSide: BorderSide(
                                                        color: CustomTheme
                                                                .buildLightTheme()
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    counterText: "",
                                                    hintText:
                                                        'Sourcing Location',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.text,
                                                maxLength: 100,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Requirements',
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
                                    child: TextFormField(
                                      controller: _remarksForIOCFieldController,
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
                                          hintText: 'Requirements in Brief',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.text,
                                      maxLength: 100,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Whether OMC Customer',
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
                                      items: whetherOMCCustomerMap.map((map) {
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
                                          _whetherOMCCustomerDropdownSelection =
                                              newVal;
                                        });
                                      },
                                      // value: _leadStatusDropdownSelection,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: const SizedBox(
                            height: 10,
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
                              child: Text('Generate Lead'),
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
        if (functionValue == "RETAIL") {
          functionValue = "SL01";
        } else if (functionValue == "LPG") {
          functionValue = "LPG0";
        } else if (functionValue == "IB") {
          functionValue = "SL06";
        } else if (functionValue == "LUBE") {
          functionValue = "LUB0";
        } else if (functionValue == "AVIATION") {
          functionValue = "AV00";
        }
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_DSARole ? '/DSA/createLead' : '/HMOFMO/createLead')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "leadOwner": _leadOwnerDropdownSelection,
              "companyName": _companyNameFieldController.text,
              "contactPersonName": _contactPersonNameFieldController.text,
              "location": _locationFieldController.text,
              "city": _cityFieldController.text,
              "pinCode": _pinCodeFieldController.text,
              "emailId": _emailIdFieldController.text,
              "mobile": _mobileFieldController.text,
              "website": _websiteFieldController.text,
              "leadStatus": _leadStatusDropdownSelection,
              "industry": _industryDropdownSelection,
              "vehicles": _vehicleFieldController.text,
              "dieselKLPM": _dieselKLPMFieldController.text,
              "DEFKLPM": _DEFKLPMFieldController.text,
              "lubricantKLPM": _lubricantKLPMFieldController.text,
              "emailOptOut": _emailOptOutDropdownSelection,
              "leadCreatedFor": functionValue == "AV00"
                  ? _avDropdownSelection
                  : _soDropdownSelection,
              "aircraftRegNo": _aircraftRegNoFieldController.text,
              "monthlyRequirement": _monthlyRequirementFieldController.text,
              "presentlySourcingFrom":
                  _presentlySouringFromFieldController.text,
              "remarkForIOC": _remarksForIOCFieldController.text,
              "productCategory": _productDropdownSelection,
              "lat": widget.lat.toString(),
              "lng": widget.long.toString(),
              "leadFunction": functionValue,
              "whetherOMCCustomer": _whetherOMCCustomerDropdownSelection
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
                      child: Text('Lead Generation Failed'),
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
}
