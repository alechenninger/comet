part of comet;

abstract class Message {
  final Map _fields;

  Message(this._fields);

  factory Message.fromMap(Map<String, Object> map) {
    switch (map["type"]) {
      case MessageType.send: return new SendMessage.fromMap(map);
      case MessageType.connect: return new ConnectMessage.fromMap(map);
      case MessageType.login: return new LoginMessage.fromMap(map);
      case MessageType.send: return new SendMessage.fromMap(map);
      default: throw new ArgumentError("Unrecognized message type: ${map['type']}");
    }
  }

  factory Message.fromJson(String json) {
    return new Message.fromMap(JSON.decode(json));
  }

  String get type;

  Map toJson() {
    return new Map.from(_fields)
      ..['type'] = type;
  }
}

class ConnectMessage extends Message {
  ConnectMessage(String host, int port, String username, String nickname,
      String realname): super({
        "host": host,
        "port": port,
        "username": username,
        "nickname": nickname,
        "realname": realname
      });

  ConnectMessage.fromMap(Map map): super(map);

  String get type => MessageType.connect;
  String get host => _fields['host'];
  int get port => _fields['port'];
  String get username => _fields['username'];
  String get nickname => _fields['nickname'];
  String get realname => _fields['realname'];
}

class SendMessage extends Message {
  SendMessage(String target, String message): super({
    "target": target,
    "message": message
  });

  SendMessage.fromMap(Map map): super(map);

  String get type => MessageType.send;
  String get target => _fields['target'];
  String get message => _fields['message'];
}

class ReceiveMessage extends Message {
  ReceiveMessage(from, target, message): super({
    "from": from,
    "target": target,
    "message": message
  });

  ReceiveMessage.fromMap(Map map): super(map);

  String get type => MessageType.receive;
  String get from => _fields["from"];
  String get target => _fields["target"];
  String get message => _fields["message"];
}

class LoginMessage extends Message {
  LoginMessage(String username): super({
    "username": username
  });

  LoginMessage.fromMap(Map map): super(map);

  String get type => MessageType.login;
  String get username => _fields['username'];
}

class MessageType {
  static const String login = 'login';
  static const String connect = 'connect';
  static const String send = 'send';
  static const String receive = 'receive';
}