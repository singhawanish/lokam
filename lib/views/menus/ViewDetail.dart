import 'dart:convert';

import 'package:jwt_decode/jwt_decode.dart';
// import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../utils/networkUtil.dart';
import '../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../loginPage.dart';
import 'package:http/http.dart' as http;

import '../userVerification.dart';
import 'FindLeadHelper/leads_list_view.dart';

class ViewDetailPage extends StatefulWidget {
  const ViewDetailPage({Key key, this.id, this.leadData, this.callback})
      : super(key: key);

  final String id;
  final LeadsListData leadData;

  final VoidCallback callback;
  @override
  _ViewDetailState createState() => _ViewDetailState();
}

class _ViewDetailState extends State<ViewDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final leadStatusDropdownState = GlobalKey<FormFieldState>();
  final industryDropdownState = GlobalKey<FormFieldState>();
  final emailOptOutDropdownState = GlobalKey<FormFieldState>();

  String _leadStatusDropdownSelection;
  List<Map> leadStatusMap = [];
  String _industryDropdownSelection;
  List<Map> industryMap = [];
  String _emailOptOutDropdownSelection;
  List<Map> emailOptOutMap = [];
  final _companyNameFieldController = TextEditingController();
  final _contactPersonNameFieldController = TextEditingController();
  final _locationFieldController = TextEditingController();
  final _cityFieldController = TextEditingController();
  final _pinCodeFieldController = TextEditingController();
  final _emailIdFieldController = TextEditingController();
  final _mobileFieldController = TextEditingController();
  final _websiteFieldController = TextEditingController();
  final _reasonFieldController = TextEditingController();
  final _vehicleFieldController = TextEditingController();
  final _dieselKLPMFieldController = TextEditingController();
  final _DEFKLPMFieldController = TextEditingController();
  final _lubricantKLPMFieldController = TextEditingController();
  bool _reasonRequired = false;
  bool _DSARole = false;

  bool _buttonEnabled = true;
  String jwt;
  String name;

  List<String> wing = [];
  List<Map<String, String>> floor = [];
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
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
            (_DSARole ? '/DSA/getAllLeadStatus' : '/HMOFMO/getAllLeadStatus')),
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
            temp['descRequired'] = element['descRequired'] as String;
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
      response = await http.post(
          Uri.parse(BASE_URI +
              (_DSARole ? '/DSA/getLeadDetails' : '/HMOFMO/getLeadDetails')),
          headers: {
            'Content-type': 'application/json',
            "Accept": "application/json",
            "Authorization": jwt
          },
          body: jsonEncode({
            "id": widget.id,
          }));
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        bool status = map['status'] as bool;

        if (status) {
          List<dynamic> data = map['data'];
          data.forEach((element) {
            _companyNameFieldController.text = element['companyName'] as String;
            _contactPersonNameFieldController.text =
                element['contactPersonName'] as String;
          //  debugPrint('_leadFunctionValue::$_companyNameFieldController.text');
            _locationFieldController.text = element['location'] as String;
            _cityFieldController.text = element['city'] as String;
            _pinCodeFieldController.text = element['pincode'] as String;
            _emailIdFieldController.text = element['emailID'] as String;
            _mobileFieldController.text = element['mobileNo'] as String;
            _websiteFieldController.text = element['website'] as String;
            _vehicleFieldController.text = element['vehicles'] as String;
            _dieselKLPMFieldController.text = element['diesel'] as String;
            _DEFKLPMFieldController.text = element['def'] as String;
            _lubricantKLPMFieldController.text = element['lubricant'] as String;
            leadStatusDropdownState.currentState
                .didChange(element['leadStatus'] as String);
            industryDropdownState.currentState
                .didChange(element['industry'] as String);
            emailOptOutDropdownState.currentState
                .didChange(element['emailOptOut'] as String);
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
                            'View Lead Detail',
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
                                // Text(
                                //   'Function',
                                //   style: TextStyle(
                                //     fontWeight: FontWeight.w500,
                                //     fontSize: 18,
                                //   ),
                                // ),
                                // Container(
                                //   child: const SizedBox(
                                //     height: 10,
                                //   ),
                                // ), Text(
                                //   widget.leadData.leadFunction,
                                //   style: TextStyle(
                                //     fontStyle: FontStyle.italic,
                                //     fontSize: 18,
                                //   ),
                                // ),
                                // Container(
                                //   child: const SizedBox(
                                //     height: 40,
                                //   ),
                                // ),
                                widget.leadData.companyName != ''
                                    ? Column(
                                        children: [
                                          Text(
                                            'Company Name',
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
                                            widget.leadData.companyName,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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

                                widget.leadData.contactPersonName != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.contactPersonName,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.location != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.location,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.city != ''
                                    ? Column(
                                        children: [
                                          Text(
                                            'City',
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
                                            widget.leadData.city,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.pinCode != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.pinCode,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.emailId != ''
                                    ? Column(
                                        children: [
                                          Text(
                                            'Email-ID',
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
                                            widget.leadData.emailId,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.mobileNo != ''
                                    ? Column(
                                        children: [
                                          Text(
                                            'Mobile No.',
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
                                            widget.leadData.mobileNo,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.website != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.website,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                widget.leadData.vehicles != ''
                                    ? Column(
                                        children: [
                                          Text(
                                            'No. of Vehicles',
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
                                            widget.leadData.vehicles,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.diesel != ''
                                    ? Column(
                                        children: [
                                          Text(
                                            'Diesel Monthly Consumption',
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
                                            widget.leadData.diesel,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.def != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.def,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.lubricant != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.lubricant,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.productCategory != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.productCategory,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.monthlyRequirement != ''
                                    ? Column(
                                        children: [
                                          Text(
                                            'Monthly Requirements (in Standard UoM)',
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
                                            widget.leadData.monthlyRequirement,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.presentlySourcingFrom != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget
                                                .leadData.presentlySourcingFrom,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                                widget.leadData.whetherOMCCustomer != ''
                                    ? Column(
                                        children: [
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
                                          Text(
                                            widget.leadData.whetherOMCCustomer,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
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
                (_DSARole ? '/DSA/updateLead' : '/HMOFMO/updateLead')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "id": widget.id,
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
              "reason": _reasonFieldController.text,
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
                      child: Text('Lead Updation Failed'),
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
