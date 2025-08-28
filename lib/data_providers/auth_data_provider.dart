import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypton/crypton.dart';

import '../main.dart';

abstract class BaseAuth {
  Future<Map<String, dynamic>> signInWithUsernameAndPassword(
      String username, String password);
  Future<bool> signOut();
}

class AuthDataProvider implements BaseAuth {
  @override
  Future<Map<String, dynamic>> signInWithUsernameAndPassword(
    String username,
    String password,
  ) async {
    Map<String, dynamic> authResponse = Map<String, dynamic>();

    final rsa = await http.post(
      Uri.parse(BASE_URI + '/getRSAKey'),
    );
    if (rsa.statusCode == 200) {
      String jsonkey = rsa.body;
      Map<String, dynamic> map = jsonDecode(jsonkey);
      String key = map['key'];

      String encryptedUsername = RSAPublicKey.fromString(key).encrypt(username);
      String encryptedPassword = RSAPublicKey.fromString(key).encrypt(password);
      String body = jsonEncode(
          {"username": encryptedUsername, "password": encryptedPassword});
      var res = await http.post(
        Uri.parse(BASE_URI + '/user'),
        body: body,
        headers: {'Content-type': 'application/json'},
      );
      if (res.statusCode == 200) {
        String auth = res.body;
        Map<String, dynamic> map = jsonDecode(auth);

        String msg = map['msg'];
        bool status = map['status'];
        if (status == true && msg == '001') {
          String jwt = map['token'];
          Map<String, dynamic> profile = map['profile'];
          await storage.write(key: 'jwt', value: jwt);
          await storage.write(key: 'name', value: profile['name'] as String);
          authResponse['msg'] = 'OK';
          authResponse['status'] = true;
        } else if (status == true && msg == '900') {
          authResponse['msg'] = 'AUTHENTICATION_FAILED';
          authResponse['status'] = false;
        }
      } else {
        authResponse['msg'] = 'NOT_REACHABLE';
        authResponse['status'] = false;
      }
    } else {
      authResponse['msg'] = 'NOT_REACHABLE';
      authResponse['status'] = false;
    }

    return authResponse;
  }

  @override
  Future<bool> signOut() async {
    final res = await http.get(Uri.parse('API_ENDPOINT'));

    return res.statusCode == 200;
  }
}
