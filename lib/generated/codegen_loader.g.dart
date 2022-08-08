// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> en_US = {
  "searchingContacts": "Searching contacts...",
  "selectFromContacts": "Select players from Contacts",
  "selectPlayers": "Select players",
  "topic": "topic",
  "insertTheTopic": "Insert the topic",
  "noPlayerSelected": "No player selected !",
  "noTopicSelected": "No topic selected !",
  "finalConfirm": "Final confirm",
  "doYouWantToSend": "Do you want to send ?",
  "yes": "Yes",
  "no": "No",
  "trueArtistWithArg": "The topic for this round is {}",
  "fakeArtist": "You are the fake artist !",
  "send": "SEND",
  "finished": "Finished !"
};
static const Map<String,dynamic> ja_JP = {
  "searchingContacts": "連絡先 検索中...",
  "selectFromContacts": "連絡先でプレイヤー選択",
  "selectPlayers": "プレイヤー選択",
  "topic": "お題",
  "insertTheTopic": "お題 入力",
  "noPlayerSelected": "プレイヤーが選択されていません !",
  "noTopicSelected": "お題が選択されていません !",
  "finalConfirm": "確認",
  "doYouWantToSend": " 本当に送りますか ?",
  "yes": "はい",
  "no": "いいえ",
  "trueArtistWithArg": "今回のラウンドのお題は{}です.",
  "fakeArtist": "あなたはエセ芸術家です !",
  "send": "送信",
  "finished": "完了 !"
};
static const Map<String,dynamic> ko_KR = {
  "searchingContacts": "전화번호부 목록 조회중...",
  "selectFromContacts": "전화번호부로 플레이어 선택",
  "selectPlayers": "플레이어 선택",
  "topic": "주제어",
  "insertTheTopic": "주제어 입력",
  "noPlayerSelected": "선택된 플레이어가 없습니다 !",
  "noTopicSelected": "선택된 주제어가 없습니다 !",
  "finalConfirm": "최종 확인",
  "doYouWantToSend": "정말 보내시겠습니까 ?",
  "yes": "예",
  "no": "아니오",
  "trueArtistWithArg": "이번 라운드의 주제는 {}입니다.",
  "fakeArtist": "당신은 가짜 예술가입니다 !",
  "send": "보내기",
  "finished": "전송 완료 !"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en_US": en_US, "ja_JP": ja_JP, "ko_KR": ko_KR};
}
