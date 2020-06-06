# Flutter Isolate Web

The title is a misnomer. Of course, there are no isolates in Flutter Web. What this code provides
is actually a unified interface to isolates *and* web workers so that each platform can use its own.
It's not a package on pub.dev and it won't be because you can't use it out of the box just like
a regular package or plugin. You have to copy it into your own code and modify it to suit your needs.

## Dependencies

It depends on:

* [isolate_handler](https://pub.dev/packages/isolate_handler), this is what provides
the isolates with communication already in place,

* [js](https://pub.dev/packages/js), this is what provides the connection to JavaScript.

## Usage

Create a worker first:

```dart
final worker = BackgroundWorker();
```

and start it when needed:

```dart
worker.spawn(
  doWork,
  name: 'some-unique-name',
  onInitialized: onInitialized,
  onReceive: onReceive,
);
```

You can start any amount of workers, just give a unique name to all so that you can reference them later when sending
or receiving messages.

`doWork()` is a function taking a `Map` argument (the context of the isolate/worker). As customary with standard isolates,
it has to be a top-level or static function. The most usual activity here is to start listening to messages the isolate/worker
will receive from the main app (the actual message structure is completely up to you, this is just an example):

```dart
void doWork(Map<String, dynamic> context) {
  worker.listen((args) {
    switch (args['command']) {
      case 'start':
        // worker starts its job
        break;
    }
  }, context: context);
}
```

When the isolate/worker actually gets initialized, the main app will be notified. You might simply use this to send a message
back to the worker to start the actual work (the actual message structure is completely up to you, this is just an example):

```dart
void onInitialized() {
  worker.sendTo('some-unique-name', {
    // tell the worker to start its job
    'command': 'start',
    'data': ...,
  });
}
```

There is an important difference between the two that must be understood. `doWork()` runs in the worker/isolate,
this is the main entry point of the worker/isolate code. `onInitialized()` and the other callbacks run in the main app,
this is where the main app receives messages from the workers/isolates.

`onReceive` is the main messaging mechanism. Pass the `worker` and the unique name (returned to you as `context['name']`)
to the isolate/worker so that it can store it and use it to send its messages back:

```dart
worker.sendFrom('unique-name', message);

void onReceive(T message) {
  //...
}
```

If you need to kill the worker/isolate, use:

```dart
worker.kill('unique-name');
```

To kill all of them, use the `names` list:

```dart
for (String name in worker.names) worker.kill(name);
```
