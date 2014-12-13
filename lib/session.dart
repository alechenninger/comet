part of comet;

/// A session is a persistent connection to an IRC server, which accepts
/// commands to that IRC server, as well as publishes a stream of events from
/// the IRC server. Events are persisted (either in memory or on disk), and
/// only removed after delivery confirmation.
abstract class Session {
  get events;

  confirmDelivery();


}