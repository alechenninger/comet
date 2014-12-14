import 'dart:html';
import 'dart:convert';

import '../lib/comet.dart';

void main() {
  WebSocket ws = new WebSocket("ws://${window.location.host}/ws");

  var callback;

  void login() {
    ws.sendString(JSON.encode(new LoginMessage('comettest')));
  }

  void connect() {
    ws.sendString(JSON.encode(new ConnectMessage("irc.freenode.net", 6667,
        'comettest', 'comettest', 'Comet Test')));
  }

  ws.onMessage.listen((MessageEvent msgEvent) {
    var msg = new Message.fromJson(msgEvent.data);

    window.console.log(msg.toString());

    if (msg is LoginSuccessMessage) {
      connect();
    }
  });

  ws.onOpen.listen((e) {
    login();
  });

}