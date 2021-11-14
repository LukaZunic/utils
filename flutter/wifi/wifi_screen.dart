import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/services/wifi_service.dart';
import 'package:wifi_iot/wifi_iot.dart';


class Wifi extends StatefulWidget {
  const Wifi({Key? key}) : super(key: key);

  @override
  _WifiState createState() => _WifiState();
}

class _WifiState extends State<Wifi> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final networkController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    networkController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: networkController,
                        decoration: const InputDecoration(
                            hintText: 'Enter wifi network'
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wifi network';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                            hintText: 'Enter wifi password'
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wifi password';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              WifiService.getGatewayIP().then((value) {
                                WifiService.sendWifiData(networkController.text,
                                    passwordController.text, value);
                                }
                              );
                            }
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('Sending data: ' + networkController.text + ' ' + passwordController.text),
                                );
                              },
                            );
                          },
                          child: const Text('Submit')
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    elevation: 2,
                    child: _buildWifiList()
                ),
              )
            ],
          )
        ),
      ),
    );
  }


  Widget _buildWifiList() {
    return FutureBuilder(
        future: WifiService.scanWifi('AirLocker'),
        builder: (BuildContext context, AsyncSnapshot<List<WifiNetwork>> snap){
          List<WifiNetwork> wifiList = snap.data!;
          return ListView.builder(itemCount: wifiList.length, shrinkWrap: true,
              itemBuilder: (BuildContext context, int i){
            return _buildWifiTile(wifiList[i]);
          });
        }
    );
  }


  Widget _buildWifiTile(WifiNetwork network) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
          title: Text(network.ssid.toString()),
          leading: Container(
            padding: const EdgeInsets.only(right: 12.0),
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(width: 1.0, color: Colors.black12))),
            child: const Icon(Icons.tap_and_play, color: Colors.black),
          ),
          onTap: () => WifiService.connect(network.ssid.toString())
      ),
    );
  }

}