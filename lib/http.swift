/**
 * File: http.swift
 * Desc: Various HTTP constructs.
 * Auth: Cezary Wojcik
 */

// ---- [ structs ] -----------------------------------------------------------

struct HTTPRequest {
    let raw : String
}

struct HTTPResponse {
    let cs : ClientSocket

    func sendRaw(message : String) {
        cs.sendResponse(message)
    }
}
