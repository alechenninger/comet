part of comet;

class CometSocket {
  /// The websocket associated with the user
  final WebSocket _socket;
  final SessionManager _sessionManager;

  /// Listen to the [_socket] for messages.
  CometSocket(this._socket, this._sessionManager) {
    // Set on connection event
    Session session;
    String user;

    _socket.listen((data) {
      var msg = new Message.fromJson(data);
      stdout.writeln(data);

      switch (msg.type) {
        case MessageType.connect:
          var config = new IrcConfig.fromMap(msg.toJson());
          session = _sessionManager.newSession(config, user);

          session.listen((msg) => _socket.add(JSON.encode(msg)));

          break;
        case MessageType.send:
          session.sendMessage(msg);

          break;
        default:
          throw new ArgumentError("Unsupported message type.");
      }
    });
  }
}
