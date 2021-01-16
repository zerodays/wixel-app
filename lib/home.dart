import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'device.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Device> devices = [];
  bool loading = true;
  Color currentColor = Color(0xff443a49);

  checkDeviceWixlable(NetworkAddress address) async {
    print(address.ip);
    if (!address.exists) return;
    print('found ip ${address.ip}');

    try {
      Device newDevice = new Device(address.ip);
      await newDevice.getCurrentState();
      newDevice.getName(() => this.setState(() {}));

      setState(() {
        devices.add(newDevice);
      });
    } catch (_) {}
  }

  void loadFinished() {
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    const port = 6969;
    final stream = NetworkAnalyzer.discover2(
      '192.168.1',
      port,
      timeout: Duration(milliseconds: 10000),
    );
    stream.listen(checkDeviceWixlable).onDone(this.loadFinished);

    super.initState();
  }

  Widget getDeviceWidget(Device device) {
    return Card(
      child: ListTile(
        title: Text(device.name),
        subtitle: Text(device.ip),
      ),
    );
  }

  void onColorChanged(Color newColor) {
    setState(() {
      currentColor = newColor;
    });

    for (Device d in devices) {
      d.setColor(newColor);
    }
  }

  Widget getColorPicker() {
    return ColorPicker(
      pickerColor: currentColor,
      onColorChanged: onColorChanged,
      showLabel: true,
      pickerAreaHeightPercent: 0.8,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Center(
          child: Text(
            'Wixel',
            textAlign: TextAlign.center,
          ),
        )),
        body: Column(
          children: [
            loading
                ? LinearProgressIndicator(
                    minHeight: 4,
                  )
                : Container(
                    height: 4,
                  ),
            Container(
              height: 16,
            ),
            ...devices.map(getDeviceWidget),
            Container(
              height: 32,
            ),
            getColorPicker(),
          ],
        ));
  }
}
