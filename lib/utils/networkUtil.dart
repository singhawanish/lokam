import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

import '../main.dart';

Future<bool> checkInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

Future<Map<String, dynamic>> getDevices() async {
  Map<String, dynamic> authResponse = Map<String, dynamic>();
  var internet = await checkInternet();
  if (!internet) {
    authResponse['msg'] = 'NO_INTERNET';
    authResponse['status'] = false;
  } else {
    await storage.write(
        key: 'jwt',
        value:
            "IOC eyJhbGciOiJIUzUxMiJ9.eyJzZXNzaW9uRGF0YSI6eyJ1c2VybmFtZSI6IlplNzZlMjgxaEhDbzZWWWRnYW9lTFdVYnRKbUFlNS9YTWNPeDlHNThUd3ptQU1EdDVrdzBXTVhkMlRaaWE1WkFTaGNhSEUyUVNVNTVkMDk0VTZTclBKMDd4aEloaU0vSkxKenlLVjhQdUU3VUMySXVESjlFQTJaQlNWamVuL0F0dGpSZHFCTW1XNm5WVDVMZnZBdndIWGpJbEdZcE05eUpSbGRGM2RXUVpPV1ZsMHg3Vmlkc01kTkQ5Yk85c3NnQ1FEZU5QQlZDMVJGRzVsNThEOS9tbTZhdW1Pd25Za2Q1Q211Z21KQmxiYy93V0huTHZaSWJ6eVJVMXFrRnhybVl1SDlOeXhXT0RkYnpUb3d0VW5xNEE1TkNXcUNmY0xFaVpLWUdnRkRNdGgxSnM1RkZCaHZCTGdMR3kvRGhYVWJyaDMyVzNvc0ZYbFFuenV5bHY3UUpWZz09Iiwicm9sZSI6IlVTRVIifSwiZXhwIjoxNjE5MDc1NDcxLCJpYXQiOjE2MTg5ODkwNzEsImF1dGhvcml0aWVzIjpbIlVTRVIiXX0.LAq4jGesjJgzcFVgnBs_2FeOdsgsGbYkRyVxnLF-PA1a7w4GF-QgWrFyMsHWqg4KH5JEYdm2vXipvw1YqyKZGw");

    String jwt = await storage.read(key: 'jwt');
    final rsa = await http.get(
        Uri.parse(BASE_URI + '/HardwareComplaints/getDeviceType'),
        headers: {"Accept": "application/json", "Authorization": jwt});

    if (rsa.statusCode == 200) {
      String auth = rsa.body;
      Map<String, dynamic> map = jsonDecode(auth);
      List<String> data = new List<String>.from(map['data']);
      bool status = map['status'];
      if (status == true) {
        authResponse['msg'] = 'OK';
        authResponse['status'] = true;
        authResponse['data'] = data;
      } else {
        authResponse['msg'] = 'OK';
        authResponse['status'] = false;
      }
    } else {
      authResponse['msg'] = 'NOT_REACHABLE';
      authResponse['status'] = false;
    }
  }
  return authResponse;
}

void useHttpRead() async {
  var contents = await http.read(Uri.parse('http://localhost:8080/Complaints'));
  print(contents);
}

void useHttpGet(int programId) async {
  var response = await http.get(
    Uri.parse('http://localhost:8080/Complaints/$programId'),
  );
  print(response.body);
  print(response.statusCode);
}

void useHttpPost() async {
  var response = await http.post(
    Uri.parse('http://localhost:8080/Complaints'),
    body: UserProfile(23, '').toJson(),
    headers: {'Content-type': 'application/json'},
  );
  print(response.statusCode);
}

class UserProfile {
  int empCode;
  String name;

  UserProfile(this.empCode, this.name);

  String toJson() {
    Map<String, dynamic> userMap = {
      'empCode': this.empCode,
      'name': this.name,
    };
    var data = jsonEncode(userMap);
    return data;
  }

  factory UserProfile.fromJson(String json) {
    var userMap = jsonDecode(json);
    return UserProfile(
      userMap['empCode'] as int,
      userMap['name'] as String,
    );
  }

  void authenticate() {
    var credentials = 'username:password';
    var bytes = utf8.encode(credentials);
    var b64 = base64.encode(bytes);
    print(b64);
  }
}
