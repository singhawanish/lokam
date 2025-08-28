import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';

import 'package:flutter/material.dart';

import '../../../main.dart';
import '../GoogleMap.dart';

class HubsListView extends StatefulWidget {
  const HubsListView({
    Key key,
    this.hubsData,
    this.animationController,
    this.animation,
    this.callback,
    this.parentContext,
    this.refreshCall,
    this.id,
    this.tab,
  }) : super(key: key);

  final VoidCallback callback;
  final HubsListData hubsData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final BuildContext parentContext;
  final Function refreshCall;
  final String id;
  final String tab;
  @override
  _HubsListViewState createState() => _HubsListViewState();
}

class HubsListData {
  HubsListData({
    this.name,
    this.lat,
    this.lng,
    this.createdBy,
  });
  String name;
  String lat;
  String lng;
  String createdBy;
}

class _HubsListViewState extends State<HubsListView> {
  String jwt;
  String name;
  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
    name = await storage.read(key: 'name');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - widget.animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  widget.callback();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        offset: const Offset(4, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Column(
                      children: <Widget>[
                        Container(
                            color:
                                CustomTheme.buildLightTheme().backgroundColor,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 16,
                                            top: 8,
                                            bottom: 8,
                                            left: 16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              widget.hubsData.name,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ])),
                        Container(
                          color: CustomTheme.buildLightTheme().backgroundColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 8, bottom: 8, right: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Created By - " +
                                              widget.hubsData.createdBy,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    4, 0, 4, 0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: CustomTheme
                                                          .buildLightTheme()
                                                      .primaryColor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Location'),
                                                ],
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          GoogleMapPage(
                                                              lat: double.parse(
                                                                  widget
                                                                      .hubsData
                                                                      .lat),
                                                              long: double
                                                                  .parse(widget
                                                                      .hubsData
                                                                      .lng))),
                                                );
                                              },
                                            ),
                                          ),
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
