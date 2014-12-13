part of comet;

class CometHttp {
  final _address;
  final _port;

  /// [_address] follows the semantics of [HttpServer.bind], which is to say it
  /// may either be a [String] or an [InternetAddress].
  CometHttp(dynamic this._address, int this._port);

  Future<HttpServer> serve() {
    return shelf_io.serve(_handler, _address, _port).then((server) {
      print("Comet server listening on ${server.address}.");
    });
  }

  get _handler => const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((router()
          ..get("/ws", _ws)
          ..add("/", ["GET"], _static, exactMatch: false)).handler);

  // TODO: Should "build/web" be parameterized? AppEngine compatibility?
  get _static =>
      createStaticHandler("build/web", defaultDocument: "index.html");

  get _ws => webSocketHandler((socket) => new CometSocket(socket));
}
