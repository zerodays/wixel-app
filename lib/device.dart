import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Device {
  String ip;
  int size;
  List<dynamic> state;
  bool settingColor = false;
  Color settingColorInQueue;
  String name = 'Unknown';

  Device(String ip) {
    this.ip = ip;
  }

  String getDeviceUrl() {
    return 'http://$ip:6969/api/v1';
  }

  Future<void> getCurrentState() async {
    var response = await http.get('${getDeviceUrl()}/strip');
    state = jsonDecode(response.body);
    size = state.length;
  }

  Future<void> setColor(Color newColor) async {
    if (settingColor) {
      settingColorInQueue = newColor;
    } else {
      settingColorInQueue = null;
      await _sendCommand(newColor);
    }
  }

  Future<void> _sendCommand(Color newColor) async {
    settingColor = true;

    for (int i = 0; i < size; i++) {
      state[i] = [newColor.red, newColor.green, newColor.blue];
    }

    String data = jsonEncode(state);

    await http.post('${getDeviceUrl()}/strip',
        headers: {'content-type': 'application/json'}, body: data);

    settingColor = false;

    if (settingColorInQueue != null) {
      Color tmp = settingColorInQueue;
      settingColorInQueue = null;
      this._sendCommand(tmp);
    }
  }
  
  getName(Function callback) async {
    var response = await http.get('${getDeviceUrl()}/wix_enabled');
    name = jsonDecode(response.body)['device_name'];
    callback();
  }

  @override
  String toString() {
    return 'wixel device at $ip';
  }
}
