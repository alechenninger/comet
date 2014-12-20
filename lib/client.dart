part of comet;

class CometClient {
  final html.WebSocket _socket;

  /// Complete with whether or not the current login has an existing session on
  /// the server.
  Completer<bool> _login;
  Completer _connect;

  static Future<CometClient> connect(String server) {
    var socket = new html.WebSocket(server);
    return socket.onOpen.first.then(((e) => new CometClient._(socket)));
  }

  CometClient._(this._socket) {
    _socket.onMessage.listen((event) {
      var reply = _process(new Message.fromJson(event.data));

      if (reply != null) {
        _send(reply);
      }

    });
  }

  Future<bool> login(String username) {
    _login = new Completer();
    _send(new LoginMessage(username));
    return _login.future;
  }

  Future newConnection(ConnectMessage msg) {
    _connect = new Completer();
    _send(msg);
    return _connect.future;
  }

  /// Not sure if this incorrectly returns true when login is completed with an
  /// error.
  bool get isLoggedIn => _login.isCompleted;
  bool get isConnected => _connect.isCompleted;

  void _send(Message msg) {
    _socket.sendString(JSON.encode(msg));
  }

  Message _process(Message msg) {
    html.window.console.log(msg);

    switch (msg.type) {
      case MessageType.loginSuccess:
        if (_login != null) {
          _login.complete((msg as LoginSuccessMessage).hasSession);
        }

        break;
      case MessageType.connectSuccess:
        if (_connect != null) {
          _connect.complete();
        }

        break;
      case MessageType.receive:
        if (!isConnected) {
          html.window.console.error("Receiving messages but not connected? " +
              msg.toString());
        }

        return new ConfirmMessage(msg.id);
      default:
        html.window.console.error("Unsupported message: ${msg}");
    }

    return null;
  }
}