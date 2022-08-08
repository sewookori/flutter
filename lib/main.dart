import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dart:math';
import 'package:vibration/vibration.dart';
import 'contacts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'generated/locale_keys.g.dart';

final supportedLocales = [
  const Locale('en', 'US'),
  const Locale('ko', 'KR'),
  const Locale('ja', 'JP')
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  //runApp(const MyApp());
  runApp(
  EasyLocalization(
      // 지원 언어 리스트
      supportedLocales: supportedLocales,
      //path: 언어 파일 경로
      path: 'assets/translations',
      //fallbackLocale supportedLocales에 설정한 언어가 없는 경우 설정되는 언어
      fallbackLocale: const Locale('en', 'US'),

      //startLocale을 지정하면 초기 언어가 설정한 언어로 변경됨
      //만일 이 설정을 하지 않으면 OS 언어를 따라 기본 언어가 설정됨
      //startLocale: Locale('ko', 'KR')

      child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<ContactInfo>? _contacts = [];
  List<ContactInfo>? _selectedContacts = [];
  bool _isContactPermissionAllowed = false;
  bool _isSmsPermissionGranted = false;
  final _myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkContactsReady();
  }

  Future<void> _checkContactsReady() async {
    List<ContactInfo> contactInfoList = [];
    var fetchContactsResult = await fetchContacts(contactInfoList);
    var checkSmsPermissionResult = await checkSmsPermissionGranted();
    setState(() {
      _isContactPermissionAllowed = fetchContactsResult;
      _contacts = contactInfoList;
      _isSmsPermissionGranted = checkSmsPermissionResult;
    });
  }

  void setContactInfo(List<ContactInfo> contacts) {
    _contacts = contacts;
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
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.fitWidth,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8), BlendMode.dstATop),
              image: const AssetImage('assets/fake_artest_title.jpg'),
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
                  //context.setLocale(const Locale('ja', 'JP'));
                  //context.resetLocale();
                  final items = _contacts!
                      .map((contact) =>
                          MultiSelectItem<ContactInfo>(contact, contact.name))
                      .toList();
                  if (!_isContactPermissionAllowed) {
                    return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Center(
                              child: CircularProgressIndicator(
                            color: Colors.yellow,
                          )),
                          const Padding(padding: EdgeInsets.only(top: 120)),
                          Text(
                            LocaleKeys.searchingContacts.tr(),
                            style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )
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
                            title: Text(LocaleKeys.selectPlayers.tr()),
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
                              LocaleKeys.selectFromContacts.tr(),
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
                                labelText: LocaleKeys.topic.tr(),
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
                                hintText: LocaleKeys.insertTheTopic.tr(),
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
                              child: Text(LocaleKeys.send.tr(),
                                  style: const TextStyle(color: Colors.yellow)),
                              onPressed: () async {
                                Vibration.vibrate(
                                    pattern: [150], intensities: [20]);
                                if (_selectedContacts!.isNotEmpty &&
                                    _myController.text.isNotEmpty) {
                                  _setFakeArtist();
                                  _finalConfirm(ctx);
                                } else if (_selectedContacts!.isEmpty) {
                                  _showSnackBar(ctx, LocaleKeys.noPlayerSelected.tr());
                                } else {
                                  _showSnackBar(ctx, LocaleKeys.noTopicSelected.tr());
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
          title: Text(LocaleKeys.finalConfirm.tr()),
          content: Text(LocaleKeys.doYouWantToSend.tr()),
          actions: <Widget>[
            ElevatedButton(
                child: Text(LocaleKeys.yes.tr()),
                onPressed: () {
                  if (_isSmsPermissionGranted) {
                    sendSMS(_selectedContacts!, _myController.text);
                    _showSnackBar(context, LocaleKeys.finished.tr());
                  } else {
                    getSmsPermission();
                  }
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
              child: Text(LocaleKeys.no.tr()),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
