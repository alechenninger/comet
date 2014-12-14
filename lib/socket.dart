part of comet;

class CometSocket {
  /// The websocket associated with the user
  final WebSocket _socket;
  final SessionManager _sessionManager;

  /// Listen to the [_socket] for messages.
  CometSocket(this._socket, this._sessionManager) {
    Session session;
    String user;

    _socket.listen((data) {
      var msg = new Message.fromJson(data);
      stdout.writeln(data);

      // TODO: Need a better way to manage preconditions
      switch (msg.type) {
        case MessageType.login:
          user = (msg as LoginMessage).username;
          session = _sessionManager[user];

          _reply(new LoginSuccessMessage(session != null));

          break;
        case MessageType.connect:
          _errorIf(user == null, "Must login before connecting.",
            otherwise: () {
              var config = new IrcConfig.fromMap(msg.toJson());
              session = _sessionManager.newSession(config, user);

              session.listen((msg) => _reply(msg));
            });

          break;
        case MessageType.send:
          _errorIf(session == null, "Must connect before sending a message.",
              otherwise: () {
                session.sendMessage(msg);
              });

          break;
        case MessageType.confirm:
          session.confirmReceipt((msg as ConfirmMessage).receivedId);

          break;
        default:
          _error("Unsupported message type, ${msg}");
      }
    });
  }

  void _reply(Message msg) {
    _socket.add(JSON.encode(msg));
  }

  void _errorIf(bool ifTrue, String description,
                {void otherwise(): _doNothing}) {
    if (ifTrue) {
      _error(description);
    } else {
      otherwise();
    }
  }

  void _error(String description) {
    _reply(new ErrorMessage(description));
  }
}

void _doNothing() {}
