import 'package:remove_emoji/remove_emoji.dart';

class Validators {
  // static final RegExp numberRegExp = RegExp(r'\d');
  static final RegExp numberRegExp = RegExp(r'^[0-9]*$');
  static final removeEmoji = RemoveEmoji();
  static String validateUsername(String value) {
    value = removeEmoji.removemoji(value);
    String msg;
    if (value.isEmpty) {
      msg = 'Username can\'t be empty';
    } else if (!numberRegExp.hasMatch(value) || value.length > 10) {
      msg = 'Not Valid';
    } else {
      msg = null;
    }
    return msg;
  }

  static String validatePassword(String value) {
    value = removeEmoji.removemoji(value);
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }

  static String validateNumbers(String value) {
    value = removeEmoji.removemoji(value);
    if (value == '') return null;
    String msg;
    if (!numberRegExp.hasMatch(value)) {
      msg = 'Not a Valid Number';
    } else {
      msg = null;
    }
    return msg;
  }

  static String validateDeviceDropDown(String value) {
    return value == 'Select' ? 'Select Device Type' : null;
  }
}
