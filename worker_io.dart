/*
 * Copyright (C) 2020 DEÁK JAHN Gábor.
 * All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:isolate_handler/isolate_handler.dart';

import 'interface.dart';

BackgroundWorker getWorker() => BackgroundWorkerIo();

class BackgroundWorkerIo implements BackgroundWorker {
  final IsolateHandler _isolates = IsolateHandler();

  @override
  List<String> get names => _isolates.isolates.keys.toList();

  @override
  void spawn<T>(void Function(Map<String, dynamic>) mainFunction, {@required String name, void Function() onInitialized, void Function(T message) onReceive}) {
    _isolates.spawn(
      mainFunction,
      name: name,
      onInitialized: onInitialized,
      onReceive: onReceive,
    );
  }

  @override
  void send(String name, dynamic message) {
    _isolates.send(message, to: name);
  }

  @override
  void listen(void Function(dynamic message) onData, {@required Map<String, dynamic> context, void Function() onError, void Function() onDone, bool cancelOnError}) {
    HandledIsolate.initialize(context).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  void kill(String name) {
    _isolates.kill(name);
  }
}
