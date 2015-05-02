import 'dart:html';

import 'package:comet/client.dart';

main() async {
  CometClient client = await CometClient.connect("ws://${window.location.host}/ws");
  await client.login("comettest");

  if (!client.hasSession) {
    await client.newConnection(freenode);
  }

  client.messages.listen(window.console.log);
}

ConnectMessage freenode = new ConnectMessage("irc.freenode.net", 6667,
        'comettest', 'comettest', 'Comet Test');
