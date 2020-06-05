/*
 * Copyright (C) 2020 DEÁK JAHN Gábor.
 * All rights reserved.
 */

library worker;

import 'package:flutter/foundation.dart';

import 'worker.dart' //
    if (dart.library.io) 'worker_io.dart'
    if (dart.library.html) 'worker_web.dart';

abstract class BackgroundWorker {
  factory BackgroundWorker() => getWorker();

  List<String> get names => [];

  void spawn<T>(void Function(String) mainFunction, {@required String name, void Function() onInitialized, void Function(T message) onReceive});

  void send(String name, dynamic message);

  void listen(void Function(dynamic message) onData, {@required Map<String, dynamic> context, void Function() onError, void Function() onDone, bool cancelOnError});

  void kill(String name);
}
