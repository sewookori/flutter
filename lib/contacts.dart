import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'generated/locale_keys.g.dart';

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

sendSMS(List<ContactInfo> selectedContactList, String topic) async {
  for (var selectedContact in selectedContactList) {
    if (selectedContact.phone != 'None') {
      if ((await _supportCustomSim)!) {
        if (selectedContact.isFakeArtest == true) {
          print(
              'send message : ${selectedContact.name}, (fake artist), ${selectedContact.phone}');
          _sendMessage(selectedContact.phone, LocaleKeys.fakeArtist.tr(), simSlot: 1);
        } else {
          print(
              'send message : ${selectedContact.name}, (true artist), ${selectedContact.phone}, hint: $topic');
          _sendMessage(
              selectedContact.phone, LocaleKeys.trueArtistWithArg.tr(args: [topic]),
              simSlot: 1);
        }
      } else {
        if (selectedContact.isFakeArtest == true) {
          print(
              'send message : ${selectedContact.name}, ${selectedContact.phone}');
          _sendMessage(selectedContact.phone, LocaleKeys.fakeArtist.tr());
        } else {
          print(
              'send message : ${selectedContact.name}, (true artist), ${selectedContact.phone}, hint: $topic');
          _sendMessage(
              selectedContact.phone, LocaleKeys.trueArtistWithArg.tr(args: [topic]));
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

_sendMessage(String phoneNumber, String message, {int? simSlot}) async {
  var result = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber, message: message, simSlot: simSlot);
  if (result == SmsStatus.sent) {
    print("Sent");
  } else {
    print("Failed");
  }
}

void getSmsPermission() async => await [
      Permission.sms,
    ].request();

Future<bool> checkSmsPermissionGranted() async =>
    await Permission.sms.status.isGranted;

Future<bool> fetchContacts(List<ContactInfo> contactInfoList) async {
  if (!await FlutterContacts.requestPermission(readonly: true)) {
    return false;
  } else {
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
          contactInfoList.add(contactInfo);
        }
      }
      return true;
    } else {
      print('No Contacts found !');
      return false;
    }
  }
}
