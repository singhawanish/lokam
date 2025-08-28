import 'package:flutter/material.dart';
import '../data_providers/auth_data_provider.dart';
import '../data_providers/auth_provider.dart';
import '../utils/networkUtil.dart';
import '../utils/validators.dart';

import 'menus/homeScreen.dart';
import 'themes/custom_theme.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

  LoginPage({
    Key key,
    this.username,
  }) : super(key: key);
  final String username;
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _usernameFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _usernameFieldController.text = widget.username;
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
                      enabled: false,
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
                        hintText: 'User ID ',
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _passwordFieldController,
                      autocorrect: false,
                      obscureText: _obscureText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                        hintText: 'Password/OTP',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: CustomTheme.buildLightTheme().primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
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
                      validator: Validators.validatePassword,
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
        Map<String, dynamic> loggedIn =
            await auth.signInWithUsernameAndPassword(
          username,
          password,
        );
        if (loggedIn['status'] == true && loggedIn['msg'] == 'OK') {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
            (_) => false,
          );
        } else {
          String snackBarMsg = '';
          switch (loggedIn['msg']) {
            case 'NOT_REACHABLE':
              snackBarMsg = 'Server Not Reachable.';
              break;
            case 'AUTHENTICATION_FAILED':
              snackBarMsg = 'Your username / password is incorrect';
              break;
          }
          if (snackBarMsg != '') {
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
