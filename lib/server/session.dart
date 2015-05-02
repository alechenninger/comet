part of comet.server;

typedef void OnReceive(Message message);

/// Creates an Irc [Client] for a given Irc [Configuration].
typedef Client ClientFactory(Configuration config);

defaultClientFactory(Configuration config) {
  return new Client(config);
}

/// A session is a persistent connection to an IRC server, which accepts
/// commands to that IRC server, as well as publishes a stream of events from
/// the IRC server. Events are persisted (either in memory or on disk), and
/// only removed after delivery confirmation.
class Session {
  final Client _client;

  /// This could eventually be abstracted to be an event store that did not
  /// entirely live in memory (persisted to disk after some amount of messages
  /// or if messages go unconfirmed for too long).
  final List<Message> _received = new List();

  OnReceive _onReceive = _noop;

  Session(Configuration config,
      {ClientFactory clientFactory: defaultClientFactory})
      : _client = clientFactory(config) {

    // Register handlers before connecting.
    _handlerFactories
        .forEach((getHandler) => _client.register(getHandler(_receive)));

    _client.connect();
  }

  /// Removes the message from the delivery queue
  void confirmReceipt(String id) {
    _received.removeWhere((m) => m.id == id);
  }

  /// Sets an event listener for all new events. Only one listener may be active
  /// at one time. When first subscribing, all unconfirmed events will be
  /// communicated, and then any new events will be communicated in real time.
  void listen(OnReceive onEvent) {
    _onReceive = onEvent == null ? _noop : onEvent;
    _received.forEach(_onReceive);
  }

  /// Sends a message to the IRC server.
  void sendMessage(SendMessage msg) {
    _client.sendMessage(msg.target, msg.message);
  }

  /// Add event to queue, triggering listeners and persisting the event.
  void _receive(Message msg) {
    _received.add(msg);
    _onReceive(msg);
  }
}

void _noop(event) {}

/// List of handler factories. Each takes a callback and returns a handler
/// function. A factory exists for each IRC event we deal with.
List _handlerFactories = [
  (callback) => (MessageEvent event) =>
      callback(new ReceiveMessage(event.from, event.target, event.message)),
  (callback) => (MOTDEvent event) =>
      callback(new ReceiveMessage("server", "you", event.message)),
  (callback) => (ConnectEvent event) => callback(new ConnectSuccessMessage())
];
