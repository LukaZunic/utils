import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiService {

  /// Scans and returns available wifi networks
  ///
  /// Optional argument [substring] filters out networks where the ssid
  /// doesn't contain the given String
  static Future<List<WifiNetwork>> scanWifi([String? substring]) async {
    List<WifiNetwork> wifiList;
    wifiList = await WiFiForIoTPlugin.loadWifiList();

    if(substring != null){
      List<WifiNetwork> wifiFiltered = wifiList.where((network) =>
          network.ssid!.contains(substring)).toList();
      return wifiFiltered;
    } else {
      return wifiList;
    }
  }


  /// Returns the Gateway IP of the current wifi network connection
  static Future<String?> getGatewayIP() async {
    String? wifiGatewayIP;
    final NetworkInfo _networkInfo = NetworkInfo();

    try {
      wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    return wifiGatewayIP;
  }

  /// Returns the name of the Wi-Fi network the device is currently connected to
  static Future<String?> getCurrentConnection() async {
    String? SSID;
    final NetworkInfo _networkInfo = NetworkInfo();

    try {
      SSID = await _networkInfo.getWifiName();
    } on PlatformException catch (e) {
      SSID = 'Failed to get Wifi SSID';
    }

    return SSID;
  }


  /// Sends a post request containing [ssid] and [pass] to local server
  /// Functions accepts additional parameter [IP] which represents the
  /// gateway IP and uses it to establish a connection to the server
  ///
  /// IP:3000/connect receives data and tries to connect to a
  /// wifi network using the given parameters
  static Future<http.Response> sendWifiData(String ssid, String pass, String? IP) {
    return http.post(
      Uri.parse('http://$IP:3000/connect'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ssid': ssid,
        'pass': pass
      }),
    );
  }


  /// Connects to wifi network using [ssid] and [pass]
  ///
  /// Returns true or false depending on if the connection was successful
  static Future<bool> connect(String ssid, [String pass = '123456789']) async {
    return WiFiForIoTPlugin.findAndConnect(
        ssid,
        password: pass,
    );
  }


}