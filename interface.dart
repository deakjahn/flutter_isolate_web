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

  /// Returns the names of all running workers.
  List<String> get names => [];

  /// Starts a new worker.
  ///
  /// [entryPoint] is the place for the actual work in the worker: start from here what you want to accomplish in the worker.
  /// It must be a top-level or static function, with a single argument [context]. [name] must be a unique name to refer
  /// to the worker later. [onInitialized] will be called when the worker is actually started and ready to send or receive messages.
  /// [onFromWorker] will be called with all messages coming from the worker.
  void spawn(void Function(Map<String, dynamic>) entryPoint, {@required String name, void Function() onInitialized, void Function(Map<String, dynamic> message) onFromWorker});

  /// Sends a message to a worker.
  ///
  /// [name] identifies the worker to send the message to.
  void sendTo(String name, dynamic message);

  /// Sends a message from a worker.
  ///
  /// Workers can use this function to send their messages back to the main app.
  /// In order to do that, they must have a reference to this object (can be sent to them when they are started)
  /// and they also have to know their own uniqe [name].
  void sendFrom(String name, dynamic message);

  /// Receives messages from the main app.
  ///
  /// Workers can use this function to set up their listener for messages coming from the main app.
  /// This is normally called from their [entryPoint] function, passing the [context] that function receives.
  void listen(void Function(dynamic message) onFromMain, {@required Map<String, dynamic> context, void Function() onError, void Function() onDone, bool cancelOnError});

  /// Kills a worker.
  ///
  /// [name] identifies to the worker to kill.
  void kill(String name);
}
