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

  /// Returns the names of all running workers.
  @override
  List<String> get names => _isolates.isolates.keys.toList();

  /// Starts a new worker.
  ///
  /// [entryPoint] is the place for the actual work in the worker: start from here what you want to accomplish in the worker.
  /// It must be a top-level or static function, with a single argument [context]. [name] must be a unique name to refer
  /// to the worker later. [onInitialized] will be called when the worker is actually started and ready to send or receive messages.
  /// [onFromWorker] will be called with all messages coming from the worker.
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

  /// Sends a message to a worker.
  ///
  /// [name] identifies the worker to send the message to.
  @override
  void sendTo(String name, dynamic message) {
    _isolates.send(message, to: name);
  }

  /// Sends a message from a worker.
  ///
  /// Workers can use this function to send their messages back to the main app.
  /// In order to do that, they must have a reference to this object (can be sent to them when they are started)
  /// and they also have to know their own uniqe [name].
  @override
  void sendFrom(String name, dynamic message) {
    final messenger = _messengers[name];
    assert(messenger != null, 'Unknown name');

    messenger.send(message);
  }

  /// Receives messages from the main app.
  ///
  /// Workers can use this function to set up their listener for messages coming from the main app.
  /// This is normally called from their [entryPoint] function, passing the [context] that function receives.
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

  /// Kills a worker.
  ///
  /// [name] identifies to the worker to kill.
  @override
  void kill(String name) {
    _isolates.kill(name);
  }
}
