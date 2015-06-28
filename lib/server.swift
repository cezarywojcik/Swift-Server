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

            // get and display client address
            guard let clientAddress = cs.clientAddress() else {
                print("clientAddress() failed.")
                continue
            }
            print("Client IP: \(clientAddress)")

            // get request
            let request = HTTPRequest(raw: cs.fetchRequest())

            // create response
            let response = HTTPResponse(cs: cs)

            // run closure
            closure(request: request, response: response)
        }
    }
}
