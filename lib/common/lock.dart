import 'dart:io';

import 'package:fl_clash/common/common.dart';

class SingleInstanceLock {
  static SingleInstanceLock? _instance;
  RandomAccessFile? _accessFile;

  SingleInstanceLock._internal();

  factory SingleInstanceLock() {
    _instance ??= SingleInstanceLock._internal();
    return _instance!;
  }

  Future<bool> acquire() async {
    final lockFilePath = await appPath.getLockFilePath();
    final lockFile = File(lockFilePath);
    await lockFile.create();
    try {
      _accessFile = await lockFile.open(mode: FileMode.write);
      _accessFile?.lock();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final singleInstanceLock = SingleInstanceLock();
