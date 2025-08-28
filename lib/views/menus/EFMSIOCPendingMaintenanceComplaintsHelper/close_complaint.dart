import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../../utils/networkUtil.dart';
import '../../../utils/validators.dart';
import '../../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../loginPage.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../userVerification.dart';
import 'complaints_list_view.dart';

class CloseComplaintPage extends StatefulWidget {
  const CloseComplaintPage(
      {Key key, this.id, this.complaintInfo, this.type, this.callback})
      : super(key: key);

  final String id;
  final ComplaintsListData complaintInfo;
  final String type;
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
  bool _sumbitButtonEnabled = true;
  bool _rejectButtonEnabled = true;
  String workStartedButton = '';
  String closeButton = '';
  String nonClosedWorkPermits = '';
  String jwt;
  String name;

  List<Map> warrantyType = [];
  // String _warrantyTypeDropdownSelection = 'Select';
  String _warrantyTypeDropdownSelection = '';
  List<Map> workPermitType = [];
  // String _workPermitTypeDropdownSelection = 'Select';
  String _workPermitTypeDropdownSelection = '';
  List<Map> nameOfContractor = [];
  // String _nameOfContractorDropdownSelection = 'Select';
  String _nameOfContractorDropdownSelection = '';
  String contractNo = "";
  String contractValue = "";
  String vendorType = "";
  String invoiceAmount = "";
  String emailID = "";
  String mobileNo = "";

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
    var response = await http.get(
      Uri.parse(BASE_URI +
          (_EFMSVENDORRole
              ? '/EFMSVENDOR/getWarrantyType'
              : '/HMOFMO/getWarrantyType')),
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
          warrantyType.add(temp);
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
          (_EFMSVENDORRole
              ? '/EFMSVENDOR/getWorkPermitType'
              : '/HMOFMO/getWorkPermitType')),
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
          workPermitType.add(temp);
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

    response = await http.post(
      Uri.parse(BASE_URI +
          (_EFMSVENDORRole
              ? '/EFMSVENDOR/getNameOfContractor'
              : '/HMOFMO/getNameOfContractor')),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
        "Authorization": jwt
      },
      body: jsonEncode({
        "salesarea": widget.complaintInfo.salesarea,
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
          temp['vendorCode'] = element['vendorCode'] as String;
          temp['vendorName'] = element['vendorName'] as String;
          temp['emailId'] = element['emailId'] as String;
          temp['mobileNo'] = element['mobileNo'] as String;
          temp['contractNo'] = element['contractNo'] as String;
          temp['contractValue'] = element['contractValue'] as String;
          temp['vendorType'] = element['vendorType'] as String;
          temp['procInvoiceValue'] = element['procInvoiceValue'] as String;
          nameOfContractor.add(temp);
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
                            widget.type == 'A'
                                ? 'Intimate Contractor'
                                : 'Reject',
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
                              children: widget.type == 'A'
                                  ? <Widget>[
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'SAP Code of RO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.roCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Name of RO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.custName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Complaint No.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.complaintID,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Facility Requiring Maintenance',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.facility,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Nature of Complaint',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.natureOfComplaint,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Description of Complaint',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.remarks,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Sales Area',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.salesareaName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'RO Type',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.site,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Sales Stopped',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.complaintInfo.salesStopped,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      widget.complaintInfo.salesStopped == 'Yes'
                                          ? Container(
                                              child: Column(children: [
                                                Text(
                                                  'Sales Stopped Products',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  widget.complaintInfo.products,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                                Text(
                                                  'No. of DUs Closed',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  widget.complaintInfo.duCount,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                                Text(
                                                  'No. of Nozzles Closed',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  widget.complaintInfo
                                                      .nozzleCount,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                              ]),
                                            )
                                          : Container(),
                                      Text(
                                        'Whether Complaint is under Warranty?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                          child: DropdownButtonFormField(
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                                color: Colors.black),
                                            items: warrantyType.map((map) {
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
                                                _warrantyTypeDropdownSelection =
                                                    newVal;
                                              });
                                            },
                                          )),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Work Permit Type as per the Work Permit System under OISD 225',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                          child: DropdownButtonFormField(
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                                color: Colors.black),
                                            items: workPermitType.map((map) {
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
                                                _workPermitTypeDropdownSelection =
                                                    newVal;
                                              });
                                            },
                                          )),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Target Date for Work Completion',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        child: const SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary:
                                                CustomTheme.buildLightTheme()
                                                    .primaryColor),
                                        onPressed: () {
                                          DatePicker.showDateTimePicker(
                                            context,
                                            currentTime: DateTime.now(),
                                            showTitleActions: true,
                                            minTime: DateTime.now().subtract(
                                                const Duration(seconds: 1)),
                                            maxTime: DateTime(2041),
                                            onChanged: (date) {
                                              print(
                                                  'change $date in time zone ' +
                                                      date.timeZoneOffset
                                                          .inHours
                                                          .toString());
                                            },
                                            onConfirm: (date) {
                                              print('confirm $date');
                                              print(DateFormat('yyyyMMddHHmmss')
                                                  .format(date));
                                              dueDate = DateFormat('dd-MM-yyyy')
                                                  .format(date);
                                              displayDueDate =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(date);
                                              // displayDueDate = date.toString();
                                              setState(() {});
                                            },
                                            locale: LocaleType.en,
                                          );
                                        },
                                        child: Text(
                                          'Pick Target Date',
                                        ),
                                      ),
                                      displayDueDate != ""
                                          ? Text(
                                              'Target Date: $displayDueDate',
                                            )
                                          : Container(),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Name/ Vendor Code of Contractor',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                          child: DropdownButtonFormField(
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                                color: Colors.black),
                                            items: nameOfContractor.map((map) {
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
                                                _nameOfContractorDropdownSelection =
                                                    newVal;
                                                for (Map m
                                                    in nameOfContractor) {
                                                  if (m['key'] == newVal) {
                                                    contractNo =
                                                        m['contractNo'];
                                                    contractValue =
                                                        m['contractValue'];
                                                    vendorType =
                                                        m['vendorType'];
                                                    invoiceAmount =
                                                        m['procInvoiceValue'];
                                                    emailID = m['emailId'];
                                                    mobileNo = m['mobileNo'];
                                                  }
                                                }
                                              });
                                            },
                                          )),
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      contractNo != ""
                                          ? Column(
                                              children: [
                                                Text(
                                                  'Contract No.',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  contractNo,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                                Text(
                                                  'Contract Value',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  contractValue,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                                Text(
                                                  'Vendor Type',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  vendorType,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                                Text(
                                                  'Invoice Amount (Cumulative)',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  invoiceAmount,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                                Text(
                                                  'Email ID',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  emailID,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 30,
                                                  ),
                                                ),
                                                Text(
                                                  'Mobile No.',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Container(
                                                  child: const SizedBox(
                                                    height: 10,
                                                  ),
                                                ),
                                                Text(
                                                  mobileNo,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
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
                                    ]
                                  : <Widget>[
                                      Container(
                                        child: const SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      Text(
                                        'Rejection Remarks',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                              primaryColor:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor),
                                          child: TextFormField(
                                            controller:
                                                _descriptionFieldController,
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
                                                    'Maximum 100 Characters are allowed',
                                                hintStyle: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic)),
                                            keyboardType:
                                                TextInputType.multiline,
                                            minLines: 1,
                                            maxLength: 100,
                                            maxLines: 5,
                                            validator: (value) =>
                                                value.isEmpty ||
                                                        Validators.removeEmoji
                                                                .removemoji(
                                                                    value) ==
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
                        SizedBox(
                          height: 10.0,
                        ),
                        widget.type == 'A'
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
                                        Text('Submit'),
                                      ],
                                    ),
                                    onPressed: _sumbitButtonEnabled
                                        ? _onSubmitButton
                                        : null,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: CustomTheme.buildLightTheme()
                                            .primaryColor),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Reject'),
                                      ],
                                    ),
                                    onPressed: _rejectButtonEnabled
                                        ? _onRejectButton
                                        : null,
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

  _onSubmitButton() async {
    setState(() {});
    if (_isFormValidated()) {
      setState(() {
        _sumbitButtonEnabled = false;
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
            _sumbitButtonEnabled = true;
          });
        });
      } else {
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_EFMSVENDORRole
                    ? '/EFMSVENDOR/assignContractor'
                    : '/HMOFMO/assignContractor')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "warrantyType": _warrantyTypeDropdownSelection,
              "workPermitType": _workPermitTypeDropdownSelection,
              "targetDate": dueDate,
              "vendorCode": _nameOfContractorDropdownSelection,
              "roCode": widget.complaintInfo.roCode,
              "facility": widget.complaintInfo.facility,
              "facilityCode": widget.complaintInfo.parentCode,
              "roName": widget.complaintInfo.custName,
              "complaintId": widget.complaintInfo.complaintID,
              "natureOfComplaint": widget.complaintInfo.natureOfComplaint,
              "remarks": widget.complaintInfo.remarks,
              "natureOfComplaintCode":
                  widget.complaintInfo.origNatureOfComplaint,
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
                _sumbitButtonEnabled = true;
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
              _sumbitButtonEnabled = true;
            });
          });
        }
      }
    }
  }

  _onRejectButton() async {
    setState(() {});
    if (_isFormValidated()) {
      setState(() {
        _rejectButtonEnabled = false;
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
            _rejectButtonEnabled = true;
          });
        });
      } else {
        var response = await http.post(
            Uri.parse(BASE_URI +
                (_EFMSVENDORRole
                    ? '/EFMSVENDOR/rejectComplaints'
                    : '/HMOFMO/rejectComplaints')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "complaintId": widget.id,
              "rejectRemarks": _descriptionFieldController.text,
              "facility": widget.complaintInfo.facility,
              "custName": widget.complaintInfo.custName,
              "roCode": widget.complaintInfo.roCode,
              "compDate": widget.complaintInfo.complaintDatetime,
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
                _rejectButtonEnabled = true;
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
                _rejectButtonEnabled = true;
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
              _rejectButtonEnabled = true;
            });
          });
        }
      }
    }
  }
}
