part of comet;

class CometSocket {
  /// The websocket associated with the user
  final WebSocket _socket;
  final SessionManager _sessionManager;

  Session __session;
  String _user;

  /// Listen to the [_socket] for messages.
  CometSocket(this._socket, this._sessionManager) {
    _socket.listen((data) {
      var reply = _process(new Message.fromJson(data));

      if (reply != null) {
        _send(reply);
      }
    });
  }

  void _send(Message msg) {
    _socket.add(JSON.encode(msg));
  }

  /// If a [Message] is returned, it will be sent to the client. If it is null,
  /// no message will be sent.
  Message _process(Message msg) {
    stdout.writeln(msg);

    switch (msg.type) {
      case MessageType.login:
        _user = (msg as LoginMessage).username;
        var hasSession = _sessionManager.hasSession(_user);

        if (hasSession) {
          _session = _sessionManager[_user];
        }

        return new LoginSuccessMessage(hasSession);

      case MessageType.connect:
        if(_user == null) {
          return new ErrorMessage("Must login before connecting.");
        }

        var config = new IrcConfig.fromMap(msg.toJson());
        _session = _sessionManager.newSession(config, _user);

        break;

      case MessageType.send:
        if (_session == null) {
          return new ErrorMessage("Must connect before sending a message.");
        }

        _session.sendMessage(msg);

        break;
      case MessageType.confirm:
        _session.confirmReceipt((msg as ConfirmMessage).receivedId);

        break;
      default:
       return new ErrorMessage("Unsupported message type, ${msg}");
    }

    return null;
  }

  set _session(Session session) {
    __session = session;
    __session.listen((msg) => _send(msg));
  }

  Session get _session => __session;
}
