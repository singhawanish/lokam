import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'views/splashScreen.dart';

import 'data_providers/auth_data_provider.dart';
import 'data_providers/auth_provider.dart';
import 'views/menus/homeScreen.dart';

// const BASE_URI = "https://spandan.indianoil.co.in/MobileApp/HMOFMOAppBE";
const BASE_URI = "https://parikshan.indianoil.co.in/MobileApp/HMOFMOAppBE";
// const BASE_URI =
//     "https://spandan.indianoil.co.in/MobileApp/IOCHardwareComplaintBE/HMOFMOAppBE";
final storage = FlutterSecureStorage();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String jwt = await storage.read(key: 'jwt');
  var isLoggedIn = (jwt == null) ? false : true;
  Widget page = isLoggedIn ? NavigationHomeScreen() : SpalshScreen();
  bool jailbroken;
  bool developerMode;
  try {
    jailbroken = await FlutterJailbreakDetection.jailbroken;
    developerMode = await FlutterJailbreakDetection.developerMode;
  } on PlatformException {
    jailbroken = true;
    developerMode = true;
  }
  // jailbroken = false;
  if (jailbroken) {
    runApp(
      JailBroken(),
    );
  } else {
    runApp(AuthProvider(
      auth: AuthDataProvider(),
      child: App(
        page: page,
      ),
    ));
  }
}

class App extends StatefulWidget {
  final Widget page;

  App({Key key, this.page}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  void initState() {
    super.initState();
    /**For Disabling Landscape Mode */

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "IOCL Customer Connect",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: widget.page,
    );
  }
}

class JailBroken extends StatefulWidget {
  const JailBroken({Key key}) : super(key: key);

  @override
  _JailBrokenState createState() => _JailBrokenState();
}

class _JailBrokenState extends State<JailBroken> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "IOCL Customer Connect",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("JailBroken"),
        ],
      )),
    );
  }
}
