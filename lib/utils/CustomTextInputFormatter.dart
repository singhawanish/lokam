import 'package:flutter/services.dart';

class CustomTextInputFormatter extends FilteringTextInputFormatter {
  final RegExp _invalidCharacters;

  CustomTextInputFormatter()
      : _invalidCharacters = RegExp(r'[~!@#\$%^&*_+`={}\[\]:\";<>?\\|]'),
        super.deny(RegExp(r'[~!@#\$%^&*_+`={}\[\]:\";<>?\\|]'));
}
