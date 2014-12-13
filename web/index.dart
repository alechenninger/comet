import 'dart:html';

void main() {
  WebSocket ws = new WebSocket("ws://${window.location.host}/ws");

  ws.onMessage.listen((MessageEvent msgEvent) {
    window.console.log(msgEvent);
  });

  ws.onOpen.listen((e) {
    ws.sendString("""{
"type": "connect",
"body": {
  "host": "irc.freenode.net",
  "port": 6667,
  "nickname": "comettest",
  "username": "comettest",
  "realname": "Comet Test"
}}""");
  });
}