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
import 'CreateLeadV2.dart';
import 'aboutUsPage.dart';
import 'homeScreen.dart';
import 'home_drawer.dart';

class CustomerVisitsV2Page extends StatefulWidget {
  const CustomerVisitsV2Page({Key key, this.lat, this.long}) : super(key: key);

  final double lat;
  final double long;
  @override
  _CustomerVisitsV2State createState() => _CustomerVisitsV2State();
}

class _CustomerVisitsV2State extends State<CustomerVisitsV2Page> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final _descriptionFieldController = TextEditingController();
  final _customerIDFieldController = TextEditingController();
  final _customerNameFieldController = TextEditingController();
  final _customerOfficeLocationFieldController = TextEditingController();
  final _customerAvgMonthlyVolFieldController = TextEditingController();
  final _currentPurchaseFromWhichOMCFieldController = TextEditingController();
  final _iocShareFieldController = TextEditingController();
  final _nameOfCustomerPersonContacted = TextEditingController();
  final _mobileOfCustomerPersonCpntacted = TextEditingController();
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
  String _rolesDropdownSelection;
  String _typeOfCustomerDropdownSelection;
  String _consumerPumpStatusDropdownSelection;
  String _ifIbCustomerApproachedWithIbOfficer;
  String _leadToBeGenerated;
  List<Map> hubsMap = [];
  List<Map> consumerPumpStatusMap = [];
  List<Map> typeOfCustomerMap = [];
  List<Map> ifIBCustomerMap = [];
  double _discreteValue = 100.0;

  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  bool _DSARole = false;
  bool _buttonEnabled = true;
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
    var temp = Map();
    temp['key'] = 'YES';
    temp['value'] = 'YES';
    ifIBCustomerMap.add(temp);
    temp = Map();
    temp['key'] = 'NO';
    temp['value'] = 'NO';
    ifIBCustomerMap.add(temp);

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
            BASE_URI + (_DSARole ? '/DSA/getRoleList' : '/HMOFMO/getRoleList')),
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
            hubsMap.add(temp);
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
                ? '/DSA/getConsumerPumpStatusList'
                : '/HMOFMO/getConsumerPumpStatusList')),
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
            consumerPumpStatusMap.add(temp);
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
                ? '/DSA/getTypeOfCustomerList'
                : '/HMOFMO/getTypeOfCustomerList')),
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
            typeOfCustomerMap.add(temp);
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
                            'Customer Visit',
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
                                  '*Customer ID',
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
                                      controller: _customerIDFieldController,
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
                                              'XtraPower Customer ID/SAP Code',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.number,
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
                                    height: 10,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    fetchCustomerInfo();
                                  },
                                  icon: Icon(
                                    FlutterIcons.search1_ant,
                                    size: 20.0,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return Colors
                                              .grey; // Color when button is disabled
                                        }
                                        return CustomTheme.buildLightTheme()
                                            .primaryColor; // Color when button is enabled
                                      },
                                    ),
                                  ),
                                  label: Text('Search'),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                so != ""
                                    ? Column(
                                        children: [
                                          Container(
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Text(
                                            'Name of the Customer',
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
                                          Text(
                                            customerName,
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
                                          Text(
                                            'State Office: ' + so,
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
                                          Text(
                                            'Divisional Office: ' + dO,
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
                                          Text(
                                            'Hub: ' + hub,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Nothing Picked',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 18,
                                        ),
                                      ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  '*Contact Number',
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
                                          _mobileOfCustomerPersonCpntacted,
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
                                          hintText: 'Contact Person Mobile',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.number,
                                      minLines: 1,
                                      maxLength: 10,
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
                                Text(
                                  '*Feedback',
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
                                      controller: _descriptionFieldController,
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
                                          hintText: 'Requirement from Customer',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.multiline,
                                      minLines: 1,
                                      maxLength: 1000,
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
                                FutureBuilder(
                                  future: storage.read(key: 'name'),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                        'Name of Officer: ' + snapshot.data,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          fontSize: 18,
                                        ),
                                      );
                                    } else {
                                      return Text('Loading...');
                                    }
                                  },
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  '*Officer Role',
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
                                      items: hubsMap.map((map) {
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
                                          _rolesDropdownSelection = newVal;
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
                                  "*Customer Potential (KLPM)",
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
                                          _customerAvgMonthlyVolFieldController,
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
                                          hintText: 'Customer Potential (KLPM)',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.number,
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
                                Text(
                                  'Whether Customer 100% with IOC',
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
                                    child: Slider(
                                      activeColor: CustomTheme.buildLightTheme()
                                          .primaryColor,
                                      value: _discreteValue,
                                      min: 0.0,
                                      max: 100.0,
                                      divisions: 100,
                                      label: '${_discreteValue.round()}',
                                      onChanged: (double value) {
                                        setState(() {
                                          _discreteValue = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                _discreteValue < 100.0
                                    ? Column(children: [
                                        ...entries.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          String label = entry.value;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 70, right: 70),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(label),
                                                SizedBox(
                                                  width: 100,
                                                  child: TextField(
                                                    controller:
                                                        controllers[index],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d*\.?\d*')), // Allow numbers with optional decimal point
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ])
                                    : Container(),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                _discreteValue < 100.0
                                    ? Column(
                                        children: [
                                          Text(
                                            'Whether Lead to be Generated?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                            ),
                                            textAlign: TextAlign.center,
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
                                                    ifIBCustomerMap.map((map) {
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
                                                    _leadToBeGenerated = newVal;
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
                                        ],
                                      )
                                    : Container(),
                                Text(
                                  '*Type of Customer',
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
                                      items: typeOfCustomerMap.map((map) {
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
                                          _typeOfCustomerDropdownSelection =
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
                                  '*Does the Customer has CP?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
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
                                      items: ifIBCustomerMap.map((map) {
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
                                          _ifIbCustomerApproachedWithIbOfficer =
                                              newVal;
                                        });
                                      },
                                      // value: _industryDropdownSelection,
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
        StringBuffer tableString = StringBuffer();
        for (int i = 0; i < entries.length; i++) {
          String value =
              controllers[i].text.isNotEmpty ? controllers[i].text : '0';
          tableString.writeln('${entries[i]}: $value ,');
        }
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_DSARole
                    ? '/DSA/captureCustomerVisit/v2'
                    : '/HMOFMO/captureCustomerVisit/v2')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "customerID": _customerIDFieldController.text,
              "customerName": customerName,
              "mobileOfCustomerPersonContacted":
                  _mobileOfCustomerPersonCpntacted.text,
              "details": _descriptionFieldController.text,
              "role": _rolesDropdownSelection,
              "customerAvgMonthlyVol":
                  _customerAvgMonthlyVolFieldController.text,
              "iocShare": _discreteValue.toString(),
              "currentPurchaseFromWhichOMC": tableString.toString(),
              "typeOfCustomer": _typeOfCustomerDropdownSelection,
              "ifIbCustomerApproahedByIbOfficer":
                  _ifIbCustomerApproachedWithIbOfficer,
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
                  _discreteValue < 100 && _leadToBeGenerated == 'YES'
                      ? MaterialPageRoute(
                          builder: (context) => NavigationHomeScreen(
                                drawerIndex: DrawerIndex.CreateLeadV2,
                                screenView: CreateLeadV2Page(
                                    lat: widget.lat, long: widget.long),
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
