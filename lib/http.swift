/**
 * File: http.swift
 * Desc: Various HTTP constructs.
 * Auth: Cezary Wojcik
 */

// ---- [ includes ] ----------------------------------------------------------

include "lib/utils.swift" // for String extension

// ---- [ structs ] -----------------------------------------------------------

struct HTTPRequest {
    let cs : ClientSocket
    let raw : String
    let rawHeaders : [String : String]

    // ---- [ setup ] ---------------------------------------------------------

    init(cs : ClientSocket) {
        // temp vars so that struct members can be constant
        var tempRaw = ""
        var tempRawHeaders : [String : String] = [:]

        // get request data
        self.cs = cs
        let lines = cs.fetchRequest()

        // parse request headers
        for i in 1..<lines.count {
            let index = lines[i].indexOf(":")
            guard index != -1 else {
                continue
            }
            let headerName = lines[i][0..<index]
            let headerContent = lines[i][index+1..<lines[i].characters.count]
            tempRawHeaders[headerName] = headerContent
            tempRaw += lines[i]
        }

        // assign temp vars to the struct members
        raw = tempRaw
        rawHeaders = tempRawHeaders
    }

    // ---- [ instance methods ] ----------------------------------------------

    func clientAddress() -> String? {
        return cs.clientAddress()
    }
}

struct HTTPResponse {
    let cs : ClientSocket

    // ---- [ instance methods ] ----------------------------------------------

    func sendRaw(message : String) {
        cs.sendResponse(message)
    }
}
