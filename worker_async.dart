/*
 * Copyright (C) 2020 DEÁK JAHN Gábor.
 * All rights reserved.
 */

import 'dart:async';

import 'package:cpc_mobile/order/uploader/worker/interface.dart';
import 'package:flutter/foundation.dart';

BackgroundWorker getWorker() => BackgroundWorkerAsync();

/// This is NOT a real background worker, it's a simple asynchronous one.
/// It implements the same interface and sends and receives messages the same way as the real workers do,
/// so it can be used for testing instead of a parallel worker (or when a real worker can't be built).
class BackgroundWorkerAsync implements BackgroundWorker {
  final Map<String, void Function(Map<String, dynamic> message)> _messengers = {};
  final events = StreamController<_BackgroundWorkerEvent>.broadcast();

  /// Returns the names of all running workers.
  @override
  List<String> get names => _messengers.keys.toList();

  /// Starts a new worker.
  ///
  /// [entryPoint] is the place for the actual work in the worker: start from here what you want to accomplish in the worker.
  /// It must be a top-level or static function, with a single argument [context]. [name] must be a unique name to refer
  /// to the worker later. [onInitialized] will be called when the worker is actually started and ready to send or receive messages.
  /// [onFromWorker] will be called with all messages coming from the worker.
  @override
  void spawn(void Function(Map<String, dynamic>) entryPoint, {@required String name, void Function() onInitialized, void Function(Map<String, dynamic> message) onFromWorker}) {
    assert(entryPoint != null);

    _messengers[name] = onFromWorker;
    entryPoint({'name': name});
    onInitialized?.call();
  }

  /// Sends a message to a worker.
  ///
  /// [name] identifies the worker to send the message to.
  @override
  void sendTo(String name, dynamic message) {
    events.add(_BackgroundWorkerEvent(name, message));
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

    messenger(message);
  }

  /// Receives messages from the main app.
  ///
  /// Workers can use this function to set up their listener for messages coming from the main app.
  /// This is normally called from their [entryPoint] function, passing the [context] that function receives.
  @override
  void listen(void Function(dynamic message) onFromMain, {@required Map<String, dynamic> context, void Function() onError, void Function() onDone, bool cancelOnError}) {
    assert(onFromMain != null);

    String name = context['name'];
    assert(name != null, 'Unknown name');

    _onEvent(name: name).listen((event) {
      onFromMain(event.message);
    });

    if (onError != null)
      _onError(name: name).listen((event) {
        onError();
        if (cancelOnError) kill(name);
      });
  }

  /// Kills a worker.
  ///
  /// [name] identifies to the worker to kill.
  @override
  void kill(String name) {}

  /// Internal event queue for the worker. It stores *incoming* messages.
  Stream<_BackgroundWorkerMessage> _onEvent({@required String name}) {
    return events.stream //
        .where((event) => event.name == name && event is _BackgroundWorkerMessage)
        .cast<_BackgroundWorkerMessage>();
  }

  /// Internal event queue for the worker. It stores error events.
  Stream<_BackgroundWorkerError> _onError({@required String name}) {
    return events.stream //
        .where((event) => event.name == name && event is _BackgroundWorkerError)
        .cast<_BackgroundWorkerError>();
  }
}

class _BackgroundWorkerEvent<T> {
  final String name;
  final T message;

  _BackgroundWorkerEvent(this.name, this.message);
}

class _BackgroundWorkerError extends _BackgroundWorkerEvent {
  _BackgroundWorkerError(String name) : super(name, null);
}

class _BackgroundWorkerMessage extends _BackgroundWorkerEvent<Map<String, dynamic>> {
  _BackgroundWorkerMessage(String name, Map<String, dynamic> message) : super(name, message);
}
