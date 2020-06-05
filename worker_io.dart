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
  static final Map<String, HandledIsolateMessenger> _messengers = {};
  static final Map<String, void Function(String)> _mainFunctions = {};

  @override
  List<String> get names => _isolates.isolates.keys.toList();

  @override
  void spawn<T>(void Function(String) mainFunction, {@required String name, void Function() onInitialized, void Function(T message) onReceive}) {
    _mainFunctions[name] = mainFunction;
    _isolates.spawn(
      BackgroundWorkerIo._start,
      name: name,
      onInitialized: onInitialized,
      onReceive: onReceive,
    );
  }

  static void _start(Map<String, dynamic> context) {
    String name = context['name'] as String;
    _messengers[name] = HandledIsolate.initialize(context);
    _mainFunctions[name]?.call(name);
  }

  @override
  void send(String name, dynamic message) {
    _isolates.send(message, to: name);
  }

  @override
  void listen(void Function(dynamic message) onData, {@required String name, void Function() onError, void Function() onDone, bool cancelOnError}) {
    final messenger = _messengers[name];
    assert(messenger != null, 'Unknown name');

    messenger.listen(
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
