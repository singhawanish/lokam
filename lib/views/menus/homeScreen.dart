import 'package:geolocator/geolocator.dart';
import 'package:ioclcustomerconnect/views/menus/CaptureCampaignDetails.dart';
import 'package:ioclcustomerconnect/views/menus/CaptureNewHub.dart';
import 'package:ioclcustomerconnect/views/menus/ChangeLeadOwner.dart';
import 'package:ioclcustomerconnect/views/menus/ComplaintCreation.dart';
import 'package:ioclcustomerconnect/views/menus/FindCustomerVisits.dart';
import 'package:ioclcustomerconnect/views/menus/FindOpportunityOth.dart';
import 'package:ioclcustomerconnect/views/menus/OpenActivities.dart';

import 'CaptureHealthCampsDetails.dart';
import 'ComplaintClosure.dart';
import 'CreateLead.dart';
import 'package:flutter/material.dart';
import 'CreateLeadV2.dart';
import 'CustomerMeetMajor.dart';
import 'CustomerMeetMini.dart';
import 'CustomerMeetRecords.dart';
import 'CustomerVisits.dart';
import 'CustomerVisitsV1.dart';
import 'CustomerVisitsV2.dart';
import 'DSAMonitoring.dart';
import 'DailyActivityTracker.dart';
import 'EFMSIOCPendingMaintenanceComplaints.dart';
import 'EFMSIOCPendingProposals.dart';
import 'EFMSVendorPendingComplaint.dart';
import 'Escalations.dart';
import 'FeedbackSurvey.dart';
import 'FindCampaignDetails.dart';
import 'FindHealthCampDetails.dart';
import 'FindHub.dart';
import 'FindLead.dart';
import 'FindOpportunity.dart';
import 'LocateOurServiceOutlets.dart';
import 'MarketIntelligence.dart';
import 'MarketIntelligenceRecords.dart';
import 'RedeemCoupon.dart';
import 'Summary.dart';
import 'drawer_user_controller.dart';
import 'aboutUsPage.dart';
import 'home_drawer.dart';
import 'issueCoupon.dart';
import 'issueCouponBulk.dart';

class NavigationHomeScreen extends StatefulWidget {
  Widget screenView;
  DrawerIndex drawerIndex;
  NavigationHomeScreen({Key key, this.screenView, this.drawerIndex})
      : super(key: key);
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
  double lat;
  double long;
  bool grant = false;

  Future<void> _checkGPSAccess() async {
    bool servicestatus = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!servicestatus) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Enable Location Service'),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        grant = false;
      });
    } else {
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('Enable Permission'),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          grant = false;
        });
      } else {
        // while (permission != LocationPermission.always &&
        //     permission != LocationPermission.whileInUse) {
        //   permission = await Geolocator.requestPermission();
        // }
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        setState(() {
          lat = position.latitude;
          long = position.longitude;
          grant = true;
        });
      }
    }
  }

  @override
  void initState() {
    if (widget.screenView == null) {
      drawerIndex = DrawerIndex.AboutUs;
      screenView = AboutUsPage();
    } else {
      drawerIndex = widget.drawerIndex;
      screenView = widget.screenView;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white70,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
            },
            screenView: screenView,
          ),
        ),
      ),
    );
  }

  Future<void> changeIndex(DrawerIndex drawerIndexdata) async {
    if (drawerIndex != drawerIndexdata || drawerIndex == drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.AboutUs) {
        setState(() {
          screenView = AboutUsPage();
        });
      } else if (drawerIndex == DrawerIndex.CreateLead) {
        setState(() {
          screenView = CreateLeadPage();
        });
      } else if (drawerIndex == DrawerIndex.FindLead) {
        setState(() {
          screenView = FindLeadPage();
        });
      } else if (drawerIndex == DrawerIndex.FindOpportunity) {
        setState(() {
          screenView = FindOpportunityPage();
        });
      } else if (drawerIndex == DrawerIndex.FindOpportunityOth) {
        setState(() {
          screenView = FindOpportunityOthPage();
        });
      } else if (drawerIndex == DrawerIndex.OpenActivities) {
        setState(() {
          screenView = OpenActivitiesPage();
        });
      } else if (drawerIndex == DrawerIndex.ChangeLeadOwner) {
        setState(() {
          screenView = ChangeLeadOwnerPage();
        });
      } else if (drawerIndex == DrawerIndex.Escalations) {
        setState(() {
          screenView = EscalationsPage();
        });
      } else if (drawerIndex == DrawerIndex.MarketIntelligence) {
        setState(() {
          screenView = MarketIntelligencePage();
        });
      } else if (drawerIndex == DrawerIndex.MarketIntelligenceRecords) {
        setState(() {
          screenView = MarketIntelligenceRecordsPage();
        });
      } else if (drawerIndex == DrawerIndex.CaptureNewHub) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = CaptureNewHubPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.FindHub) {
        setState(() {
          screenView = FindHubPage();
        });
      } else if (drawerIndex == DrawerIndex.CaptureCampaign) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView =
                CaptureCampaignDetailsPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.CaptureHealthCamps) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView =
                CaptureHealthCampsDetailsPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.CampaignDetails) {
        setState(() {
          screenView = FindCampaignDetailsPage();
        });
      } else if (drawerIndex == DrawerIndex.HealthCampsDetails) {
        setState(() {
          screenView = FindHealthCampDetailsPage();
        });
      } else if (drawerIndex == DrawerIndex.DSAMonitoring) {
        setState(() {
          screenView = DSAMonitoringPage();
        });
      } else if (drawerIndex == DrawerIndex.CustomerVisits) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = CustomerVisitsPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.CustomerVisitsDetails) {
        setState(() {
          screenView = FindCustomerVisitsPage();
        });
      } else if (drawerIndex == DrawerIndex.RetailOutlet) {
        setState(() {
          screenView = LocateOurServiceOutletPage();
        });
      } else if (drawerIndex == DrawerIndex.Summary) {
        setState(() {
          screenView = SummaryPage();
        });
      } else if (drawerIndex == DrawerIndex.IssueCoupon) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = IssueCouponPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.RedeemCoupon) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = RedeemCouponPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.IssueCouponBulk) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = IssueCouponBulkPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.CustomerVisitsV1) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = CustomerVisitsV1Page(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.ComplaintCreation) {
        setState(() {
          screenView = ComplaintCreationPage();
        });
      } else if (drawerIndex == DrawerIndex.ComplaintClosure) {
        setState(() {
          screenView = ComplaintClosurePage();
        });
      } else if (drawerIndex == DrawerIndex.EFMSVendorPendingComplaint) {
        setState(() {
          screenView = EFMSVendorPendingComplaintPage();
        });
      } else if (drawerIndex ==
          DrawerIndex.EFMSIOCPendingMaintenanceComplaints) {
        setState(() {
          screenView = EFMSIOCPendingMaintenanceComplaintPage();
        });
      } else if (drawerIndex == DrawerIndex.EFMSIOCPendingProposals) {
        setState(() {
          screenView = EFMSIOCPendingProposalsPage();
        });
      } else if (drawerIndex == DrawerIndex.CustomerMeetMajor) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView =
                CutomerMeetMajorDetailsPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.CustomerMeetMini) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView =
                CutomerMeetMiniDetailsPage(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.CustomerMeetRecords) {
        setState(() {
          screenView = CustomerMeetRecordsPage();
        });
      } else if (drawerIndex == DrawerIndex.CustomerVisitsV2) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = CustomerVisitsV2Page(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.DailyActivityTracker) {
        setState(() {
          screenView = DailyActivityTrackerPage();
        });
      } else if (drawerIndex == DrawerIndex.CreateLeadV2) {
        await _checkGPSAccess();
        if (grant) {
          setState(() {
            screenView = CreateLeadV2Page(lat: this.lat, long: this.long);
          });
        }
      } else if (drawerIndex == DrawerIndex.FeedbackSurvey) {
        setState(() {
          screenView = FeedbackSurveyPage();
        });
      }
    }
  }
}
