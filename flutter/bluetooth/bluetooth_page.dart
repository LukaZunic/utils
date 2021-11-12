import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'discovery_page.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  _BluetoothPage createState() => _BluetoothPage();
}

class _BluetoothPage extends State<BluetoothPage> {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = '';
  String _name    = '';

  @override
  void initState() {
    super.initState();

    // Set the current Bluetooth state
    FlutterBluetoothSerial.instance.state.then((state) => {
      setState(() => {
        _bluetoothState = state
      })
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airlocker Bluetooth Connection Page'),
      ),
      body: Container(
        child: ListView(
            children: [
              const Divider(),
              SwitchListTile(
                title: const Text('Enable Bluetooth'),
                value: _bluetoothState.isEnabled,
                onChanged: (bool value) {
                  setState(() {
                    print(value);
                    future() async {
                        if(value){
                          print('here');
                          await FlutterBluetoothSerial.instance.requestEnable();
                        } else {
                          await FlutterBluetoothSerial.instance.requestDisable();
                        }
                    }
                  });
                },
              ),
              ListTile(
                title: const Text('Bluetooth Status'),
                subtitle: Text(_bluetoothState.stringValue),
                trailing: ElevatedButton(
                  child: const Text('Settings'),
                  onPressed: () {
                    FlutterBluetoothSerial.instance.openSettings();
                  },
                ),
              ),
              ListTile(
                title: const Text('Local adapter address'),
                subtitle: Text(_address),
              ),
              ListTile(
                title: const Text('Local adapter name'),
                subtitle: Text(_name),
                onLongPress: null,
              ),
              ListTile(
                title: ElevatedButton(
                    child: const Text('Explore discovered devices'),
                    onPressed: () async {
                      final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return DiscoveryPage();
                          },
                        ),
                      );
                      if (selectedDevice != null) {
                        print('Discovery -> selected ' + selectedDevice.address);
                      } else {
                        print('Discovery -> no device selected');
                      }
                    }),
              ),
            ],
        ),
      ),

    );

  }



}

