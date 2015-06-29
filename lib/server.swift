/**
 * File: server.swift
 * Desc: Basic HTTP server functionality.
 * Auth: Cezary Wojcik
 */

// ---- [ includes ] ----------------------------------------------------------

include "lib/socket.swift"
include "lib/http.swift"

// ---- [ server class ] ------------------------------------------------------

class Server {
    let sock : Socket

    // ---- [ setup ] ---------------------------------------------------------

    init(host : String = "0.0.0.0", port : Int) {
        sock = Socket(host: host, port: port)
    }

    // ---- [ instance methods ] ----------------------------------------------

    func run(closure : (request : HTTPRequest,
        response : HTTPResponse) -> ()) {
        while true {
            // get client socket
            guard let cs = sock.acceptClientSocket() else {
                print("acceptClientSocket() failed.")
                continue
            }

            // get request
            let request = HTTPRequest(cs: cs)

            // create response
            let response = HTTPResponse(cs: cs)

            // run closure
            closure(request: request, response: response)
        }
    }
}
