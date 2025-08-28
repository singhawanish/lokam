import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:search_choices/search_choices.dart';

import '../../main.dart';
import '../../utils/networkUtil.dart';
import '../../utils/validators.dart';
import '../loginPage.dart';
import 'package:http/http.dart' as http;

import '../themes/custom_theme.dart';
import '../userVerification.dart';
import 'aboutUsPage.dart';
import 'homeScreen.dart';
import 'home_drawer.dart';

class ComplaintCreationPage extends StatefulWidget {
  const ComplaintCreationPage({Key key, this.assetId}) : super(key: key);

  final String assetId;
  @override
  _ComplaintCreationPageState createState() => _ComplaintCreationPageState();
}

class _ComplaintCreationPageState extends State<ComplaintCreationPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final _descriptionFieldController = TextEditingController();
  final _duFieldController = TextEditingController();
  final _nozzleFieldController = TextEditingController();
  bool _buttonEnabled = true;
  bool facilityDropdownValid = true;
  List<Map> facility = [];
  // String _facilityDropdownSelection = 'Select';
  String _facilityDropdownSelection = '';

  bool natureDropdownValid = true;
  List<String> nature = ['Select'];
  // String _natureDropdownSelection = 'Select';
  String _natureDropdownSelection = '';

  bool salesDropdownValid = true;
  List<Map> sales = [];
  // String _salesDropdownSelection = 'Select';
  String _salesDropdownSelection = '';

  List<String> temppartyNoMap = ['Select'];
  String _partyNoDropdownSelection;
  // String _tempPartyNoDropdownSelection = 'Select';
  String _tempPartyNoDropdownSelection = '';
  List<Map> partyNoMap = [];

  bool partyNoDropdownValid = true;

  List<Map> checkboxData = [];

  String jwt;
  String name;
  String mobileNo = "";
  String intercomNo = "";
  String userSeat = "";
  String isfloor = "";
  String count = "1";
  String Iswing = "";
  bool _DealerRole = false;

  String locName = "";
  String locCode = "";

  List<String> wing = [];
  List<Map<String, String>> floor = [];
  String _dropdownSelection;
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  Future<void> getNature(String plant) async {
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
      if ((element as String) == 'DEALER') {
        _DealerRole = true;
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
      var response = await http.post(
        Uri.parse(BASE_URI +
            (_DealerRole
                ? '/DEALER/getOtherDUSubCategoryList'
                : '/HMOFMO/getOtherDUSubCategoryList')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
        body: jsonEncode({
          "facility_code": _facilityDropdownSelection,
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        bool status = map['status'] as bool;

        if (status) {
          List<dynamic> data = map['data'];
          temppartyNoMap = ['Select'];
          // _tempPartyNoDropdownSelection = 'Select';
          partyNoMap.clear();
          data.forEach((element) {
            var temp = Map();
            temp['key'] = element['key'] as String;
            temp['value'] = element['value'] as String;
            temppartyNoMap.add(element['value'] as String);
            partyNoMap.add(temp);
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

  Future<void> getFacilities() async {
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
      if ((element as String) == 'DEALER') {
        _DealerRole = true;
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
            (_DealerRole
                ? '/DEALER/getFacilityRequiringMaintenanceList'
                : '/HMOFMO/getFacilityRequiringMaintenanceList')),
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
            facility.add(temp);
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
            (_DealerRole
                ? '/DEALER/getSalesStoppedList'
                : '/HMOFMO/getSalesStoppedList')),
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
            sales.add(temp);
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
            (_DealerRole
                ? '/DEALER/getProductFoWhichSalesClosedList'
                : '/HMOFMO/getProductFoWhichSalesClosedList')),
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
            checkboxData.add(temp);
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
  void initState() {
    getFacilities();
    super.initState();
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
                            'eFMS New Complaint',
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
                              left: 16, right: 16, bottom: 16, top: 8),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Facility Requiring Maintenance',
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
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: DropdownButtonFormField(
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 16,
                                          color: Colors.black),
                                      items: facility.map((map) {
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
                                          _facilityDropdownSelection = newVal;
                                          getNature(newVal);
                                        });
                                      },
                                      // value: _industryDropdownSelection,
                                    )),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Nature of Complaint',
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
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: SearchChoices.single(
                                      items: partyNoMap.map((item) {
                                        return DropdownMenuItem(
                                          child: Container(
                                            width: width * 0.5,
                                            child: Text(
                                              item['value'],
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          value: item['key'],
                                        );
                                      }).toList(),
                                      value: _tempPartyNoDropdownSelection,
                                      hint: "Select",
                                      searchHint: "Select",
                                      onChanged: (newVal) async {
                                        setState(() {
                                          _tempPartyNoDropdownSelection =
                                              newVal;
                                        });
                                      },
                                      isCaseSensitiveSearch: false,
                                      validator: (value) =>
                                          natureDropdownValid ? null : 'Select',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 16,
                                          color: Colors.black),
                                    )),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Remark',
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
                                      controller: _descriptionFieldController,
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
                                              'Maximum 500 Characters are allowed',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.multiline,
                                      minLines: 1,
                                      maxLength: 500,
                                      maxLines: 5,
                                      validator: (value) => value.isEmpty ||
                                              Validators.removeEmoji
                                                      .removemoji(value) ==
                                                  ""
                                          ? 'Non Empty Text Field.'
                                          : null,
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
                        Container(
                          child: const SizedBox(
                            height: 10,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          'Whether Sales Stopped',
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
                            child: DropdownButtonFormField(
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                  color: Colors.black),
                              items: sales.map((map) {
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
                                  _salesDropdownSelection = newVal;
                                });
                              },
                              // value: _industryDropdownSelection,
                            )),
                        Container(
                          child: const SizedBox(
                            height: 40,
                          ),
                        ),
                        _salesDropdownSelection == 'Y'
                            ? Column(
                                children: [
                                  Text(
                                    'Product for which Sales Closed',
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
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Theme(
                                      data: ThemeData(
                                          primaryColor:
                                              CustomTheme.buildLightTheme()
                                                  .primaryColor),
                                      child: Column(
                                        children: [
                                          for (var item in checkboxData)
                                            CheckboxListTile(
                                              title: Text(item['value']),
                                              value: item['isChecked'] ?? false,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  item['isChecked'] = newValue;
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: const SizedBox(
                                      height: 40,
                                    ),
                                  ),
                                  Text(
                                    'No. of DUs Closed',
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
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Theme(
                                      data: ThemeData(
                                          primaryColor:
                                              CustomTheme.buildLightTheme()
                                                  .primaryColor),
                                      child: TextFormField(
                                        controller: _duFieldController,
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
                                                color: CustomTheme
                                                        .buildLightTheme()
                                                    .primaryColor,
                                              ),
                                            ),
                                            counterText: "",
                                            hintStyle: TextStyle(
                                                fontStyle: FontStyle.italic)),
                                        keyboardType: TextInputType.number,
                                        minLines: 1,
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
                                    'No. of Nozzles Closed',
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
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Theme(
                                      data: ThemeData(
                                          primaryColor:
                                              CustomTheme.buildLightTheme()
                                                  .primaryColor),
                                      child: TextFormField(
                                        controller: _nozzleFieldController,
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
                                                color: CustomTheme
                                                        .buildLightTheme()
                                                    .primaryColor,
                                              ),
                                            ),
                                            counterText: "",
                                            hintStyle: TextStyle(
                                                fontStyle: FontStyle.italic)),
                                        keyboardType: TextInputType.number,
                                        minLines: 1,
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
                                ],
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: CustomTheme.buildLightTheme()
                                      .primaryColor),
                              child: Text('Submit Complaint'),
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
        String selectedValues = "";
        for (var item in checkboxData) {
          if (item['isChecked'] == true) {
            selectedValues = selectedValues + item['value'] + ",";
          }
        }
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_DealerRole
                    ? '/DEALER/captureOtherDUComplaint'
                    : '/HMOFMO/captureOtherDUComplaint')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "facility_code": _facilityDropdownSelection,
              "sub_facility": _tempPartyNoDropdownSelection,
              "remark": _descriptionFieldController.text,
              "salesStopped": _salesDropdownSelection,
              "selectedProd": selectedValues,
              "duCount": _duFieldController.text,
              "nozzleCount": _nozzleFieldController.text,
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
                      child: Text('Complaint Creation Failed'),
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
