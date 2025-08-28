import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;

import '../userVerification.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer(
      {Key key,
      this.screenIndex,
      this.iconAnimationController,
      this.callBackIndex})
      : super(key: key);

  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList> drawerList = [];
  List<ExpansionTileList> expansionTile = [];
  String jwt;
  String empName;
  String empDesignation;

  @override
  void initState() {
    // setDrawerListArray();
    setDrawerListArrayDynamic();
    super.initState();
  }

  Future<void> initializeData() async {
    jwt = await storage.read(key: 'jwt');
  }

  void setDrawerListArrayDynamic() async {
    await initializeData();
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    Map<String, dynamic> menus = payload['menu'];
    expansionTile = <ExpansionTileList>[];
    menus.forEach((key, sb) {
      List<DrawerList> subMenus = <DrawerList>[];
      sb.forEach((element) {
        try {
          DrawerList temp = DrawerList(
            index: DrawerIndex.values.firstWhere(
                (e) => e.toString() == (element['index'] as String)),
            labelName: element['label'],
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          );
          subMenus.add(temp);
        } catch (e) {}
      });
      ExpansionTileList menu = ExpansionTileList(
          labelName: key,
          lists: subMenus,
          icon: Icon(
            Icons.escalator_warning,
            color: Colors.orange,
            size: 30,
          ));
      expansionTile.add(menu);
    });
  }

  void setDrawerListArray() async {
    await initializeData();
    drawerList = <DrawerList>[];
    expansionTile = <ExpansionTileList>[];
    Map<String, dynamic> payload = Jwt.parseJwt(jwt);
    payload = payload['sessionData'];
    List<dynamic> roles = payload['role'];

    List<DrawerList> HMOFMO = <DrawerList>[];
    List<DrawerList> SFM = <DrawerList>[];
    List<DrawerList> SRH = <DrawerList>[];
    List<DrawerList> DSA = <DrawerList>[];

    List<DrawerList> opportunityHMOFMO = <DrawerList>[];
    List<DrawerList> opportunitySFM = <DrawerList>[];
    List<DrawerList> opportunitySRH = <DrawerList>[];
    List<DrawerList> opportunityDSA = <DrawerList>[];

    List<DrawerList> monitoringHMOFMO = <DrawerList>[];
    List<DrawerList> monitoringSFM = <DrawerList>[];
    List<DrawerList> monitoringSRH = <DrawerList>[];
    List<DrawerList> monitoringDSA = <DrawerList>[];

    List<DrawerList> mktintelHMOFMO = <DrawerList>[];
    List<DrawerList> mktintelSFM = <DrawerList>[];
    List<DrawerList> mktintelSRH = <DrawerList>[];
    List<DrawerList> mktintelDSA = <DrawerList>[];

    List<DrawerList> TollTransportHubHMOFMO = <DrawerList>[];
    List<DrawerList> TollTransportHubSFM = <DrawerList>[];
    List<DrawerList> TollTransportHubSRH = <DrawerList>[];
    List<DrawerList> TollTransportHubDSA = <DrawerList>[];

    roles.forEach((element) {
      if ((element as String) == 'HMOFMO') {
        List<DrawerList> temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CreateLead,
            labelName: 'Create Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindLead,
            labelName: 'Find Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.ChangeLeadOwner,
            labelName: 'Change Lead Owner',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        HMOFMO.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.FindOpportunity,
            labelName: 'Find Opportunity',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        opportunityHMOFMO.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.OpenActivities,
            labelName: 'Open Activities',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.Escalations,
            labelName: 'Escalations',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.DSAMonitoring,
            labelName: 'DSA Monitoring',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        monitoringHMOFMO.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.MarketIntelligence,
            labelName: 'Market Intelligence',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.MarketIntelligenceRecords,
            labelName: 'Market Intelligence Records',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        mktintelHMOFMO.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CaptureNewHub,
            labelName: 'Capture New Hub',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindHub,
            labelName: 'Find Hubs',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CaptureCampaign,
            labelName: 'Capture Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CampaignDetails,
            labelName: 'Find Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        TollTransportHubHMOFMO.addAll(temp);
        drawerList.addAll(temp);
      }
      if ((element as String) == 'DSA') {
        List<DrawerList> temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CreateLead,
            labelName: 'Create Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindLead,
            labelName: 'Find Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        DSA.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.FindOpportunity,
            labelName: 'Find Opportunity',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        opportunityDSA.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.OpenActivities,
            labelName: 'Open Activities',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        monitoringDSA.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.MarketIntelligence,
            labelName: 'Market Intelligence',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          // DrawerList(
          //   index: DrawerIndex.MarketIntelligenceRecords,
          //   labelName: 'Market Intelligence Records',
          //   icon: Icon(
          //     Icons.receipt,
          //     color: Colors.blue,
          //   ),
          // ),
        ];
        mktintelDSA.addAll(temp);
        drawerList.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CaptureNewHub,
            labelName: 'Capture New Hub',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindHub,
            labelName: 'Find Hubs',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CaptureCampaign,
            labelName: 'Capture Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CampaignDetails,
            labelName: 'Find Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        TollTransportHubDSA.addAll(temp);
        drawerList.addAll(temp);
      }

      if ((element as String) == 'SFM') {
        List<DrawerList> temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CreateLead,
            labelName: 'Create Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindLead,
            labelName: 'Find Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.ChangeLeadOwner,
            labelName: 'Change Lead Owner',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        SFM.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.FindOpportunity,
            labelName: 'Find Opportunity',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        opportunitySFM.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.OpenActivities,
            labelName: 'Open Activities',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.Escalations,
            labelName: 'Escalations',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        monitoringSFM.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.MarketIntelligence,
            labelName: 'Market Intelligence',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.MarketIntelligenceRecords,
            labelName: 'Market Intelligence Records',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        mktintelSFM.addAll(temp);
        drawerList.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CaptureNewHub,
            labelName: 'Capture New Hub',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindHub,
            labelName: 'Find Hubs',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CaptureCampaign,
            labelName: 'Capture Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CampaignDetails,
            labelName: 'Find Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        TollTransportHubSFM.addAll(temp);
        drawerList.addAll(temp);
      }

      if ((element as String) == 'SRH') {
        List<DrawerList> temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CreateLead,
            labelName: 'Create Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindLead,
            labelName: 'Find Lead',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        SRH.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.FindOpportunity,
            labelName: 'Find Opportunity',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        opportunitySRH.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.Escalations,
            labelName: 'Escalations',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        monitoringSRH.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.MarketIntelligence,
            labelName: 'Market Intelligence',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.MarketIntelligenceRecords,
            labelName: 'Market Intelligence Records',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        mktintelSRH.addAll(temp);
        drawerList.addAll(temp);
        drawerList.addAll(temp);
        temp = <DrawerList>[
          DrawerList(
            index: DrawerIndex.CaptureNewHub,
            labelName: 'Capture New Hub',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.FindHub,
            labelName: 'Find Hubs',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CaptureCampaign,
            labelName: 'Capture Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
          DrawerList(
            index: DrawerIndex.CampaignDetails,
            labelName: 'Find Campaign Details',
            icon: Icon(
              Icons.receipt,
              color: Colors.blue,
            ),
          ),
        ];
        TollTransportHubSRH.addAll(temp);
        drawerList.addAll(temp);
      }
    });
    List<DrawerList> temp = <DrawerList>[
      DrawerList(
        index: DrawerIndex.AboutUs,
        labelName: 'About Us',
        icon: Icon(Icons.receipt),
      ),
    ];

    drawerList.addAll(temp);

    for (final element in roles) {
      if ((element as String) == 'HMOFMO') {
        ExpansionTileList temp2 = ExpansionTileList(
            labelName: 'Leads',
            lists: HMOFMO,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp2);
        temp2 = ExpansionTileList(
            labelName: 'Opportunities',
            lists: opportunityHMOFMO,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp2);
        temp2 = ExpansionTileList(
            labelName: 'Monitoring',
            lists: monitoringHMOFMO,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp2);
        temp2 = ExpansionTileList(
            labelName: 'Market Intelligence',
            lists: mktintelHMOFMO,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp2);
        temp2 = ExpansionTileList(
            labelName: 'Toll/Transport Hub',
            lists: TollTransportHubHMOFMO,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp2);
        break;
      }
    }

    for (final element in roles) {
      if ((element as String) == 'DSA') {
        ExpansionTileList temp3 = ExpansionTileList(
            labelName: 'Leads',
            lists: DSA,
            icon: Icon(
              Icons.emoji_people,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Opportunities',
            lists: opportunityDSA,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Monitoring',
            lists: monitoringDSA,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Market Intellignce',
            lists: mktintelDSA,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Toll/Transport Hub',
            lists: TollTransportHubDSA,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        break;
      }
    }

    for (final element in roles) {
      if ((element as String) == 'SFM') {
        ExpansionTileList temp3 = ExpansionTileList(
            labelName: 'Leads',
            lists: SFM,
            icon: Icon(
              Icons.escalator_warning,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Opportunities',
            lists: opportunitySFM,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Monitoring',
            lists: monitoringSFM,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Market Intellignce',
            lists: mktintelSFM,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Toll/Transport Hub',
            lists: TollTransportHubSFM,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        break;
      }
    }

    for (final element in roles) {
      if ((element as String) == 'SRH') {
        ExpansionTileList temp3 = ExpansionTileList(
            labelName: 'Leads',
            lists: SRH,
            icon: Icon(
              Icons.escalator_warning,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Opportunities',
            lists: opportunitySRH,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Monitoring',
            lists: monitoringSRH,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Market Intellignce',
            lists: mktintelSRH,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        temp3 = ExpansionTileList(
            labelName: 'Toll/Transport Hub',
            lists: TollTransportHubSRH,
            icon: Icon(
              Icons.group,
              color: Colors.orange,
              size: 30,
            ));
        expansionTile.add(temp3);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF0F2).withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(
                            1.0 - (widget.iconAnimationController.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(
                                      begin: 0.0, end: 24.0)
                                  .animate(CurvedAnimation(
                                      parent: widget.iconAnimationController,
                                      curve: Curves.fastOutSlowIn))
                                  .value /
                              360),
                          child: Center(
                            child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.6),
                                        offset: const Offset(2.0, 4.0),
                                        blurRadius: 8),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(300.0),
                                  child:
                                      Image.asset('assets/images/splash.jpg'),
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FutureBuilder(
                            future: storage.read(key: 'name'),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: expansionTile.length,
              itemBuilder: (BuildContext context, int index) {
                return multilevel(expansionTile[index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF253840),
                  ),
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                onTap: () {
                  onTapped();
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ],
      ),
    );
  }

  void onTapped() async {
    await storage.delete(key: 'jwt');
    await storage.delete(key: 'name');

    await http.post(Uri.parse(BASE_URI + '/signOut'),
        headers: {
          "Accept": "application/json",
          "Authorization": jwt,
          'Content-type': 'application/json'
        },
        body: jsonEncode({}));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => UserVerificationPage()),
      (_) => false,
    );
  }

  Widget multilevel(ExpansionTileList listData) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0.0),
        leading: listData.icon,
        title: Text(
          listData.labelName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF253840),
            fontSize: 18,
          ),
          textAlign: TextAlign.left,
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(0.0),
            itemCount: listData.lists.length,
            itemBuilder: (BuildContext context, int index) {
              return inkwell(listData.lists[index]);
            },
          )
        ],
      ),
    );
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          if (listData.index != DrawerIndex.DIVIDER) {
            navigationtoScreen(listData.index);
          }
        },
        child: listData.index == DrawerIndex.DIVIDER
            ? Divider(
                height: 20,
              )
            : Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 6.0,
                          height: 46.0,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                        ),
                        listData.isAssetsImage
                            ? Container(
                                width: 24,
                                height: 24,
                                child: Image.asset(listData.imageName,
                                    color: widget.screenIndex == listData.index
                                        ? Colors.blue
                                        : Colors.black87),
                              )
                            : Icon(listData.icon.icon,
                                color: widget.screenIndex == listData.index
                                    ? listData.icon.color
                                    : listData.icon.color),
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                        ),
                        Expanded(
                          child: Text(
                            listData.labelName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: widget.screenIndex == listData.index
                                  ? Colors.black87
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.screenIndex == listData.index
                      ? AnimatedBuilder(
                          animation: widget.iconAnimationController,
                          builder: (BuildContext context, Widget child) {
                            return Transform(
                              transform: Matrix4.translationValues(
                                  (MediaQuery.of(context).size.width * 0.75 -
                                          64) *
                                      (1.0 -
                                          widget.iconAnimationController.value -
                                          1.0),
                                  0.0,
                                  0.0),
                              child: Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75 -
                                          64,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: new BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(28),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(28),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox()
                ],
              ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}

enum DrawerIndex {
  AboutUs,
  CreateLead,
  FindLead,
  FindOpportunity,
  FindOpportunityOth,
  OpenActivities,
  ChangeLeadOwner,
  Escalations,
  MarketIntelligence,
  MarketIntelligenceRecords,
  CaptureNewHub,
  FindHub,
  CaptureCampaign,
  CampaignDetails,
  DSAMonitoring,
  CustomerVisits,
  CustomerVisitsDetails,
  CaptureHealthCamps,
  HealthCampsDetails,
  RetailOutlet,
  IssueCoupon,
  IssueCouponBulk,
  RedeemCoupon,
  CustomerVisitsV1,
  ComplaintCreation,
  ComplaintClosure,
  EFMSVendorPendingComplaint,
  EFMSIOCPendingMaintenanceComplaints,
  EFMSIOCPendingProposals,
  CustomerMeetMajor,
  CustomerMeetMini,
  CustomerMeetRecords,
  CustomerVisitsV2,
  DailyActivityTracker,
  CreateLeadV2,
  Summary,
  DIVIDER,
  FeedbackSurvey,
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex index;
}

class ExpansionTileList {
  ExpansionTileList({
    this.labelName = '',
    this.lists,
    this.icon,
  });

  String labelName;
  List<DrawerList> lists;
  Icon icon;
}
