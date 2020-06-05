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
