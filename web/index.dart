import 'dart:html';

import 'package:comet/client.dart';

void main() {
  CometClient.connect("ws://${window.location.host}/ws").then((client) {
    return client.login("comettest");
  }).then((client) {
    if (!client.hasSession) {
      return client.newConnection(freenode);
    }
  }).then((client) {
    client.messages.listen((msg) => window.console.log(msg.toString()));
  });

}

ConnectMessage freenode = new ConnectMessage("irc.freenode.net", 6667,
        'comettest', 'comettest', 'Comet Test');