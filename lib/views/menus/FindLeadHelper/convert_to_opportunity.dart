import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../../utils/networkUtil.dart';
import '../../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../loginPage.dart';
import 'package:http/http.dart' as http;

import '../../userVerification.dart';

class ConvertToOpportunityPage extends StatefulWidget {
  const ConvertToOpportunityPage(
      {Key key, this.id, this.leadFunction, this.callback})
      : super(key: key);

  final String id;
  final String leadFunction;
  final VoidCallback callback;
  @override
  _ConvertToOpportunityState createState() => _ConvertToOpportunityState();
}

class _ConvertToOpportunityState extends State<ConvertToOpportunityPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final _descriptionFieldController = TextEditingController();
  TextEditingController _controller2 =
      new TextEditingController(text: DateTime.now().toString());
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(40.7128, -74.0060));
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();
  String displayDueDate = "";
  String dueDate = "";
  String _employeeDropdownSelection;
  String _regionsDropdownSelection;
  List<Map> employeeMap = [];
  List<Map> regionsMap = [];

  String leadFunction;
  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  bool _DSARole = false;
  bool _buttonEnabled = true;
  String jwt;
  String name;

  List<String> wing = [];
  List<Map<String, String>> floor = [];
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
    leadFunction = this.widget.leadFunction;
  }

  @override
  void initState() {
    getDropdownValues();
    getEmployees('100');
    getRegions();
    super.initState();
  }

  void getRegions() async {
    var temp = Map();
    // temp['key'] = "XYZ1";
    // temp['value'] = "Western Region Office";
    // regionsMap.add(temp);

    // temp = Map();
    // temp['key'] = "XYZ2";
    // temp['value'] = "Eastern Region Office";
    // regionsMap.add(temp);

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
            (_DSARole ? '/HMOFMO/getAFSRegions' : '/HMOFMO/getAFSRegions')),
        headers: {
          "Accept": "application/json",
          "Authorization": jwt,
          'Content-type': 'application/json'
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

            regionsMap.add(temp);
          });
        //  debugPrint('regionsMap::$regionsMap');

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

    setState(() {
      regionsMap.forEach((element) {
        element['key'] == '100'
            ? _regionsDropdownSelection = element['key']
            : _regionsDropdownSelection = regionsMap[0]['key'];
      });
      //     _regionsDropdownSelection = regionsMap[0]['key'];
    });
  }

  void getEmployees(String compCode) async {
    await initializeData();

    // var temp = Map();
    // temp['key'] = "00508558";
    // temp['value'] = "Nivetha, Manager (IS)";
    // employeeMap.add(temp);
    //
    // temp = Map();
    // temp['key'] = "00508564";
    // temp['value'] = "Neha Bable, Manager (IS)";
    // employeeMap.add(temp);
    employeeMap = [];
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
            (_DSARole
                ? '/HMOFMO/fetchStateFunctionEmp?compCode=' + compCode
                : '/HMOFMO/fetchStateFunctionEmp?compCode=' + compCode)),
        headers: {
          "Accept": "application/json",
          "Authorization": jwt,
          'Content-type': 'application/json'
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

            employeeMap.add(temp);
          });
        //  debugPrint('employeeMap::$employeeMap');

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
    setState(() {
      _employeeDropdownSelection = employeeMap[0]['key'];
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
    });
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
                            'Assign Lead',
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
                                leadFunction == 'AV00'
                                    ? Column(
                                        children: [
                                          Container(
                                            child: const SizedBox(
                                              height: 30,
                                            ),
                                          ),
                                          Text(
                                            '*Assign to Region',
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
                                                value:
                                                    _regionsDropdownSelection,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items: regionsMap.map((map) {
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
                                                  getEmployees(newVal);
                                                  setState(() {
                                                    _regionsDropdownSelection =
                                                        newVal;
                                                  });
                                                },
                                                // value: _industryDropdownSelection,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Text(
                                            '*Assign to Employee',
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
                                                value:
                                                    _employeeDropdownSelection,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items: employeeMap.map((map) {
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
                                                    _employeeDropdownSelection =
                                                        newVal;
                                                  });
                                                },
                                                // value: _industryDropdownSelection,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Text(
                                            '*Remark',
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
                                                left: 30, right: 30),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                enabled: true,
                                                controller:
                                                    _descriptionFieldController,
                                                // inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),],
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
                                                        'Remarks for assigning the lead',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.multiline,
                                                minLines: 1,
                                                maxLength: 500,
                                                maxLines: 5,
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
                                    : Column(
                                        children: [
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Text(
                                            '*Assign to Employee',
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
                                                value:
                                                    _employeeDropdownSelection,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items: employeeMap.map((map) {
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
                                                    _employeeDropdownSelection =
                                                        newVal;
                                                  });
                                                },
                                                // value: _industryDropdownSelection,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Text(
                                            '*Remark',
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
                                                left: 30, right: 30),
                                            child: Theme(
                                              data: ThemeData(
                                                  primaryColor: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: TextFormField(
                                                enabled: true,
                                                controller:
                                                    _descriptionFieldController,
                                                // inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),],
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
                                                        'Remarks for assigning the lead',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.multiline,
                                                minLines: 1,
                                                maxLength: 500,
                                                maxLines: 5,
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
                              ],
                            ),
                          ),
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Assign Lead'),
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
                (_DSARole
                    ? '/DSA/convertToOpportunity'
                    : '/HMOFMO/convertToOpportunityCampaign')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "leadID": widget.id,
              "desc": _descriptionFieldController.text,
              "assignToEmployee": _employeeDropdownSelection
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
                Navigator.pop(context);
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
                      child: Text('Lead assigning Failed'),
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
