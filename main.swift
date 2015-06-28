/**
 * File: main.swift
 * Desc: Currently testing a basic HTTP server using Swift
 * Auth: Cezary Wojcik
 */

// ---- [ imports ] -----------------------------------------------------------

import Darwin

// ---- [ includes ] ----------------------------------------------------------

include "settings.swift"
include "lib/socket.swift"

// ---- [ server setup ] ------------------------------------------------------

// create server socket (host and port from settings.swift)
let sock = Socket(host: host, port: port)

while true {
    // get client socket
    guard let cs = sock.acceptClientSocket() else {
        print("acceptClientSocket() failed.")
        continue
    }

    // get and display client address
    guard let clientAddress = cs.clientAddress() else {
        print("clientAddress() failed.")
        continue
    }
    print("Client IP: \(clientAddress)")

    // get and display request
    let request = cs.fetchRequest()
    print(request)

    // send response
    cs.sendResponse("HTTP/1.1 200 OK\n\nHello, World!\n")
}
