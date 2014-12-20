part of comet;

class CometSocket {
  /// The websocket associated with the user
  final WebSocket _socket;
  final SessionManager _sessionManager;

  Session _session;
  String _user;

  /// Listen to the [_socket] for messages.
  CometSocket(this._socket, this._sessionManager) {
    _socket.listen((data) {
      var reply = _process(new Message.fromJson(data));

      if (reply != null) {
        _reply(reply);
      }
    });
  }

  void _reply(Message msg) {
    _socket.add(JSON.encode(msg));
  }

  /// If a [Message] is returned, it will be sent to the client. If it is null,
  /// no message will be sent.
  Message _process(Message msg) {
    stdout.writeln(msg);

    switch (msg.type) {
      case MessageType.login:
        _user = (msg as LoginMessage).username;
        _session = _sessionManager[_user];

        return new LoginSuccessMessage(_session != null);

      case MessageType.connect:
        if(_user == null) {
          return new ErrorMessage("Must login before connecting.");
        }

        var config = new IrcConfig.fromMap(msg.toJson());
        _session = _sessionManager.newSession(config, _user);

        _session.listen((msg) => _reply(msg));

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
}
