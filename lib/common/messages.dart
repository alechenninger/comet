part of comet.common;

abstract class Message {
  String get id => _message['id'];

  String get type;

  final Map _message;

  Message(this._message) {
    _message.putIfAbsent('id', () => new Uuid().v1());
    _message['type'] = type;
  }

  factory Message.fromMap(Map<String, Object> map) {
    switch (map["type"]) {
      case MessageType.send:
        return new SendMessage.fromMap(map);
      case MessageType.connect:
        return new ConnectMessage.fromMap(map);
      case MessageType.connectSuccess:
        return new ConnectSuccessMessage();
      case MessageType.login:
        return new LoginMessage.fromMap(map);
      case MessageType.loginSuccess:
        return new LoginSuccessMessage.fromMap(map);
      case MessageType.error:
        return new ErrorMessage.fromMap(map);
      case MessageType.confirm:
        return new ConfirmMessage.fromMap(map);
      case MessageType.receive:
        return new ReceiveMessage.fromMap(map);
      default:
        throw new ArgumentError("Unrecognized message type: ${map['type']}");
    }
  }

  factory Message.fromJson(String json) {
    return new Message.fromMap(JSON.decode(json));
  }

  factory Message.copyOf(Message msg) {
    return new Message.fromMap(msg.toJson());
  }

  bool operator ==(other) {
    if (other is! Message) {
      return false;
    }

    return other.id == id;
  }

  int get hashCode => _message.hashCode;

  String toString() {
    return JSON.encode(toJson());
  }

  Map toJson() {
    return new Map.from(_message);
  }
}

class ConnectMessage extends Message {
  ConnectMessage(
      String host, int port, String username, String nickname, String realname)
      : super({
        "host": host,
        "port": port,
        "username": username,
        "nickname": nickname,
        "realname": realname
      });

  ConnectMessage.fromMap(Map map) : super(map);

  String get type => MessageType.connect;

  String get host => _message['host'];

  int get port => _message['port'];

  String get username => _message['username'];

  String get nickname => _message['nickname'];

  String get realname => _message['realname'];
}

class SendMessage extends Message {
  SendMessage(String target, String message)
      : super({"target": target, "message": message});

  SendMessage.fromMap(Map map) : super(map);

  String get type => MessageType.send;

  String get target => _message['target'];

  String get message => _message['message'];
}

class ReceiveMessage extends Message {
  ReceiveMessage(from, target, message)
      : super({"from": from, "target": target, "message": message});

  ReceiveMessage.fromMap(Map map) : super(map);

  String get type => MessageType.receive;

  String get from => _message["from"];

  String get target => _message["target"];

  String get message => _message["message"];
}

class LoginMessage extends Message {
  LoginMessage(String username) : super({"username": username});

  LoginMessage.fromMap(Map map) : super(map);

  String get type => MessageType.login;

  String get username => _message['username'];
}

class ErrorMessage extends Message {
  ErrorMessage(String description) : super({"description": description});

  ErrorMessage.fromMap(Map map) : super(map);

  String get type => MessageType.error;

  String get description => _message['description'];
}

class LoginSuccessMessage extends Message {
  LoginSuccessMessage(bool hasSession) : super({"hasSession": hasSession});

  LoginSuccessMessage.fromMap(Map map) : super(map);

  String get type => MessageType.loginSuccess;

  bool get hasSession => _message['hasSession'];
}

class ConfirmMessage extends Message {
  ConfirmMessage(String receivedId) : super({"receivedId": receivedId});

  ConfirmMessage.fromMap(Map map) : super(map);

  String get type => MessageType.confirm;

  String get receivedId => _message['receivedId'];
}

class ConnectSuccessMessage extends Message {
  ConnectSuccessMessage() : super({});

  @override
  String get type => MessageType.connectSuccess;
}

class MessageType {
  static const String login = 'login';
  static const String loginSuccess = 'loginSuccess';
  static const String connect = 'connect';
  static const String connectSuccess = 'connectSuccess';
  static const String send = 'send';
  static const String receive = 'receive';
  static const String error = 'error';
  static const String confirm = 'confirm';
}
