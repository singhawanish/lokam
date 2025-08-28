import 'dart:convert';

import 'loginPage.dart';
import 'package:crypton/crypton.dart';
import 'package:flutter/material.dart';
import '../data_providers/auth_data_provider.dart';
import '../data_providers/auth_provider.dart';
import '../utils/networkUtil.dart';
import '../utils/validators.dart';

import '../main.dart';
import 'themes/custom_theme.dart';
import 'package:http/http.dart' as http;

class UserVerificationPage extends StatefulWidget {
  @override
  _UserVerificationPageState createState() => _UserVerificationPageState();
}

class _UserVerificationPageState extends State<UserVerificationPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _usernameFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameFieldController.text = '';
    _passwordFieldController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/wall.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Container(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width,
                    height: height * 0.45,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _usernameFieldController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      autocorrect: false,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: "",
                        hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                        hintText: 'User ID',
                        suffixIcon: Icon(Icons.email,
                            color: CustomTheme.buildLightTheme().primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: CustomTheme.buildLightTheme().primaryColor,
                            width: 3.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: CustomTheme.buildLightTheme().primaryColor,
                          ),
                        ),
                      ),
                      validator: Validators.validateUsername,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary:
                                CustomTheme.buildLightTheme().primaryColor),
                        child: Text('Login'),
                        onPressed: _onSubmitLoginButton,
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
    );
  }

  bool _isFormValidated() {
    final FormState form = formKey.currentState;
    return form.validate();
  }

  _onSubmitLoginButton() async {
    if (_isFormValidated()) {
      ScaffoldMessenger.of(context).showSnackBar(_loadingSnackBar());
      final BaseAuth auth = AuthProvider.of(context).auth;
      final String username = _usernameFieldController.text;
      final String password = _passwordFieldController.text;

      var internet = await checkInternet();
      if (!internet) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('No Internet Connectivity.'),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        Map<String, dynamic> loggedIn = Map<String, dynamic>();

        final rsa = await http.post(
          Uri.parse(BASE_URI + '/getRSAKey'),
        );
        if (rsa.statusCode == 200) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(
                            username: username,
                          )),
                );
          // String jsonkey = rsa.body; // By-passing for UAT
          // Map<String, dynamic> map = jsonDecode(jsonkey);
          // String key = map['key'];

          // String encryptedUsername =
          //     RSAPublicKey.fromString(key).encrypt(username);
          // String body = jsonEncode({"username": encryptedUsername});
          // var res = await http.post(
          //   Uri.parse(BASE_URI + '/userGetOTP'),
          //   body: body,
          //   headers: {'Content-type': 'application/json'},
          // );
          // if (res.statusCode == 200) {
          //   String auth = res.body;
          //   Map<String, dynamic> map = jsonDecode(auth);

          //   bool data = map['data'];
          //   bool status = map['status'];
          //   if (status == true) {
          //     if (data == true) {
          //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => LoginPage(
          //                   username: username,
          //                 )),
          //       );
          //     } else {
          //       String snackBarMsg = 'Login Not Feasible.';
          //       final snackBar = SnackBar(
          //         backgroundColor: Colors.red,
          //         content: Text(snackBarMsg),
          //       );
          //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
          //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //     }
          //   }
          // } else {
          //   String snackBarMsg = 'Server Not Reachable.';
          //   final snackBar = SnackBar(
          //     backgroundColor: Colors.red,
          //     content: Text(snackBarMsg),
          //   );
          //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // }
        } else {
          String snackBarMsg = 'Server Not Reachable.';
          final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text(snackBarMsg),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  Widget _loadingSnackBar() {
    return SnackBar(
      duration: const Duration(minutes: 5),
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(
            width: 20,
          ),
          Text(" Signing-In...")
        ],
      ),
    );
  }
}
