import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
import 'CreateLead.dart';
import 'aboutUsPage.dart';
import 'homeScreen.dart';
import 'home_drawer.dart';

class DailyActivityTrackerPage extends StatefulWidget {
  const DailyActivityTrackerPage({Key key}) : super(key: key);
  @override
  _DailyActivityTrackerState createState() => _DailyActivityTrackerState();
}

class _DailyActivityTrackerState extends State<DailyActivityTrackerPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final _nameOfComplanyController = TextEditingController();
  final _activityDescriptionController = TextEditingController();
  final _customerIDFieldController = TextEditingController();
  final _customerNameFieldController = TextEditingController();
  final _customerOfficeLocationFieldController = TextEditingController();
  final _customerAvgMonthlyVolFieldController = TextEditingController();
  final _currentPurchaseFromWhichOMCFieldController = TextEditingController();
  final _iocShareFieldController = TextEditingController();
  final _nameOfCustomerPersonContacted = TextEditingController();
  final _roCode = TextEditingController();
  final _reasonForReductionInTxn = TextEditingController();
  final _whetherShiftedToPvtOmc = TextEditingController();
  final _hsdVolShiftedToOtherOmcRo = TextEditingController();
  TextEditingController _controller2 =
      new TextEditingController(text: DateTime.now().toString());
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(40.7128, -74.0060));
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();
  String displayDueDate = "";
  String dueDate = "";
  String _slotTypeDropdownSelection;
  String _workTypeDropdownSelection;
  String _fieldWorkTypeDropdownSelection;
  String _customerTypeDropdownSelection;
  String _typeOfCustomerDropdownSelection;
  String _consumerPumpStatusDropdownSelection;
  String _ifIbCustomerApproachedWithIbOfficer;
  String _leadToBeGenerated;
  List<Map> slotTypeMap = [];
  List<Map> workTypeMap = [];
  List<Map> fieldWorkTypeMap = [];
  List<Map> customerTypeMap = [];
  List<Map> consumerPumpStatusMap = [];
  List<Map> typeOfCustomerMap = [];
  List<Map> ifIBCustomerMap = [];
  double _discreteValue = 100.0;

  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  bool _DSARole = false;
  bool _buttonEnabled = true;
  bool _roCodeEnabled = false;
  bool _customerTypeEnabled = false;
  bool _fieldWorkTypeEnabled = false;
  String jwt;
  String name;
  String customerName = "";
  String so = "";
  String dO = "";
  String hub = "";
  final List<String> entries = [
    'BPCL',
    'HPCL',
    'RIL',
    'Nayara',
    'Shell',
    'Others'
  ];
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  List<String> wing = [];
  List<Map<String, String>> floor = [];
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  @override
  void initState() {
    getDropdownValues();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void fetchCustomerInfo() async {
    await initializeData();
    customerName = so = dO = hub = "";
    var response = await http.post(
      Uri.parse(BASE_URI + ('/HMOFMO/getCustomerData')),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
        "Authorization": jwt
      },
      body: jsonEncode({
        "ID": _customerIDFieldController.text,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      bool status = map['status'] as bool;

      if (status) {
        dynamic data = map['data'];
        customerName =
            data['customerName'] == null ? '' : data['customerName'] as String;
        so = data['so'] == null ? '' : data['so'] as String;
        dO = data['do'] == null ? '' : data['do'] as String;
        hub = data['hub'] == null ? '' : data['hub'] as String;
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
        Uri.parse(
            BASE_URI + (_DSARole ? '/DSA/getSlotType' : '/HMOFMO/getSlotType')),
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
            slotTypeMap.add(temp);
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
        Uri.parse(
            BASE_URI + (_DSARole ? '/DSA/getWorkType' : '/HMOFMO/getWorkType')),
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
            workTypeMap.add(temp);
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
            (_DSARole ? '/DSA/getFieldWorkType' : '/HMOFMO/getFieldWorkType')),
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
            fieldWorkTypeMap.add(temp);
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
            (_DSARole ? '/DSA/getCustomerType' : '/HMOFMO/getCustomerType')),
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
            customerTypeMap.add(temp);
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
                            'Daily Activity Tracker',
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
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: CustomTheme.buildLightTheme()
                                          .primaryColor),
                                  onPressed: () {
                                    DatePicker.showDatePicker(
                                      context,
                                      currentTime: DateTime.now(),
                                      showTitleActions: true,
                                      // minTime: DateTime.now()
                                      //     .subtract(const Duration(days: 7)),
                                      minTime: DateTime(2024),
                                      maxTime: DateTime(2041),
                                      onChanged: (date) {
                                        print(
                                            'change $date in time zone ${date.timeZoneOffset.inHours}');
                                      },
                                      onConfirm: (date) {
                                        print('confirm $date');
                                        // Formatting the date to only capture the date part (yyyyMMdd format)
                                        dueDate =
                                            DateFormat('yyyyMMdd').format(date);
                                        displayDueDate = date.toString();
                                        setState(() {});
                                      },
                                      locale: LocaleType.en,
                                    );
                                  },
                                  child: Text(
                                    'Pick Date of Activity',
                                  ),
                                ),
                                displayDueDate != ""
                                    ? Text(
                                        'Picked Date : ${DateFormat('dd/MM/yyyy').format(DateTime.parse(displayDueDate))}',
                                      )
                                    : Container(),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  '*Day Slot',
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
                                      items: slotTypeMap.map((map) {
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
                                          _slotTypeDropdownSelection = newVal;
                                          _roCodeEnabled = false;
                                          _customerTypeEnabled = false;
                                          _fieldWorkTypeEnabled = false;
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
                                  '*Work Type',
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
                                      items: workTypeMap.map((map) {
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
                                          _workTypeDropdownSelection = newVal;
                                          _fieldWorkTypeEnabled =
                                              newVal.toString() == "2"
                                                  ? true
                                                  : false;
                                          _roCodeEnabled = false;
                                          _customerTypeEnabled = false;
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
                                _fieldWorkTypeEnabled
                                    ? Column(
                                        children: [
                                          Text(
                                            '*Field Work Type',
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
                                                    fieldWorkTypeMap.map((map) {
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
                                                    _fieldWorkTypeDropdownSelection =
                                                        newVal;
                                                    _roCodeEnabled =
                                                        newVal.toString() == "1"
                                                            ? true
                                                            : false;
                                                    _customerTypeEnabled =
                                                        newVal.toString() == "3"
                                                            ? true
                                                            : false;
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
                                        ],
                                      )
                                    : Container(),
                                _customerTypeEnabled
                                    ? Column(
                                        children: [
                                          Text(
                                            '*Customer Type',
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
                                                    customerTypeMap.map((map) {
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
                                                    _customerTypeDropdownSelection =
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
                                            '*Name of Company',
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
                                                    _nameOfComplanyController,
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
                                                    hintText: "Company's Name",
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.multiline,
                                                minLines: 1,
                                                maxLength: 100,
                                                maxLines: 5,
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
                                        ],
                                      )
                                    : Container(),
                                _roCodeEnabled
                                    ? Column(
                                        children: [
                                          Text(
                                            '*SAP Code',
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
                                                controller: _roCode,
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
                                                        'Retail Outlet Code',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                keyboardType:
                                                    TextInputType.number,
                                                minLines: 1,
                                                maxLength: 6,
                                                maxLines: 5,
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
                                        ],
                                      )
                                    : Container(),
                                Text(
                                  '*Activity Description',
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
                                      controller:
                                          _activityDescriptionController,
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
                                          hintText: "Detail of Activity",
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.multiline,
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
        StringBuffer tableString = StringBuffer();
        for (int i = 0; i < entries.length; i++) {
          String value =
              controllers[i].text.isNotEmpty ? controllers[i].text : '0';
          tableString.writeln('${entries[i]}: $value ,');
        }
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_DSARole
                    ? '/DSA/captureDailyActivity'
                    : '/HMOFMO/captureDailyActivity')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "activityDate": dueDate,
              "slotType": _slotTypeDropdownSelection,
              "workType": _workTypeDropdownSelection,
              "fieldWorkType": _fieldWorkTypeDropdownSelection,
              "customerType": _customerTypeDropdownSelection,
              "companyName": _nameOfComplanyController.text,
              "workDescription": _activityDescriptionController.text,
              "roCode": _roCode.text,
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
                  _discreteValue < 100 && _leadToBeGenerated == 'YES'
                      ? MaterialPageRoute(
                          builder: (context) => NavigationHomeScreen(
                                drawerIndex: DrawerIndex.CreateLead,
                                screenView: CreateLeadPage(),
                              ))
                      : MaterialPageRoute(
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
                      child: Text('Customer Visit Capture Failed'),
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
