/**
 * File: main.swift
 * Desc: Currently testing a basic HTTP server using Swift
 * Auth: Cezary Wojcik
 */

// ---- [ imports ] -----------------------------------------------------------

import Darwin

// ---- [ includes ] ----------------------------------------------------------

include "settings.swift"
include "utils.swift"

// ---- [ testing ] -----------------------------------------------------------

// create socket that clients can connect to
let s = socket(AF_INET, SOCK_STREAM, 0)
guard s != -1 else {
    handleError("socket(...) failed.")
}

// set socket options
var value: Int32 = 1;
guard setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(sizeof(Int32)))
    != -1 else {
    handleError("setsockopt(...) failed.")
}

// bind socket to host and port (definded in settings.swift)
var addr = sockaddr_in(sin_len: __uint8_t(sizeof(sockaddr_in)),
    sin_family: sa_family_t(AF_INET), sin_port: porthtons(in_port_t(port)),
    sin_addr: in_addr(s_addr: inet_addr(host)),
    sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
var saddr = sockaddr(sa_len: 0, sa_family: 0,
    sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
memcpy(&saddr, &addr, Int(sizeof(sockaddr_in)))
guard bind(s, &saddr, socklen_t(sizeof(sockaddr_in))) != -1 else {
    handleError("bind(...) failed.")
}

// begin listening on the socket
guard listen(s, 20) != -1 else {
    handleError("listen(...) failed.")
}

// buffer for client socket
var len : socklen_t = 0
var aaddr = sockaddr(sa_len: 0, sa_family: 0,
    sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))

// create response
var response = "HTTP/1.1 200 OK\n\nHello, World!\n"
var responseData = [UInt8](response.utf8)

while true {
    // accept client socket
    let cs = accept(s, &aaddr, &len)
    guard cs != -1 else {
        print("accept(...) failed.")
        continue
    }
    // get client address
    if let socketAddress = peername(cs) {
        print("Client Address: \(socketAddress)")
    }
    // collect request, then display it
    var request = ""
    var next = 1
    var last : UInt8 = 0
    while next > 0 {
        var buffer = [UInt8](count: 1, repeatedValue: 0)
        next = recv(Int32(cs), &buffer, Int(buffer.count), 0)
        request.append(Character(UnicodeScalar(buffer[0])))
        // we'll take two newlines to mean end of message
        if last == 10 && buffer[0] == 13 {
            request.append(Character(UnicodeScalar(10)))
            break
        }
        last = buffer[0]
    }
    print(request)
    // send response
    var sent = 0
    while sent < responseData.count {
        let s = send(cs, &responseData + sent, responseData.count - sent, 0)
        guard s > 0 else {
            print("send(...) failed.")
            break
        }
        sent += s
    }
    // reset
    request = ""
    close(cs)
}
