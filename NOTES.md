config:
- host
- port
- nickname
- username
- realname

actions:


events:


each time a websocket connection is made
new websockethandler (one per connection/client)

websockethandler(socket, ircclientfactory)

needs an ircclientfactory to handle connect messages

this.host: "irc.esper.net", this.port: 6667, this.nickname: "DartBot", this.username: "DartBot", this.realname: "Dart IRC Bot"}


need to separate socket server from client connections

client connections need to be persisted



irc -> app -> buffer

client <- buffer, reading from persisted messages first

app start

create client connections

IrcConnector
-> newClient(Config config, Buffer buffer);
Connects to irc, forwards events to a buffer.

Buffer
Queue of events. If not consumed, stays in queue.
Events must be per 

On WebSocket connection + login, find a buffer if associated for that user

