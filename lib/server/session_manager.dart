part of comet.server;

class SessionManager {
  final Map<String, Session> _sessions = new Map();
  final ClientFactory _clientFactory;

  SessionManager({ClientFactory clientFactory: defaultClientFactory})
      : _clientFactory = clientFactory;

  bool hasSession(String user) {
    return _sessions.containsKey(user);
  }

  Session operator [](String user) {
    return _sessions[user];
  }

  Session newSession(Configuration config, String user) {
    _sessions[user] = new Session(config, clientFactory: _clientFactory);
    return this[user];
  }
}
