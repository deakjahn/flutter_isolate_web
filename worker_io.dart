/*
 * Copyright (C) 2020 DEÁK JAHN Gábor.
 * All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:isolate_handler/isolate_handler.dart';

import 'interface.dart';

BackgroundWorker getWorker() => BackgroundWorkerIo();

class BackgroundWorkerIo implements BackgroundWorker {
  final _isolates = IsolateHandler();
  final Map<String, HandledIsolateMessenger> _messengers = {};

  @override
  List<String> get names => _isolates.isolates.keys.toList();

  @override
  void spawn(void Function(Map<String, dynamic>) entryPoint, {@required String name, void Function() onInitialized, void Function(Map<String, dynamic> message) onFromWorker}) {
    assert(entryPoint != null);

    _isolates.spawn(
      entryPoint,
      name: name,
      onInitialized: onInitialized,
      onReceive: onFromWorker,
    );
  }

  @override
  void sendTo(String name, dynamic message) {
    _isolates.send(message, to: name);
  }

  @override
  void sendFrom(String name, dynamic message) {
    final messenger = _messengers[name];
    assert(messenger != null, 'Unknown name');

    messenger.send(message);
  }

  @override
  void listen(void Function(dynamic message) onFromMain, {@required Map<String, dynamic> context, void Function() onError, void Function() onDone, bool cancelOnError}) {
    assert(onFromMain != null);

    String name = context['name'];
    final messenger = _messengers[name] = HandledIsolate.initialize(context);
    messenger.listen(
      onFromMain,
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
