part of comet.client;

class CometClient {
  final html.WebSocket _socket;
  final StreamController<ReceiveMessage> _messages = new StreamController();

  Completer<CometClient> _login;
  Completer<CometClient> _connect;

  bool _hasSession;

  static Future<CometClient> connect(String server) {
    var socket = new html.WebSocket(server);
    return socket.onOpen.first.then(((e) => new CometClient._(socket)));
  }

  CometClient._(this._socket) {
    _socket.onMessage.listen((event) {
      var reply = _process(new Message.fromJson(event.data));

      if (reply is Message) {
        _send(reply);
      } else if (reply is String) {
        html.window.console.error(reply);
      }
    });
  }

  Future<CometClient> login(String username) {
    _login = new Completer();
    _send(new LoginMessage(username));
    return _login.future;
  }

  Future<CometClient> newConnection(ConnectMessage msg) {
    _connect = new Completer();
    _send(msg);
    return _connect.future;
  }

  Stream<ReceiveMessage> get messages => _messages.stream;

  /// Not sure if this incorrectly returns true when login is completed with an
  /// error.
  bool get isLoggedIn => _login.isCompleted;
  bool get isConnected => _connect.isCompleted;
  bool get hasSession {
    if (!isLoggedIn) {
      throw new StateError("Log in first.");
    }

    return _hasSession;
  }

  void _send(Message msg) {
    _socket.sendString(JSON.encode(msg));
  }

  /// Returns a reply [Message], an error [String], or null.
  dynamic _process(Message msg) {
    html.window.console.log(msg.toString());

    switch (msg.type) {
      case MessageType.loginSuccess:
        if (_login != null) {
          _hasSession = (msg as LoginSuccessMessage).hasSession;
          _login.complete(this);
        }

        break;
      case MessageType.connectSuccess:
        if (_connect != null) {
          _connect.complete(this);
        }

        break;
      case MessageType.receive:
        if (!isConnected) {
          return "Receiving messages but not connected? ${msg.toString()}";
        }

        _messages.add(msg);

        return new ConfirmMessage(msg.id);
      default:
        return "Unsupported message: ${msg.toString()}";
    }

    return null;
  }
}
