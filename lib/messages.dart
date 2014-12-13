part of comet;

class Message {
  final String _type;
  final Map<String, Object> _body;

  Message(this._type, this._body);
  Message.fromMap(Map<String, Object> map):
    _type = map['type'],
    _body = map['body'];
  Message.fromJson(String json): this.fromMap(JSON.decode(json));

  String get type => _type;
  Map<String, Object> get body => _body;

  Map toJson() {
    return {
      "type": _type,
      "body": body
    };
  }
}

class SendMessage extends Message {
  SendMessage(target, message): super(MessageType.send, {
    "target": target,
    "message": message
  });

  SendMessage.fromMap(Map<String, Object> map):
    this(map['target'], map['message']);

  SendMessage.fromJson(String json): this.fromMap(JSON.decode(json));

  String get target => body["target"];
  String get message => body["message"];
}

class ReceiveMessage extends Message {
  ReceiveMessage(from, target, message): super(MessageType.receive, {
    "from": from,
    "target": target,
    "message": message
  });

  ReceiveMessage.fromMap(Map<String, Object> map):
    this(map['from'], map['target'], map['message']);

  ReceiveMessage.fromJson(String json): this.fromMap(JSON.decode(json));

  String get from => body["from"];
  String get target => body["target"];
  String get message => body["message"];
}

class MessageType {
  static const String connect = 'connect';
  static const String send = 'send';
  static const String receive = 'receive';
}