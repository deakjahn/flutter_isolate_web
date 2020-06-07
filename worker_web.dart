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

  @override
  List<String> get names => _workers.keys.toList();

  @override
  void spawn(void Function(Map<String, dynamic>) entryPoint, {@required String name, void Function() onInitialized, void Function(Map<String, dynamic> message) onFromWorker}) {
    assert(entryPoint != null);

    final code = Blob([source], 'text/javascript');
    String codeUrl = _workerUrls[name] = Url.createObjectUrlFromBlob(code);
    final worker = _workers[name] = Worker(codeUrl);
    _messengers[name] = onFromWorker;
    worker.onMessage.listen((event) {
      onFromWorker?.call(event.data);
    });
    onInitialized?.call();
  }

  @override
  void sendTo(String name, dynamic message) {
    final worker = _workers[name];
    assert(worker != null, 'Unknown name');

    worker.postMessage(message);
  }

  @override
  void sendFrom(String name, dynamic message) {
    final messenger = _messengers[name];
    assert(messenger != null, 'Unknown name');

    messenger(message);
  }

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

  @override
  void kill(String name) {
    final worker = _workers[name];
    assert(worker != null, 'Unknown name');

    worker.terminate();
    Url.revokeObjectUrl(_workerUrls[name]);
  }
}
