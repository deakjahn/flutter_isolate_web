/*
 * Copyright (C) 2020 DEÁK JAHN Gábor.
 * All rights reserved.
 */

// https://github.com/flutter/flutter/issues/33577

import 'dart:html';

import 'package:flutter/foundation.dart';

import 'interface.dart';

BackgroundWorker getWorker() => BackgroundWorkerWeb();

class BackgroundWorkerWeb implements BackgroundWorker {
  final Map<String, Worker> _workers = {};
  final Map<String, String> _workerUrls = {};
  final Map<String, void Function(Map<String, dynamic> message)> _messengers = {};

  static String source = 'importScripts('sample.js');// entryPoint();';

  /// Returns the names of all running workers.
  @override
  List<String> get names => _workers.keys.toList();

  /// Starts a new worker.
  ///
  /// [entryPoint] is the place for the actual work in the worker: start from here what you want to accomplish in the worker.
  /// It must be a top-level or static function, with a single argument [context]. [name] must be a unique name to refer
  /// to the worker later. [onInitialized] will be called when the worker is actually started and ready to send or receive messages.
  /// [onFromWorker] will be called with all messages coming from the worker.
  @override
  void spawn(void Function(Map<String, dynamic>) entryPoint, {@required String name, void Function() onInitialized, void Function(Map<String, dynamic> message) onFromWorker}) {
    assert(entryPoint != null);

    final code = Blob([source], 'text/javascript');
    String codeUrl = _workerUrls[name] = Url.createObjectUrlFromBlob(code);
    final worker = _workers[name] = Worker(codeUrl);
    _messengers[name] = onFromWorker;
    worker.onMessage.listen((event) {
      final args = Map<String, dynamic>.from(event.data);
      onFromWorker?.call(args);
    });
    onInitialized?.call();
  }

  /// Sends a message to a worker.
  ///
  /// [name] identifies the worker to send the message to.
  @override
  void sendTo(String name, dynamic message) {
    final worker = _workers[name];
    assert(worker != null, 'Unknown name');

    worker.postMessage(message);
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
    final worker = _workers[name];
    assert(worker != null, 'Unknown name');

    if (onError != null)
      worker.onError.listen((event) {
        onError();
      });
  }

  /// Kills a worker.
  ///
  /// [name] identifies to the worker to kill.
  @override
  void kill(String name) {
    final worker = _workers[name];
    assert(worker != null, 'Unknown name');

    worker.terminate();
    Url.revokeObjectUrl(_workerUrls[name]);
  }
}
