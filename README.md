# Swift Server

## Introduction

This is very rough and basic HTTP server written in Swift without using `Foundation`.

This is partially based on the [Swifter](https://github.com/glock45/swifter) repo, however, the point is to eliminate the need for Apple's `Foundation` library to prepare for using Swift on Linux.

This is built using [Swift Script Include](https://github.com/cezarywojcik/Swift-Script-Include) to enable using multiple files for Swift scripts and runs without Xcode purely on the terminal.

## Installation Notes

This is built using Swift 2, and requires your command-line `swift` to be using Swift 2 as well. You can check your Swift version by running `swift --version` in your terminal. If you are running Swift 1.2 instead of 2.0, first, make sure that you have the Xcode 7 beta installed. Next, run the following command:

```
sudo xcode-select -switch /Applications/Xcode-beta.app/Contents/Developer
```

## Running

To run the project, simply type `make run` in the project directory.

Visit [`http://127.0.0.1:3000`](http://127.0.0.1:3000) in your web browser to see a friendly "Hello, World!" message. The HTTP request will be printed in your terminal.

## Example Code

The functionality is currently very basic. The code below shows what the server can currently do.

```
include "lib/server.swift"

let app = Server(port: port)

app.run() {
    request, response -> () in
    print(request.raw)
    response.sendRaw("HTTP/1.1 200 OK\n\nHello, World!\n")
}

```
