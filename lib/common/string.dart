import 'dart:convert';
import 'dart:typed_data';

extension StringExtension on String {
  bool get isUrl {
    return RegExp(r'^(http|https|ftp)://').hasMatch(this);
  }

  int compareToLower(String other) {
    return toLowerCase().compareTo(
      other.toLowerCase(),
    );
  }

  List<int> get encodeUtf16LeWithBom {
    final byteData = ByteData(length * 2);
    final bom = [0xFF, 0xFE];
    for (int i = 0; i < length; i++) {
      int charCode = codeUnitAt(i);
      byteData.setUint16(i * 2, charCode, Endian.little);
    }
    return bom + byteData.buffer.asUint8List();
  }

  bool get isBase64 {
    try {
      base64.decode(this);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get isRegex {
    try {
      RegExp(this);
      return true;
    } catch (_) {
      return false;
    }
  }
}
