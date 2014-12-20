// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import '../lib/server.dart';

import 'dart:io';


void main(List<String> args) {
  var parser = new ArgParser()
      ..addOption('port', abbr: 'p', defaultsTo: '8080')
      ..addOption('host', abbr: 'h', defaultsTo: 'localhost')
      ..addOption('fileSystemPath', abbr: 'f', defaultsTo: 'build/web');

  var results = parser.parse(args);

  var host = results['host'];
  var port = int.parse(results['port'], onError: logParseErrorAndQuit);
  var fileSystemPath = results['fileSystemPath'];
  var sessionManager = new SessionManager();

  new CometHttp(host, port, sessionManager, fileSystemPath: fileSystemPath)
      .serve();
}

logParseErrorAndQuit(val) {
  stdout.writeln('Could not parse port value "$val" into a number.');
  exit(1);
}