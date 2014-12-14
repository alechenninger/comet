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

      switch (msg.type) {
        case MessageType.login:
          user = (msg as LoginMessage).username;
          session = _sessionManager[user];

          _socket.add(new LoginSuccessMessage(session != null));

          break;
        case MessageType.connect:
          var config = new IrcConfig.fromMap(msg.toJson());
          session = _sessionManager.newSession(config, user);

          session.listen((msg) => _socket.add(JSON.encode(msg)));

          break;
        case MessageType.send:
          session.sendMessage(msg);

          break;
        default:
          _socket.add(new ErrorMessage("Unsupported message type, ${msg}"));
      }
    });
  }
}
