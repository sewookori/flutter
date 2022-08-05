import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dart:math';
import 'package:vibration/vibration.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class ContactInfo {
  String name;
  String phone;
  String email;
  bool isFakeArtest;

  ContactInfo(
      {required this.name,
      required this.phone,
      required this.email,
      this.isFakeArtest = false});
}

class ContactListItem extends ListTile {
  ContactListItem(ContactInfo contact, {Key? key})
      : super(
            key: key,
            leading: const Icon(Icons.person),
            title: Text(contact.name),
            subtitle: Text(contact.phone),
            trailing: Text(contact.email));
}

class MyAppState extends State<MyApp> {
  List<ContactInfo>? _contacts = [];
  List<ContactInfo>? _selectedContacts = [];
  bool _isContactPermissionDenied = true;
  bool _isSmsPermissionGranted = false;
  final _myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _setSmsPermissionFlag();
  }

  Future _setSmsPermissionFlag() async {
    if (!await _checkSmsPermissionGranted()) {
      setState(() => _isSmsPermissionGranted = false);
    } else {
      setState(() => _isSmsPermissionGranted = true);
    }
  }

  _getSmsPermission() async => await [
        Permission.sms,
      ].request();

  Future<bool> _checkSmsPermissionGranted() async =>
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

  _sendSMS(List<ContactInfo> selectedContactList) async {
    for (var selectedContact in selectedContactList) {
      if (selectedContact.phone != 'None') {
        if ((await _supportCustomSim)!) {
          if (selectedContact.isFakeArtest == true) {
            print(
                'send message : ${selectedContact.name}, (fake artist), ${selectedContact.phone}, hint: ${_myController.text}');
            // _sendMessage(selectedContact.phone, '당신은 가짜 예술가 입니다.', simSlot: 1);
          } else {
            print(
                'send message : ${selectedContact.name}, (true artist), ${selectedContact.phone}, hint: ${_myController.text}');
            // _sendMessage(
            //     selectedContact.phone, '이번 주제는 ${_myController.text} 입니다',
            //     simSlot: 1);
          }
        } else {
          if (selectedContact.isFakeArtest == true) {
            print(
                'send message : ${selectedContact.name}, (fake artist), ${selectedContact.phone}, hint: ${_myController.text}');
            // _sendMessage(selectedContact.phone, '당신은 가짜 예술가 입니다.');
          } else {
            print(
                'send message : ${selectedContact.name}, (true artist), ${selectedContact.phone}, hint: ${_myController.text}');
            // _sendMessage(
            //     selectedContact.phone, '이번 주제는 ${_myController.text} 입니다');
          }
        }
      } else {
        print(
            'No mobile phone number! Can\'t send SMS to ${selectedContact.name}!');
      }
    }
  }

  Future<bool?> get _supportCustomSim async =>
      await BackgroundSms.isSupportCustomSim;

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _isContactPermissionDenied = true);
    } else {
      List<ContactInfo>? mobileContactList = [];
      var contacts = await FlutterContacts.getContacts();
      if (contacts.isNotEmpty) {
        for (var element in contacts) {
          var fullContact = await FlutterContacts.getContact(element.id);

          var mobileIndex = fullContact!.phones
              .indexWhere((element) => element.label == PhoneLabel.mobile);

          var contactInfo = ContactInfo(
              name: fullContact.displayName,
              phone: (mobileIndex != -1)
                  ? fullContact.phones[mobileIndex].number
                  : 'None',
              email: (fullContact.emails.isNotEmpty)
                  ? fullContact.emails[0].address
                  : 'None',
              isFakeArtest: false);
          if (contactInfo.phone != 'None') {
            mobileContactList.add(contactInfo);
          }
        }

        setState(() {
          _isContactPermissionDenied = false;
          _contacts = mobileContactList;
        });
      } else {
        print('No Contacts found !');
      }
    }
  }

  void _setFakeArtist() {
    var fakeIndex = Random().nextInt(_selectedContacts!.length);
    setState(() {
      for (int i = 0; i < _selectedContacts!.length; i++) {
        if (i == fakeIndex) {
          _selectedContacts![i].isFakeArtest = true;
        } else {
          _selectedContacts![i].isFakeArtest = false;
        }
      }
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Close',
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
        home: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.fitWidth,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8), BlendMode.dstATop),
              image: const AssetImage('images/fake_artest_title.jpg'),
            )),
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text(
                    'Fake artist selector',
                    style: TextStyle(
                      color: Colors.pink[700],
                    ),
                  ),
                  backgroundColor: Colors.yellow[700],
                ),
                body: Builder(builder: (BuildContext ctx) {
                  final items = _contacts!
                      .map((contact) =>
                          MultiSelectItem<ContactInfo>(contact, contact.name))
                      .toList();
                  if (_isContactPermissionDenied) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                      Center(child: CircularProgressIndicator(color: Colors.yellow,)),
                      // CircularProgressIndicator(),
                      Padding(padding: EdgeInsets.only(top:120)),
                      Text('전화번호부 목록 조회중...', style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),)
                      ]);
                  }
                  if (_contacts == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(children: [
                    Expanded(
                        child: SingleChildScrollView(
                            child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Column(children: <Widget>[
                        MultiSelectDialogField(
                            items: items,
                            title: const Text("플레이어 선택"),
                            selectedColor: Colors.blue,
                            searchable: true,
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                color: Colors.yellow,
                                width: 2,
                              ),
                            ),
                            buttonIcon: const Icon(
                              Icons.people_alt_rounded,
                              color: Colors.yellow,
                            ),
                            buttonText: Text(
                              "전화번호부로 플레이어 선택",
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontSize: 16,
                              ),
                            ),
                            onConfirm: (values) async {
                              setState(() {
                                _selectedContacts = values.cast<ContactInfo>();
                              });
                            },
                            chipDisplay: MultiSelectChipDisplay(
                                chipColor: Colors.yellow,
                                textStyle: const TextStyle(color: Colors.black),
                                onTap: (item) {
                                  setState(() {
                                    _selectedContacts?.remove(item);
                                  });
                                })),
                      ]),
                    ))),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: Row(children: <Widget>[
                        SizedBox(
                            width: 290.0,
                            child: TextField(
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                              ),
                              onChanged: (text) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                labelText: '주제어',
                                labelStyle: TextStyle(
                                  color: Colors.yellow.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                fillColor: Colors.yellow.withOpacity(0.1),
                                filled: true,
                                suffixIcon: _myController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _myController.clear();
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.cancel,
                                            color:
                                                Colors.yellow.withOpacity(0.5)))
                                    : null,
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 5.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.yellow, width: 5.0),
                                ),
                                hintText: '주제 힌트 입력',
                                hintStyle: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              controller: _myController,
                            )),
                        Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(40, 60),
                                enableFeedback: true,
                                textStyle: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 20,
                                ),
                                side: const BorderSide(
                                    width: 5.0, color: Colors.yellow),
                              ),
                              child: const Text("SEND!",
                                  style: TextStyle(color: Colors.yellow)),
                              onPressed: () async {
                                Vibration.vibrate(
                                    pattern: [150], intensities: [20]);
                                if (_selectedContacts!.isNotEmpty &&
                                    _myController.text.isNotEmpty) {
                                  _setFakeArtist();
                                  _finalConfirm(ctx);
                                } else if (_selectedContacts!.isEmpty) {
                                  _showSnackBar(ctx, '선택된 플레이어가 없습니다 !');
                                } else {
                                  _showSnackBar(ctx, '선택된 주제어가 없습니다 !');
                                }
                              },
                            ))
                      ]),
                    ),
                  ]);
                }))));
  }

  void _finalConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('최종 확인'),
          content: const Text('정말 보내시겠습니까 ?'),
          actions: <Widget>[
            ElevatedButton(
                child: const Text('예'),
                onPressed: () {
                  if (_isSmsPermissionGranted) {
                    _sendSMS(_selectedContacts!);
                    _showSnackBar(context, '전송 완료 !');
                  } else {
                    _getSmsPermission();
                  }
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
              child: const Text('아니오'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
