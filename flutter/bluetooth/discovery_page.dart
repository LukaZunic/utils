import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './bluetooth_device_list_entry.dart';


class DiscoveryPage extends StatefulWidget {

  final bool start; // Start discovering immediately
  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {

  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>.empty(growable: true);

  bool isDiscovering = false;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();
    isDiscovering = widget.start;
    if(isDiscovering) _startDiscovery();
  }
  
  void _startDiscovery() {

    print('Discovering Devices');

    _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((disc) {
      setState(() {
        final existingIndex = results.indexWhere((element) => element.device.address == disc.device.address);
        if(existingIndex >= 0){
          results[existingIndex] = disc;
        } else {
          results.add(disc);
        }
      });
    });

    _streamSubscription!.onDone(() {

      print('Discovery over');

      setState(() => {
        isDiscovering = false
      });
    });
  }

  void _restartDiscovery() {
    results.clear();
    _startDiscovery();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering
            ? const Text('Discovering devices')
            : const Text('Discovered devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: _restartDiscovery,
          )
        ]
      ),
      body: ListView.builder(
          itemCount: results.length,
          itemBuilder: (BuildContext context, i) {
            BluetoothDiscoveryResult result = results[i];
            final device = result.device;
            final address = device.address;
            return BluetoothDeviceListEntry(
                device: device,
                onLongPress: () async{
                  try {
                    bool bonded = false;
                    if(device.isBonded){
                      await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(address);
                    } else {
                      bonded = (await FlutterBluetoothSerial.instance.bondDeviceAtAddress(address))!;
                    }
                    setState(() {
                      results[results.indexOf(result)] = BluetoothDiscoveryResult(
                          device: BluetoothDevice(
                            name: device.name ?? '',
                            address: address,
                            type: device.type,
                            bondState: bonded
                                ? BluetoothBondState.bonded
                                : BluetoothBondState.none,
                          ),
                          rssi: result.rssi);
                    });
                  } catch (err) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error occurred while bonding'),
                          content: Text(err.toString()),
                        );
                      },
                    );
                  }
                },
            );
          }
      ),
    );
  }
  

}