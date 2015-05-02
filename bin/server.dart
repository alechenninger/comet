// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:comet/server.dart';

import 'dart:io';

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('host', abbr: 'h', defaultsTo: 'localhost')
    ..addOption('serveFilesFrom', abbr: 'f', defaultsTo: 'build/web');

  var parsedArgs = parser.parse(args);

  var host = parsedArgs['host'];
  var port = int.parse(parsedArgs['port'], onError: logParseErrorAndQuit);
  var serveFilesFrom = parsedArgs['serveFilesFrom'];
  var sessionManager = new SessionManager();

  new CometHttp(host, port, sessionManager, serveFilesFrom: serveFilesFrom)
      .serve();
}

logParseErrorAndQuit(val) {
  stdout.writeln('Could not parse port value "$val" into a number.');
  exit(1);
}
