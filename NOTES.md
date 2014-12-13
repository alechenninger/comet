# Basic lifecycle

connect to websocket
login
look up existing session, if none, prompt connection info. when receive, start session
starts listening to session (which will dump undelievered messages if any)
user sends to websocket, websocket sends to session
sesion sends to websocket, websocket sends to client