import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../../utils/networkUtil.dart';
import '../../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../loginPage.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../userVerification.dart';

class CloseComplaintPage extends StatefulWidget {
  const CloseComplaintPage(
      {Key key, this.id, this.workPermits, this.facility, this.callback})
      : super(key: key);

  final String id;
  final String workPermits;
  final String facility;
  final VoidCallback callback;
  @override
  _CloseComplaintState createState() => _CloseComplaintState();
}

class _CloseComplaintState extends State<CloseComplaintPage> {
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
  String _filePath;

  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  bool _EFMSVENDORRole = false;
  bool _workStartedButtonEnabled = false;
  bool _closeButtonEnabled = false;
  String workStartedButton = '';
  String closeButton = '';
  String nonClosedWorkPermits = '';
  String jwt;
  String name;

  List<Map> checkboxData = [];

  List<String> wing = [];
  List<Map<String, String>> floor = [];
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  File file;

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
      if ((element as String) == 'EFMSVENDOR') {
        _EFMSVENDORRole = true;
      }
    });
    var response = await http.post(
      Uri.parse(BASE_URI +
          (_EFMSVENDORRole
              ? '/EFMSVENDOR/getWorkOrderList'
              : '/HMOFMO/getWorkOrderList')),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
        "Authorization": jwt
      },
      body: jsonEncode({
        "complaintID": widget.id,
      }),
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
        workStartedButton = map['workStartedButton'] as String;
        if (workStartedButton == 'Y' && checkboxData.length != 0) {
          _workStartedButtonEnabled = true;
        }
        closeButton = map['closeButton'] as String;
        if (closeButton == 'Y') {
          _closeButtonEnabled = true;
        }
        nonClosedWorkPermits = map['nonClosedWorkPermits'] as String;
        if (checkboxData.length == 0 && workStartedButton == 'Y') {
          // final snackBar = SnackBar(
          //   backgroundColor: Colors.red,
          //   content: Text(
          //       'No Work Permit data present. Please ask Dealer to initiate.'),
          // );
          // ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // widget.callback();
          // Navigator.pop(context);

          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: WillPopScope(
                    onWillPop: () async {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      return true;
                    },
                    child: Text(
                        'No Work Permit data present. Please ask Dealer to initiate.'),
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
        }
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
                            'Action',
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
                                  'Work Permits',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  widget.workPermits,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
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
                                    height: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        workStartedButton == 'Y'
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: CustomTheme.buildLightTheme()
                                            .primaryColor),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Work Started'),
                                      ],
                                    ),
                                    onPressed: _workStartedButtonEnabled
                                        ? _onWorkStartedButton
                                        : null,
                                  ),
                                ),
                              )
                            : Container(),
                        closeButton == 'Y'
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: CustomTheme.buildLightTheme()
                                            .primaryColor),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Close'),
                                      ],
                                    ),
                                    onPressed: _closeButtonEnabled
                                        ? _onCloseButton
                                        : null,
                                  ),
                                ),
                              )
                            : Container(),
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

  _onWorkStartedButton() async {
    setState(() {});
    if (_isFormValidated()) {
      setState(() {
        _workStartedButtonEnabled = false;
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
            _workStartedButtonEnabled = true;
          });
        });
      } else {
        String base64String = "";
        if (file != null) {
          List<int> fileBytes = await file.readAsBytes();
          base64String = base64Encode(fileBytes);
        }
        String selectedValues = "";
        for (var item in checkboxData) {
          if (item['isChecked'] == true) {
            selectedValues = selectedValues + item['key'] + ",";
          }
        }
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_EFMSVENDORRole
                    ? '/EFMSVENDOR/acceptComplaint'
                    : '/HMOFMO/acceptComplaint')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "complaintID": widget.id,
              "workPermits": selectedValues,
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
                _workStartedButtonEnabled = true;
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
                      child: Text('Error!!!'),
                    ),
                  ),
                )
                .closed
                .then((reason) {
              setState(() {
                _EFMSVENDORRole = true;
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
              _workStartedButtonEnabled = true;
            });
          });
        }
      }
    }
  }

  _onCloseButton() async {
    setState(() {});
    if (_isFormValidated()) {
      setState(() {
        _closeButtonEnabled = false;
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
            _closeButtonEnabled = true;
          });
        });
      } else {
        String base64String = "";
        if (file != null) {
          List<int> fileBytes = await file.readAsBytes();
          base64String = base64Encode(fileBytes);
        }
        String selectedValues = "";
        for (var item in checkboxData) {
          if (item['isChecked'] == true) {
            selectedValues = selectedValues + item['key'] + ",";
          }
        }
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_EFMSVENDORRole
                    ? '/EFMSVENDOR/closeComplaint'
                    : '/HMOFMO/closeComplaint')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "complaintID": widget.id,
              "workPermits": selectedValues,
              "mappedWorkPermits": widget.workPermits,
              "nonClosedWorkPermits": nonClosedWorkPermits,
              "facility": widget.facility,
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
                _closeButtonEnabled = true;
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
                _closeButtonEnabled = true;
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
              _closeButtonEnabled = true;
            });
          });
        }
      }
    }
  }
}
