part of comet;

class CometSocket {
  /// Makes new irc clients
  final ClientFactory _clientFactory;

  /// The websocket associated with the user
  final WebSocket _socket;

  /// Create a new [CometSocket] for the given [WebSocket]. Optionally a
  /// [clientFactory] may be passed which accepts an [IrcConfig] and returns a
  /// new [Client]. By default this uses a real [Client], but maybe overriden
  /// for testing.
  CometSocket(this._socket, {ClientFactory clientFactory}):
    _clientFactory = clientFactory == null
        ? defaultClientFactory
        : clientFactory {
      _registerSocketEventHandlers();
    }

  void _registerSocketEventHandlers() {
    // Set on connection event
    Client client;

    /// Precondition before processing most events. Pass [msg] for inclusion
    /// in potential [StateError] when [client] is still null.
    void ensureClient(msg) {
      if (client == null) {
        throw new StateError(
            "Must connect to client first. Message was ${msg}.");
      }
    }

    _socket.listen((data) {
      var msg = new Message.fromJson(data);
      stdout.writeln(data);

      switch (msg.type) {
        case MessageType.connect:
          var config = new IrcConfig.fromMap(msg.body);
          client = _clientFactory(config);

          client.connect();
          _registerIrcEventHandlers(client);

          break;
        case MessageType.send:
          ensureClient(msg);

          var sendMsg = new SendMessage.fromMap(msg.body);

          client.sendMessage(sendMsg.target, sendMsg.message);

          break;
        default:
          throw new ArgumentError("Unknown message type.");
      }
    });
  }

  void _registerIrcEventHandlers(Client client) {
    client.register((MessageEvent event) {
      _socket.add(JSON.encode(
          new ReceiveMessage(event.from, event.target, event.message)));
    });
  }
}

ClientFactory defaultClientFactory = (c) => new Client(c);

typedef MessageHandler(Map<WebSocket, Client> clients, WebSocket socket, dynamic msg);
typedef Client ClientFactory(IrcConfig config);