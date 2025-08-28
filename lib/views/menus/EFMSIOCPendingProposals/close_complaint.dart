import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../../utils/CustomTextInputFormatter.dart';
import '../../../utils/MyPdfViewer.dart';
import '../../../utils/networkUtil.dart';
import '../../../utils/validators.dart';
import '../../../views/themes/custom_theme.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../loginPage.dart';
import 'package:http/http.dart' as http;

import '../../userVerification.dart';
import 'complaints_list_view.dart';
import 'package:flutter_icons/flutter_icons.dart';

class CloseComplaintPage extends StatefulWidget {
  const CloseComplaintPage(
      {Key key, this.complaintInfo, this.type, this.callback})
      : super(key: key);

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
  final _otpFieldController = TextEditingController();
  String displayDueDate = "";
  String dueDate = "";

  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  bool _EFMSVENDORRole = false;
  bool _sumbitButtonEnabled = true;
  bool _resendButtonEnabled = true;
  bool _confirmButtonEnabled = true;
  String workStartedButton = '';
  String closeButton = '';
  String nonClosedWorkPermits = '';
  String jwt;
  String name;
  bool shallProceed = true;

  Map proposalBasicInfo = Map();
  List<Map> workPermitType = [];
  List<Map> nameOfContractor = [];
  String _nameOfContractorDropdownSelection = 'Select';
  String contractNo = "";
  String contractValue = "";
  String vendorType = "";
  String invoiceAmount = "";
  String emailID = "";
  String mobileNo = "";

  List<Map> statusType = [];
  String _statusTypeDropdownSelection = '';

  List<Map> WorkflowMap = [];
  List<Map> NextLevelMap = [];

  List<DataColumn> dataColumn1 = [];
  List<DataRow> dataRow1 = [];
  List<Map<String, dynamic>> Globalrows1 = [];
  List<DataColumn> dataColumn2 = [];
  List<DataRow> dataRow2 = [];
  List<Map<String, dynamic>> Globalrows2 = [];

  String pdfUrl = '';
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  File file;

  DataTable _createDataTable1() {
    return DataTable(
      columns: _createColumns1(),
      rows: _createRows1(),
    );
  }

  List<DataColumn> _createColumns1() {
    return dataColumn1;
  }

  List<DataRow> _createRows1() {
    dataRow1 = [];
    Globalrows1.forEach((element) {
      List<DataCell> temporary = [];
      element.forEach((key, value) {
        temporary.add(DataCell(Text(value.toString())));
      });
      dataRow1.add(DataRow(cells: temporary));
    });

    return dataRow1;
  }

  DataTable _createDataTable2() {
    return DataTable(
      columns: _createColumns2(),
      rows: _createRows2(),
    );
  }

  List<DataColumn> _createColumns2() {
    return dataColumn2;
  }

  List<DataRow> _createRows2() {
    dataRow2 = [];
    Globalrows2.forEach((element) {
      List<DataCell> temporary = [];
      element.forEach((key, value) {
        temporary.add(DataCell(Text(value.toString())));
      });
      dataRow2.add(DataRow(cells: temporary));
    });

    return dataRow2;
  }

  @override
  void initState() {
    proposalBasicInfo['subject'] = '';
    proposalBasicInfo['custCity'] = '';
    proposalBasicInfo['salesoffName'] = '';
    proposalBasicInfo['siteType'] = '';
    proposalBasicInfo['roMktDesc'] = '';
    proposalBasicInfo['addr'] = '';
    proposalBasicInfo['salesArea'] = '';
    proposalBasicInfo['district'] = '';
    proposalBasicInfo['rocode'] = '';
    proposalBasicInfo['cust_name'] = '';
    proposalBasicInfo['facility'] = '';
    proposalBasicInfo['nature_of_complaint'] = '';
    proposalBasicInfo['remarks'] = '';
    proposalBasicInfo['vendor_code'] = '';
    proposalBasicInfo['vendor_name'] = '';
    proposalBasicInfo['invoice_status'] = '';
    proposalBasicInfo['bill_no'] = '';
    proposalBasicInfo['bill_date'] = '';
    proposalBasicInfo['bill_amount'] = '';
    proposalBasicInfo['other_doc'] = '';
    proposalBasicInfo['dealer_fac_doc'] = '';
    proposalBasicInfo['e_invoice_appl'] = '';
    proposalBasicInfo['irn_no'] = '';
    proposalBasicInfo['admin_app_status'] = '';
    proposalBasicInfo['admin_prop_no'] = '';
    proposalBasicInfo['admin_app_req'] = '';
    proposalBasicInfo['doa'] = '';
    proposalBasicInfo['work_start_date'] = '';
    proposalBasicInfo['work_end_date'] = '';
    proposalBasicInfo['reference'] = '';
    proposalBasicInfo['date'] = '';
    proposalBasicInfo['status'] = '';
    proposalBasicInfo['proposalNo'] = '';
    proposalBasicInfo['proposalDetail'] = '';
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
              ? '/EFMSVENDOR/getProposalInfo'
              : '/HMOFMO/getProposalInfo')),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
        "Authorization": jwt
      },
      body: jsonEncode({
        "distCode": widget.complaintInfo.roCode,
        "proposal_no": widget.complaintInfo.proposalNo,
        "proposal_id": widget.complaintInfo.proposalId,
        "proposal_sub_id": widget.complaintInfo.subProposalId,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      bool status = map['status'] as bool;

      if (status) {
        dynamic data = map['data'];
        proposalBasicInfo['subject'] =
            data['subject'] == null ? '' : data['subject'] as String;
        proposalBasicInfo['custCity'] =
            data['custCity'] == null ? '' : data['custCity'] as String;
        proposalBasicInfo['salesoffName'] =
            data['salesoffName'] == null ? '' : data['salesoffName'] as String;
        proposalBasicInfo['siteType'] =
            data['siteType'] == null ? '' : data['siteType'] as String;
        proposalBasicInfo['roMktDesc'] =
            data['roMktDesc'] == null ? '' : data['roMktDesc'] as String;
        proposalBasicInfo['addr'] =
            data['addr'] == null ? '' : data['addr'] as String;
        proposalBasicInfo['salesArea'] =
            data['salesArea'] == null ? '' : data['salesArea'] as String;
        proposalBasicInfo['district'] =
            data['district'] == null ? '' : data['district'] as String;
        proposalBasicInfo['rocode'] =
            data['rocode'] == null ? '' : data['rocode'] as String;
        proposalBasicInfo['cust_name'] =
            data['cust_name'] == null ? '' : data['cust_name'] as String;
        proposalBasicInfo['facility'] =
            data['facility'] == null ? '' : data['facility'] as String;
        proposalBasicInfo['nature_of_complaint'] = data['subject'] == null
            ? ''
            : data['nature_of_complaint'] as String;
        proposalBasicInfo['remarks'] =
            data['remarks'] == null ? '' : data['remarks'] as String;
        proposalBasicInfo['vendor_code'] =
            data['vendor_code'] == null ? '' : data['vendor_code'] as String;
        proposalBasicInfo['vendor_name'] =
            data['vendor_name'] == null ? '' : data['vendor_name'] as String;
        proposalBasicInfo['invoice_status'] = data['invoice_status'] == null
            ? ''
            : data['invoice_status'] as String;
        proposalBasicInfo['bill_no'] =
            data['bill_no'] == null ? '' : data['bill_no'] as String;
        proposalBasicInfo['bill_date'] =
            data['bill_date'] == null ? '' : data['bill_date'] as String;
        proposalBasicInfo['bill_amount'] =
            data['bill_amount'] == null ? '' : data['bill_amount'] as String;
        proposalBasicInfo['other_doc'] =
            data['other_doc'] == null ? '' : data['other_doc'] as String;
        proposalBasicInfo['dealer_fac_doc'] = data['dealer_fac_doc'] == null
            ? ''
            : data['dealer_fac_doc'] as String;
        proposalBasicInfo['e_invoice_appl'] = data['e_invoice_appl'] == null
            ? ''
            : data['e_invoice_appl'] as String;
        proposalBasicInfo['irn_no'] =
            data['irn_no'] == null ? '' : data['irn_no'] as String;
        proposalBasicInfo['admin_app_status'] = data['admin_app_status'] == null
            ? ''
            : data['admin_app_status'] as String;
        proposalBasicInfo['admin_prop_no'] = data['admin_prop_no'] == null
            ? ''
            : data['admin_prop_no'] as String;
        proposalBasicInfo['admin_app_req'] = data['admin_app_req'] == null
            ? ''
            : data['admin_app_req'] as String;
        proposalBasicInfo['doa'] =
            data['doa'] == null ? '' : data['doa'] as String;
        proposalBasicInfo['work_start_date'] = data['work_start_date'] == null
            ? ''
            : data['work_start_date'] as String;
        proposalBasicInfo['work_end_date'] = data['work_end_date'] == null
            ? ''
            : data['work_end_date'] as String;
        proposalBasicInfo['reference'] =
            data['reference'] == null ? '' : data['reference'] as String;
        proposalBasicInfo['date'] =
            data['date'] == null ? '' : data['date'] as String;
        proposalBasicInfo['status'] =
            data['status'] == null ? '' : data['status'] as String;
        proposalBasicInfo['proposalNo'] =
            data['proposalNo'] == null ? '' : data['proposalNo'] as String;
        proposalBasicInfo['proposalDetail'] = data['proposalDetail'] == null
            ? ''
            : data['proposalDetail'] as String;
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
        Uri.parse(BASE_URI + ('/HMOFMO/getPendingProposalWorkflowSectionData')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
        body: jsonEncode({
          "proposalNo": proposalBasicInfo['proposalNo'],
        }));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      bool status = map['status'] as bool;
      String code = map['code'] as String;
      String msg = map['msg'] as String;
      if (status) {
        if (code == '001') {
          Map<String, dynamic> data = map['data'];
          List<dynamic> headers = data['header'];
          List<dynamic> rows = data['detail'];
          dataColumn1 = [];
          Globalrows1 = [];
          dataRow1 = [];
          rows.forEach((element) {
            Map<String, dynamic> singleRow = element as Map<String, dynamic>;
            Map<String, dynamic> GlobalSingleRow = Map<String, dynamic>();
            headers.forEach((element) {
              try {
                GlobalSingleRow[element as String] =
                    int.parse(singleRow[element as String]);
              } catch (e) {
                try {
                  GlobalSingleRow[element as String] =
                      double.parse(singleRow[element as String]);
                } catch (ee) {
                  GlobalSingleRow[element as String] =
                      singleRow[element as String];
                }
              }
            });
            Globalrows1.add(GlobalSingleRow);
          });
          headers.forEach((element) {
            dataColumn1.add(DataColumn(
              label: Text(element as String),
              onSort: (columnIndex, _) {
                setState(() {});
              },
            ));
          });
          setState(() {});
        } else if (code == '900' && msg != null) {
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
            setState(() {});
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
                    child: Text('Data Fetch Failed'),
                  ),
                ),
              )
              .closed
              .then((reason) {
            setState(() {});
          });
        }
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
      setState(() {});
    }

    response = await http.post(
        Uri.parse(
            BASE_URI + ('/HMOFMO/getPendingProposalNextLevelDetailsData')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
        body: jsonEncode({
          "proposalNo": proposalBasicInfo['proposalNo'],
        }));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      bool status = map['status'] as bool;
      String code = map['code'] as String;
      String msg = map['msg'] as String;
      if (status) {
        if (code == '001') {
          Map<String, dynamic> data = map['data'];
          List<dynamic> headers = data['header'];
          List<dynamic> rows = data['detail'];
          dataColumn2 = [];
          Globalrows2 = [];
          dataRow2 = [];
          rows.forEach((element) {
            Map<String, dynamic> singleRow = element as Map<String, dynamic>;
            Map<String, dynamic> GlobalSingleRow = Map<String, dynamic>();
            headers.forEach((element) {
              try {
                GlobalSingleRow[element as String] =
                    int.parse(singleRow[element as String]);
              } catch (e) {
                try {
                  GlobalSingleRow[element as String] =
                      double.parse(singleRow[element as String]);
                } catch (ee) {
                  GlobalSingleRow[element as String] =
                      singleRow[element as String];
                }
              }
            });
            Globalrows2.add(GlobalSingleRow);
          });
          headers.forEach((element) {
            dataColumn2.add(DataColumn(
              label: Text(element as String),
              onSort: (columnIndex, _) {
                setState(() {});
              },
            ));
          });
          setState(() {});
        } else if (code == '900' && msg != null) {
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
            setState(() {});
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
                    child: Text('Data Fetch Failed'),
                  ),
                ),
              )
              .closed
              .then((reason) {
            setState(() {});
          });
        }
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
      setState(() {});
    }

    response = await http.post(
        Uri.parse(BASE_URI +
            (_EFMSVENDORRole
                ? '/EFMSVENDOR/getProposalTodoStatus'
                : '/HMOFMO/getProposalTodoStatus')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
        body: jsonEncode({
          "proposalNo": proposalBasicInfo['proposalNo'],
          "proposalId": widget.complaintInfo.proposalId,
        }));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      bool status = map['status'] as bool;

      if (status) {
        List<dynamic> data = map['data'];

        data.forEach((element) {
          var temp = Map();
          temp['key'] = element['key'] as String;
          temp['value'] = element['value'] as String;
          statusType.add(temp);
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

  void fetchPdfData(String number) async {
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
      if ((element as String) == 'EFMSVENDOR') {
        _EFMSVENDORRole = true;
      }
    });
    var response =
        await http.post(Uri.parse(BASE_URI + ('/HMOFMO/getInvoiceDoc')),
            headers: {
              'Content-type': 'application/json',
              "Accept": "application/json",
              "Authorization": jwt
            },
            body: jsonEncode({
              "complaint_id": proposalBasicInfo['proposalDetail'],
              "doc_id": number,
            }));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      bool status = map['status'] as bool;
      String code = map['code'] as String;
      String msg = map['msg'] as String;
      if (status) {
        if (code == '001') {
          pdfUrl = map['data'] as String;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyPdfViewer(base64Pdf: pdfUrl),
              // MyPdfViewer(base64Pdf: 'data:application/pdf;base64,$pdfUrl'),
            ),
          );
          setState(() {});
        } else if (code == '900' && msg != null) {
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
            setState(() {});
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
                    child: Text('Data Fetch Failed'),
                  ),
                ),
              )
              .closed
              .then((reason) {
            setState(() {});
          });
        }
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
      setState(() {});
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
                            'Pending Proposals',
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
                                  'SUBJECT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['subject'],
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
                                  'Ref:' + proposalBasicInfo['reference'],
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
                                  'Date:' + proposalBasicInfo['date'],
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
                                  'Status:' + proposalBasicInfo['status'],
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
                                  'Proposal No.:' +
                                      proposalBasicInfo['proposalNo'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Contractor Claim Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 20,
                                  ),
                                ),
                                Text(
                                  'SAP Code of RO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['rocode'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Name of RO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['cust_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Complaint No.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['proposalDetail'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Facility Requiring Maintenance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['facility'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Nature of Complaint',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['nature_of_complaint'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Description of Complaint',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['remarks'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Vendor Code of Contractor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['vendor_code'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Name of Contractor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['vendor_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'E-Invoice with QR code / IRN applicable?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['e_invoice_appl'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Invoice No.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['bill_no'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Invoice Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['bill_date'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Invoice Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['bill_amount'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                proposalBasicInfo['e_invoice_appl'] == 'Yes'
                                    ? Column(
                                        children: [
                                          Text(
                                            'IRN No.',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            proposalBasicInfo['irn_no'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Container(
                                            child: const SizedBox(
                                              height: 10,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                proposalBasicInfo['e_invoice_appl'] == ' '
                                    ? Column(
                                        children: [
                                          Text(
                                            'Invoice Document',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  fetchPdfData("6");
                                                },
                                                icon: Icon(
                                                  FlutterIcons.file_pdf_o_faw,
                                                  size: 30.0,
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .disabled)) {
                                                        return Colors
                                                            .grey; // Color when button is disabled
                                                      }
                                                      return CustomTheme
                                                              .buildLightTheme()
                                                          .primaryColor; // Color when button is enabled
                                                    },
                                                  ),
                                                ),
                                                label: Text('PDF'),
                                              ),
                                            ],
                                          ),
                                          // Text(
                                          //   'invoice document',
                                          //   style: TextStyle(
                                          //     fontWeight: FontWeight.w400,
                                          //     fontSize: 18,
                                          //   ),
                                          // ),
                                          Container(
                                            child: const SizedBox(
                                              height: 10,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(children: [
                                        Text(
                                          'BOQMS Document',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                fetchPdfData("6");
                                              },
                                              icon: Icon(
                                                FlutterIcons.file_pdf_o_faw,
                                                size: 30.0,
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .disabled)) {
                                                      return Colors
                                                          .grey; // Color when button is disabled
                                                    }
                                                    return CustomTheme
                                                            .buildLightTheme()
                                                        .primaryColor; // Color when button is enabled
                                                  },
                                                ),
                                              ),
                                              label: Text('PDF'),
                                            ),
                                          ],
                                        ),
                                        // Text(
                                        //   'boqms document',
                                        //   style: TextStyle(
                                        //     fontWeight: FontWeight.w400,
                                        //     fontSize: 18,
                                        //   ),
                                        // ),
                                        Container(
                                          child: const SizedBox(
                                            height: 10,
                                          ),
                                        ),
                                        Text(
                                          'Invoice Document',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),

                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                fetchPdfData("1");
                                              },
                                              icon: Icon(
                                                FlutterIcons.file_pdf_o_faw,
                                                size: 30.0,
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .disabled)) {
                                                      return Colors
                                                          .grey; // Color when button is disabled
                                                    }
                                                    return CustomTheme
                                                            .buildLightTheme()
                                                        .primaryColor; // Color when button is enabled
                                                  },
                                                ),
                                              ),
                                              label: Text('PDF'),
                                            ),
                                          ],
                                        ),
                                        // Text(
                                        //   'invoice document',
                                        //   style: TextStyle(
                                        //     fontWeight: FontWeight.w400,
                                        //     fontSize: 18,
                                        //   ),
                                        // ),
                                        Container(
                                          child: const SizedBox(
                                            height: 10,
                                          ),
                                        ),
                                      ]),
                                proposalBasicInfo['e_invoice_appl'] == 'No'
                                    ? Column(
                                        children: [
                                          Text(
                                            'Declaration for Turnover less than 50 Cr',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  fetchPdfData("5");
                                                },
                                                icon: Icon(
                                                  FlutterIcons.file_pdf_o_faw,
                                                  size: 30.0,
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .disabled)) {
                                                        return Colors
                                                            .grey; // Color when button is disabled
                                                      }
                                                      return CustomTheme
                                                              .buildLightTheme()
                                                          .primaryColor; // Color when button is enabled
                                                    },
                                                  ),
                                                ),
                                                label: Text('PDF'),
                                              ),
                                            ],
                                          ),
                                          // Text(
                                          //   'declaration',
                                          //   style: TextStyle(
                                          //     fontWeight: FontWeight.w400,
                                          //     fontSize: 18,
                                          //   ),
                                          // ),
                                          Container(
                                            child: const SizedBox(
                                              height: 10,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                Text(
                                  "Dealer's Letter",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                proposalBasicInfo['dealer_fac_doc'] == 'YES'
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              fetchPdfData("2");
                                            },
                                            icon: Icon(
                                              FlutterIcons.file_pdf_o_faw,
                                              size: 30.0,
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.disabled)) {
                                                    return Colors
                                                        .grey; // Color when button is disabled
                                                  }
                                                  return CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor; // Color when button is enabled
                                                },
                                              ),
                                            ),
                                            label: Text('PDF'),
                                          ),
                                        ],
                                      )
                                    // Text(
                                    //     'dealer letter',
                                    //     style: TextStyle(
                                    //       fontWeight: FontWeight.w400,
                                    //       fontSize: 18,
                                    //     ),
                                    //   )
                                    : Container(),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                proposalBasicInfo['other_doc'] == 'YES'
                                    ? Column(
                                        children: [
                                          Text(
                                            'Other Document',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  fetchPdfData("3");
                                                },
                                                icon: Icon(
                                                  FlutterIcons.file_pdf_o_faw,
                                                  size: 30.0,
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .disabled)) {
                                                        return Colors
                                                            .grey; // Color when button is disabled
                                                      }
                                                      return CustomTheme
                                                              .buildLightTheme()
                                                          .primaryColor; // Color when button is enabled
                                                    },
                                                  ),
                                                ),
                                                label: Text('PDF'),
                                              ),
                                            ],
                                          ),
                                          // Text(
                                          //   'other document',
                                          //   style: TextStyle(
                                          //     fontWeight: FontWeight.w400,
                                          //     fontSize: 18,
                                          //   ),
                                          // ),
                                          Container(
                                            child: const SizedBox(
                                              height: 10,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                Text(
                                  'Admin Approval No. (Amount > 50k)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['admin_prop_no'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'DOA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['doa'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'Start Date of Work',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['work_start_date'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'End Date of Work',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  proposalBasicInfo['work_end_date'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 40,
                                  ),
                                ),
                                Text(
                                  'WorkFlow Section',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                dataColumn1.length == 0
                                    ? Container()
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: _createDataTable1())),
                                      ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Next Level Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                dataColumn2.length == 0
                                    ? Container()
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: _createDataTable2())),
                                      ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Declaration',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 20,
                                  ),
                                ),
                                Text(
                                  'Action',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
                                      items: statusType.map((map) {
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
                                          _statusTypeDropdownSelection = newVal;
                                        });
                                      },
                                    )),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
                                  ),
                                ),
                                Text(
                                  'Remarks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 30,
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
                                      inputFormatters: <TextInputFormatter>[
                                        CustomTextInputFormatter()
                                      ],
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
                                              'Maximum 1500 characters are allowed',
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                      keyboardType: TextInputType.multiline,
                                      minLines: 1,
                                      maxLength: 1500,
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
                        SizedBox(
                          height: 10.0,
                        ),
                        shallProceed
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
                                        Text('Proceed'),
                                      ],
                                    ),
                                    onPressed: _sumbitButtonEnabled
                                        ? _onSubmitButton
                                        : null,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Text(
                                    'Enter OTP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 30, right: 30),
                                    child: Theme(
                                      data: ThemeData(
                                          primaryColor:
                                              CustomTheme.buildLightTheme()
                                                  .primaryColor),
                                      child: TextFormField(
                                        controller: _otpFieldController,
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
                                            hintText: 'OTP',
                                            hintStyle: TextStyle(
                                                fontStyle: FontStyle.italic)),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: false, signed: false),
                                        minLines: 1,
                                        maxLength: 20,
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
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Resend OTP'),
                                                ],
                                              ),
                                              onPressed: _resendButtonEnabled
                                                  ? _onResendButton
                                                  : null,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Confirm'),
                                                ],
                                              ),
                                              onPressed: _confirmButtonEnabled
                                                  ? _onConfirmButton
                                                  : null,
                                            ),
                                          ]),
                                    ),
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 40.0,
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
        var response =
            await http.post(Uri.parse(BASE_URI + ('/HMOFMO/sendProposalOTP')),
                headers: {
                  "Accept": "application/json",
                  "Authorization": jwt,
                  'Content-type': 'application/json'
                },
                body: jsonEncode({}));
        if (response.statusCode == 200) {
          Map<String, dynamic> map = jsonDecode(response.body);
          bool flag = map['status'] as bool;
          String code = map['code'] as String;
          String msg = map['msg'] as String;
          if (flag == true && code == '001') {
            setState(() {
              shallProceed = false;
            });

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
                .closed
                .then((reason) {
              setState(() {});
            });
          } else if (flag == true && code == '900') {
            ScaffoldMessenger.of(context)
                .showSnackBar(
                  SnackBar(
                    content: WillPopScope(
                      onWillPop: () async {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        return true;
                      },
                      child: Text("Sending OTP Failed"),
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
                _sumbitButtonEnabled = true;
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

  _onResendButton() async {
    setState(() {});
    if (1 == 1) {
      // if (_isFormValidated()) {
      setState(() {
        _resendButtonEnabled = false;
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
            _resendButtonEnabled = true;
          });
        });
      } else {
        var response =
            await http.post(Uri.parse(BASE_URI + ('/HMOFMO/sendProposalOTP')),
                headers: {
                  "Accept": "application/json",
                  "Authorization": jwt,
                  'Content-type': 'application/json'
                },
                body: jsonEncode({}));
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
                      child: Text("OTP Re-Sent"),
                    ),
                  ),
                )
                .closed
                .then((reason) {
              setState(() {
                _resendButtonEnabled = true;
              });
            });
          } else if (flag == true && code == '900') {
            ScaffoldMessenger.of(context)
                .showSnackBar(
                  SnackBar(
                    content: WillPopScope(
                      onWillPop: () async {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        return true;
                      },
                      child: Text("Sending OTP Failed"),
                    ),
                  ),
                )
                .closed
                .then((reason) {
              setState(() {
                _resendButtonEnabled = true;
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
                _resendButtonEnabled = true;
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
              _resendButtonEnabled = true;
            });
          });
        }
      }
    }
  }

  _onConfirmButton() async {
    setState(() {});
    if (_isFormValidated()) {
      setState(() {
        _confirmButtonEnabled = false;
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
            _confirmButtonEnabled = true;
          });
        });
      } else {
        var response = await http.post(
            Uri.parse(BASE_URI + ('/HMOFMO/validateProposalOTP')),
            headers: {
              "Accept": "application/json",
              "Authorization": jwt,
              'Content-type': 'application/json'
            },
            body: jsonEncode({
              "otp": _otpFieldController.text,
              "prop_id": proposalBasicInfo['proposalNo'],
              "ro_code": proposalBasicInfo['rocode'],
              "remarks": _descriptionFieldController.text,
              "sts": _statusTypeDropdownSelection,
              "proposal_id": widget.complaintInfo.proposalId,
              "proposal_sub_id": widget.complaintInfo.subProposalId,
              "refno": proposalBasicInfo['reference'],
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
                _confirmButtonEnabled = true;
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
                _confirmButtonEnabled = true;
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
              _confirmButtonEnabled = true;
            });
          });
        }
      }
    }
  }
}
