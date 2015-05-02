part of comet.server;

class CometSocket {
  /// The websocket associated with the user
  final CompatibleWebSocket _socket;
  final SessionManager _sessionManager;

  Session _session;
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

  /// Sends a message to the client.
  void _send(Message msg) {
    _socket.add(JSON.encode(msg));
  }

  /// Processes a message sent from the client.
  ///
  /// If a [Message] is returned, it will be sent to the client. If it is null,
  /// no message will be sent.
  Message _process(Message msg) {
    stdout.writeln(msg);

    switch (msg.type) {
      case MessageType.login:
        _user = (msg as LoginMessage).username;

        var hasSession = _sessionManager.hasSession(_user);

        if (hasSession) {
          _useSession(_sessionManager[_user]);
        }

        return new LoginSuccessMessage(hasSession);

      case MessageType.connect:
        if (_user == null) {
          return new ErrorMessage("Must login before connecting.");
        }

        var config = _getIrcConfiguration(msg as ConnectMessage);
        _useSession(_sessionManager.newSession(config, _user));

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

  /// Listens to a [Session] for messages, and forwards them to client.
  void _useSession(Session session) {
    _session = session;
    _session.listen((msg) => _send(msg));
  }

  static Configuration _getIrcConfiguration(ConnectMessage msg) {
    return new Configuration(
        host: msg.host,
        port: msg.port,
        nickname: msg.nickname,
        username: msg.username,
        realname: msg.realname);
  }
}
