/**
 * File: main.swift
 * Desc: Currently testing a basic HTTP server using Swift
 * Auth: Cezary Wojcik
 */

// ---- [ includes ] ----------------------------------------------------------

include "settings.swift"
include "lib/server.swift"

// ---- [ server setup ] ------------------------------------------------------

let app = Server(port: port)

app.run() {
    request, response -> () in
    print(request.raw)
    response.sendRaw("HTTP/1.1 200 OK\n\nHello, World!\n")
}
