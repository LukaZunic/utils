import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({Key? key,
    required BluetoothDevice device,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress
  }) : super(key: key,
          onTap: onTap,
          onLongPress: onLongPress,
          leading: const Icon(Icons.devices),
          title: Text(device.name ?? ""),
          subtitle: Text(device.address.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              device.isBonded
                  ? Icon(Icons.link)
                  : Container(width: 0, height: 0),
            ],
          ),
        );
}
