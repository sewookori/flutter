import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
  List<Contact>? _contacts = [];
  List<Contact>? _selectedContacts = [];
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

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

  _sendSMS(List<Contact>? selectedContacts) async {
    Contact? fullContact;
    String? phoneNumber;
    String? name;
    for (var selectedContact in selectedContacts!) {
      fullContact = await FlutterContacts.getContact(selectedContact.id);
      name = fullContact!.displayName;

      for (int i = 0; i < fullContact.phones.length; i++) {
        if (fullContact.phones[i].label == PhoneLabel.mobile) {
          //if (fullContact!.phones[i].isPrimary) {
          phoneNumber = fullContact.phones[i].number.toString();
          //print('send message : $phoneNumber');
        }
      }
      if (phoneNumber != null) {
        if ((await _supportCustomSim)!) {
          print('send message : $name, $phoneNumber');
          //_sendMessage(phoneNumber!, "Hello", simSlot: 1);
        } else {
          print('send message : $name, $phoneNumber');
          //_sendMessage(phoneNumber!, "Hello");
        }
      } else {
        print('No mobile phone number! Can\'t send SMS to $name!');
      }
    }
  }

  Future<bool?> get _supportCustomSim async =>
      await BackgroundSms.isSupportCustomSim;

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Fake artest selector'),
            ),
            body: Builder(builder: (BuildContext ctx) {
              final _items = _contacts!
                  .map((contact) =>
                      MultiSelectItem<Contact>(contact, contact.displayName))
                  .toList();
              if (_permissionDenied) {
                return const Center(child: Text('Permission denied'));
              }
              if (_contacts == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                  child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  const SizedBox(height: 40),
                  //##################################################################
                  // Rounded blue MultiSelectDialogField
                  //##################################################################
                  MultiSelectDialogField(
                    items: _items,
                    title: const Text("Selected Players"),
                    selectedColor: Colors.blue,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(40)),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    buttonIcon: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.blue,
                    ),
                    buttonText: Text(
                      "Selected Players",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (values) {
                      setState(() {
                        _selectedContacts = values as List<Contact>;
                      });
                    },
                  ),
                  FloatingActionButton(
                      child: const Icon(Icons.send),
                      onPressed: () async {
                        if (await _isPermissionGranted()) {
                          _sendSMS(_selectedContacts);
                          _showSnackBar(ctx, 'Notified !');
                        } else {
                          _getPermission();
                        }
                      })
                ]),
              ));
            })));
  }
}
