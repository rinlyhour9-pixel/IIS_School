import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityPlusManager {
  ConnectivityPlusManager._();

  static final ConnectivityPlusManager _instance = ConnectivityPlusManager._();
  static final ConnectivityPlusManager shared = _instance;



  Future<bool> get isConnected async {
    bool result = await InternetConnection().hasInternetAccess;
    return result;
  }


}
