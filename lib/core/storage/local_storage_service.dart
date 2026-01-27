import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class LocalStorageService {
  Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(StorageKeys.postsBox);
    await Hive.openBox(StorageKeys.commentsBox);
    await Hive.openBox(StorageKeys.usersBox);
    await Hive.openBox(StorageKeys.syncQueueBox);
  }

  Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  Box get postsBox => getBox(StorageKeys.postsBox);
  Box get commentsBox => getBox(StorageKeys.commentsBox);
  Box get usersBox => getBox(StorageKeys.usersBox);
  Box get syncQueueBox => getBox(StorageKeys.syncQueueBox);

  Future<void> clearAll() async {
    await postsBox.clear();
    await commentsBox.clear();
    await usersBox.clear();
    await syncQueueBox.clear();
  }
}

