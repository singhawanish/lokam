import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:ioclcustomerconnect/utils/networkUtil.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../main.dart';
import '../loginPage.dart';
import '../themes/custom_theme.dart';
import 'package:http/http.dart' as http;

import '../userVerification.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<Map> MISTypeMap = [];
  final ScrollController _scrollController = ScrollController();
  String _MISTypeDropdownSelection;

  bool _DSARole = false;
  bool _DHABARole = false;
  bool _DEALERRole = false;
  bool _EFMSVENDORRole = false;
  String jwt;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  List data = ['Last 30 Days', 'Total'];
  String _dropdownSelection = 'Last 30 Days';
  List<DataColumn> dataColumn = [];
  List<DataRow> dataRow = [];
  List<Map<String, dynamic>> Globalrows = [];
  String displayFromDate = "";
  String fromDate = "";
  String displayToDate = "";
  String toDate = "";
  bool _buttonEnabled = true;
  int _currentSortColumn = 0;
  bool _isSortAsc = true;
  String label = "Get Data";

  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
  }

  Future<void> getData(String misType) async {
    setState(() {
      _buttonEnabled = false;
      label = "Fetching Data";
    });
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
      if ((element as String) == 'DSA') {
        _DSARole = true;
      }
      if ((element as String) == 'DHABA') {
        _DHABARole = true;
      }
      if ((element as String) == 'DEALER') {
        _DEALERRole = true;
      }
      if ((element as String) == 'EFMSVENDOR') {
        _EFMSVENDORRole = true;
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
      setState(() {
        _buttonEnabled = true;
        label = "Get Data";
      });
    } else {
      var response = await http.post(
        Uri.parse(BASE_URI +
            (_DSARole
                ? '/DSA/getMISData'
                : _DHABARole
                    ? '/DHABA/getMISData'
                    : _DEALERRole
                        ? '/DEALER/getMISData'
                        : _EFMSVENDORRole
                            ? '/EFMSVENDOR/getMISData'
                            : '/HMOFMO/getMISData')),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
          "Authorization": jwt
        },
        body: jsonEncode({
          "type": misType,
          "fromDate": fromDate,
          "toDate": toDate,
        }),
      );
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
            dataColumn = [];
            Globalrows = [];
            dataRow = [];
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
              Globalrows.add(GlobalSingleRow);
            });
            headers.forEach((element) {
              dataColumn.add(DataColumn(
                label: Text(element as String),
                onSort: (columnIndex, _) {
                  setState(() {
                    _currentSortColumn = columnIndex;
                    if (_isSortAsc) {
                      Globalrows.sort((a, b) =>
                          b[element as String].compareTo(a[element as String]));
                    } else {
                      Globalrows.sort((a, b) =>
                          a[element as String].compareTo(b[element as String]));
                    }
                    _isSortAsc = !_isSortAsc;
                  });
                },
              ));
            });
            setState(() {
              _buttonEnabled = true;
              label = "Get Data";
            });
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
              setState(() {
                _buttonEnabled = true;
                label = "Get Data";
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
                      child: Text('Data Fetch Failed'),
                    ),
                  ),
                )
                .closed
                .then((reason) {
              setState(() {
                _buttonEnabled = true;
                label = "Get Data";
              });
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
        setState(() {
          _buttonEnabled = true;
          label = "Get Data";
        });
      }
    }
  }

  DataTable _createDataTable() {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(),
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
    );
  }

  List<DataColumn> _createColumns() {
    return dataColumn;
  }

  List<DataRow> _createRows() {
    dataRow = [];
    Globalrows.forEach((element) {
      List<DataCell> temporary = [];
      element.forEach((key, value) {
        temporary.add(DataCell(Text(value.toString())));
      });
      dataRow.add(DataRow(cells: temporary));
    });

    return dataRow;
  }

  Future<void> getMISType() async {
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];
    roles.forEach((element) {
      if ((element as String) == 'DSA') {
        _DSARole = true;
      }
      if ((element as String) == 'DHABA') {
        _DHABARole = true;
      }
      if ((element as String) == 'DEALER') {
        _DEALERRole = true;
      }
      if ((element as String) == 'EFMSVENDOR') {
        _EFMSVENDORRole = true;
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
                ? '/DSA/getMISType'
                : _DHABARole
                    ? '/DHABA/getMISType'
                    : _DEALERRole
                        ? '/DEALER/getMISType'
                        : _EFMSVENDORRole
                            ? '/EFMSVENDOR/getMISType'
                            : '/HMOFMO/getMISType')),
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
            MISTypeMap.add(temp);
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
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    getMISType();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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
                            'Consolidated Summary',
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
                                  '*Type of MIS',
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
                                      items: MISTypeMap.map((map) {
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
                                          _MISTypeDropdownSelection = newVal;
                                          // getData(newVal);
                                        });
                                      },
                                      // value: _industryDropdownSelection,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                Text(
                                  'Reports with * will require Date Range ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: CustomTheme.buildLightTheme()
                                          .primaryColor),
                                  onPressed: () {
                                    DatePicker.showDatePicker(
                                      context,
                                      showTitleActions: true,
                                      // minTime: DateTime.now(),
                                      maxTime: DateTime(2041),
                                      onConfirm: (date) {
                                        fromDate =
                                            DateFormat('yyyyMMdd').format(date);
                                        displayFromDate =
                                            DateFormat('dd-MM-yyyy')
                                                .format(date);
                                        // displayFromDate = date.toString();
                                        setState(() {});
                                      },
                                      locale: LocaleType.en,
                                    );
                                  },
                                  child: Text(
                                    'Pick From Date',
                                  ),
                                ),
                                displayFromDate != ""
                                    ? Text(
                                        'Picked From Date: $displayFromDate',
                                      )
                                    : Container(),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: CustomTheme.buildLightTheme()
                                          .primaryColor),
                                  onPressed: () {
                                    DatePicker.showDatePicker(
                                      context,
                                      showTitleActions: true,
                                      maxTime: DateTime(2041),
                                      onChanged: (date) {
                                        print('change $date in time zone ' +
                                            date.timeZoneOffset.inHours
                                                .toString());
                                      },
                                      onConfirm: (date) {
                                        toDate =
                                            DateFormat('yyyyMMdd').format(date);
                                        displayToDate = DateFormat('dd-MM-yyyy')
                                            .format(date);
                                        // displayToDate = date.toString();
                                        setState(() {});
                                      },
                                      locale: LocaleType.en,
                                    );
                                  },
                                  child: Text(
                                    'Pick To Date',
                                  ),
                                ),
                                displayToDate != ""
                                    ? Text(
                                        'Picked To Date: $displayToDate',
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10.0,
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
                                          Text(label),
                                        ],
                                      ),
                                      onPressed: _buttonEnabled
                                          ? () =>
                                              getData(_MISTypeDropdownSelection)
                                          : null,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: const SizedBox(
                                    height: 10,
                                  ),
                                ),
                                dataColumn.length == 0
                                    ? Container()
                                    // : ListView(
                                    //     shrinkWrap: true,
                                    //     primary: false,
                                    //     scrollDirection: Axis.vertical,
                                    //     children: [_createDataTable()],
                                    //   ),
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: _createDataTable())),
                                      ),
                                Container(
                                  child: const SizedBox(
                                    height: 100,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget getTimeDateUI() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Complaints',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton(
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                color: Colors.black),
                            items: data.map((item) {
                              return DropdownMenuItem(
                                child: Container(
                                  width: width * 0.7,
                                  child: Text(
                                    item,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                value: item.toString(),
                              );
                            }).toList(),
                            onChanged: (newVal) async {
                              _dropdownSelection = newVal;
                              getMISType();
                            },
                            value: _dropdownSelection,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void popupButtonSelected(String value) {}

  Widget getAppBarUI() {
    return Container(
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
                    'My Complaints',
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
    );
  }
}
