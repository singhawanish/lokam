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

class ConvertToAccountPage extends StatefulWidget {
  const ConvertToAccountPage(
      {Key key, this.id, this.leadFunction, this.callback})
      : super(key: key);

  final String id;
  final String leadFunction;
  final VoidCallback callback;
  @override
  _ConvertToAccountState createState() => _ConvertToAccountState();
}

class _ConvertToAccountState extends State<ConvertToAccountPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final _descriptionFieldController = TextEditingController();
  final _accountNoFieldController = TextEditingController();
  TextEditingController _controller2 =
      new TextEditingController(text: DateTime.now().toString());
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(40.7128, -74.0060));
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();
  String displayDueDate = "";
  String dueDate = "";

  String leadFunction;
  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  bool _DSARole = false;
  bool _buttonEnabled = true;
  String jwt;
  String name;
  String _AfsDropdownSelection;

  List<String> wing = [];
  List<Map> AfsMap = [];
  List<Map<String, String>> floor = [];
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
    leadFunction = this.widget.leadFunction;
  }

  @override
  void initState() {
    getAfsCodes();
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
  }

  void getAfsCodes() async {
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
      var defValue = Map();
     defValue['key'] = "0000";
     defValue['value'] = "All India/Multiple Locations";
     AfsMap.add(defValue);
      var response = await http.get(
        Uri.parse(BASE_URI +
            (_DSARole
                ? '/HMOFMO/getAFSPlantCodes'
                : '/HMOFMO/getAFSPlantCodes')),
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

            AfsMap.add(temp);
          });
      //    debugPrint('AfsMap::$AfsMap');

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
      _AfsDropdownSelection = AfsMap[0]['key'];
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
                            'Convert To Account',
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
                                            '*Plant Code',
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
                                                value: _AfsDropdownSelection,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                items: AfsMap.map((map) {
                                                  return DropdownMenuItem(
                                                    child: Container(
                                                      width: width * 0.7,
                                                      child: Text(
                                                        map['value'] +
                                                            " (" +
                                                            map['key'] +
                                                            ")",
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                    value: map['key'],
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) async {
                                                  setState(() {
                                                    _AfsDropdownSelection =
                                                        newVal;
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
                                            '*Account No',
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
                                                controller:
                                                    _accountNoFieldController,
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
                                                        'SAP Code/XtraPower ID/SDMS ID',
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
                                          Container(
                                            child: const SizedBox(
                                              height: 30,
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
                                                        'Remarks for Conversion',
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
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Container(
                                            child: const SizedBox(
                                              height: 30,
                                            ),
                                          ),
                                          Text(
                                            '*Account No',
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
                                                controller:
                                                    _accountNoFieldController,
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
                                                        'SAP Code/XtraPower ID/SDMS ID',
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
                                          Container(
                                            child: const SizedBox(
                                              height: 30,
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
                                                        'Remarks for Conversion',
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
                                  Text('Convert'),
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
                    ? '/DSA/convertToAccount'
                    : '/HMOFMO/convertToAccount')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "leadID": widget.id,
              "desc": _descriptionFieldController.text,
              "accountNo": leadFunction == 'AV00'
                  ?_accountNoFieldController.text + "-" + _AfsDropdownSelection
                  :_accountNoFieldController.text    
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
                      child: Text('Account Conversion Failed'),
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
