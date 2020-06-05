# Flutter Isolate Web

The title is a misnomer. Of course, there are no isolates in Flutter Web. What this code provides
is actually a unified interface to isolates *and* web workers so that each platform can use its own.
It's not a package on pub.dev and it won't be because you can't use it out of the box just like
a regular package or plugin. You have to copy it into your own code and modify it in a few places.

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
  _start,
  name: 'some-unique-name',
  onInitialized: onInitialized,
  onReceive: onReceive,
);
```

You can start any amount of workers, just give a unique name to all so that you can reference them later when sending
or receiving messages.

`_start()` is just a function taking a `String` argument (the unique name of the isolate/worker). Unlike with standard isolates,
there is no limitation for it to be a top-level or static function, anything will do, even an inline anonymous one.
The most usual activity here is to start listening to messages the isolate/worker will receive from the main app
(the actual message structure is completely up to you, this is just an example):

```dart
void _start(String name) {
  worker.listen((args) {
    switch (args['command']) {
      case 'start':
        // worker starts its job
        break;
    }
  }, name: name);
}
```

When the isolate/worker actually gets initialized, we will also receive an event. You might simply use this to send
a message to the worker to start the actual work (the actual message structure is completely up to you, this is just an example):

```dart
void onInitialized() {
  worker.send('some-unique-name', {
    // tell the worker to start its job
    'command': 'start',
    'data': ...,
  });
}
```

`onReceive` is the main messaging mechanism. Pass the `worker` and the unique name to the isolate/worker so that it can store it
and send its messages back:

```dart
worker.send('unique-name', message);

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
