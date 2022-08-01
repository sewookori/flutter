import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contact_picker/contact_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final ContactPicker _contactPicker = ContactPicker();
  late Contact _contact;
  _getPermission() async => await [
        Permission.sms,
      ].request();

  Future<bool> _isPermissionGranted() async =>
      await Permission.sms.status.isGranted;

  _sendMessage(String phoneNumber, String message, {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (result == SmsStatus.sent) {
      print("Sent");
    } else {
      print("Failed");
    }
  }

  Future<bool?> get _supportCustomSim async =>
      await BackgroundSms.isSupportCustomSim;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Send Sms'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.send),
          onPressed: () async {
            Contact contact = await _contactPicker.selectContact();
            setState(() {
              _contact = contact;
            });
            if (await _isPermissionGranted()) {
              if ((await _supportCustomSim)!) {
                //_sendMessage("01092752159", "Hello", simSlot: 1);
                _sendMessage(_contact.phoneNumber.toString(), "Hello", simSlot: 1);
              } else {
                //_sendMessage("01092752159", "Hello");
                _sendMessage(_contact.phoneNumber.toString(), "Hello");
              }
            } else {
              _getPermission();
            }
          },
        ),
      ),
    );
  }
}