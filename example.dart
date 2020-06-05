/*
 * Copyright (C) 2020 DEÁK JAHN Gábor.
 * All rights reserved.
 */

final worker = BackgroundWorker();
int counter = 0;

void main() {
  // Start the worker/isolate at the `entryPoint` function.
  worker.spawn<int>(entryPoint,
    name: "counter",
    // Executed every time data is received from the spawned worker/isolate.
    onReceive: setCounter,
    // Executed once when spawned worker/isolate is ready for communication.
    onInitialized: () => isolates.send(counter, to: "counter")
  );
}

// Set new count and display current count.
void setCounter(int count) {
  counter = count;
  print("Counter is now $counter");
  
  // We will no longer be needing the worker/isolate, let's dispose of it.
  worker.kill("counter");
}

// This function happens in the worker/isolate.
void entryPoint(String name) {
  // Triggered every time data is received from the main app.
  worker.listen((count) {
    // Add one to the count and send the new value back to the main app.
    worker.send(name, ++count);
  }, name: name);
}
