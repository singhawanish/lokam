import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:flutter/material.dart';

import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import '../../main.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key key, this.lat, this.long}) : super(key: key);

  final double lat;
  final double long;
  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMapPage> {
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
            infoWindow: InfoWindow(title: 'Captured Location')),
      );
    });
  }

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
                    top: MediaQuery.of(context).padding.top, left: 0, right: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: AppBar().preferredSize.height,
                        child: Center(
                          child: Text(
                            'Google Map',
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
                        Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.95,
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: GoogleMap(
                              markers: _markers,
                              myLocationEnabled: true,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: _initialPosition,
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
}
