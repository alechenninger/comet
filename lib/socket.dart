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
      var msg = new Message.fromJson(data);

      if (msg is Processable) {
        process(msg);
      }
    });
  }

  void process(Processable msg) {
    msg.process(this);
  }

  void reply(Message msg) {
    _socket.add(JSON.encode(msg));
  }

  void errorIf(bool ifTrue, String description,
                {void otherwise(): _doNothing}) {
    if (ifTrue) {
      error(description);
    } else {
      otherwise();
    }
  }

  void error(String description) {
    reply(new ErrorMessage(description));
  }
}

void _doNothing() {}
