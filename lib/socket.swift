/**
 * File: socket.swift
 * Desc: Low-level wrappers around POSIX socket APIs.
 * Auth: Cezary Wojcik
 */

// ---- [ imports ] -----------------------------------------------------------

import Darwin

// ---- [ includes ] ----------------------------------------------------------

include "lib/utils.swift" // for fatalError(...)

// ---- [ client socket class ] -----------------------------------------------

class ClientSocket {
    let cs : Int32
    var next = -1

    // ---- [ setup ] ---------------------------------------------------------

    init?(socket : Int32) {
        // buffer for client socket
        var len : socklen_t = 0
        var aaddr = sockaddr(sa_len: 0, sa_family: 0,
            sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        // accept client socket
        cs = accept(socket, &aaddr, &len)
        guard cs != -1 else {
            print("accept(...) failed.")
            return nil
        }
        // no sig pipe
        var nosigpipe : Int32 = 1
        setsockopt(cs, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe,
            socklen_t(sizeof(Int32)))
    }

    deinit {
        close(cs)
    }

    // ---- [ instance methods ] ----------------------------------------------

    // get client IP
    func clientAddress() -> String? {
        var addr = sockaddr(), len: socklen_t = socklen_t(sizeof(sockaddr))
        guard getpeername(cs, &addr, &len) == 0 else {
            print("getpeername(...) failed.")
            return nil
        }
        var hostBuffer = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
        guard getnameinfo(&addr, len, &hostBuffer, socklen_t(hostBuffer.count),
            nil, 0, NI_NUMERICHOST) == 0 else {
            print("getnameinfo(...) failed.")
            return nil
        }
        return String.fromCString(hostBuffer)
    }

    // fetch next byte from client socket
    func nextByte() -> Int {
        var buffer = [UInt8](count: 1, repeatedValue: 0)
        next = recv(cs, &buffer, Int(buffer.count), 0)
        return Int(buffer[0])
    }

    // fetch next line from client socket
    func nextLine() -> String? {
        var line = ""
        var n = 0
        repeat {
            n = nextByte()
            line.append(Character(UnicodeScalar(n)))
        } while n > 0 && n != 10 // until either error or newline
        guard n > 0 && !line.isEmpty else {
            return nil
        }
        return line
    }

    // fetch full request from client socket
    func fetchRequest() -> [String] {
        var request : [String] = []
        var line : String?
        while line != "\r\n" { // until empty newline
            line = self.nextLine()
            // TODO: figure out why guard line = self.nextLine() doesn't work
            guard line != nil else {
                break
            }
            request.append(line!)
        }
        return request
    }

    // send response UTF8
    func sendResponse(response : String) {
        var responseData = [UInt8](response.utf8)
        var sent = 0
        while sent < responseData.count {
            let s = send(cs, &responseData + sent,
                responseData.count - sent, 0)
            guard s > 0 else {
                print("send(...) failed.")
                break
            }
            sent += s
        }
    }
}

// ---- [ socket class ] ------------------------------------------------------

class Socket {
    let s : Int32

    // ---- [ setup ] ---------------------------------------------------------

    init(host : String, port : Int) {
        // create socket that clients can connect to
        s = socket(AF_INET, SOCK_STREAM, Int32(0))
        guard self.s != -1 else {
            fatalError("socket(...) failed.")
        }

        // set socket options
        var value : Int32 = 1;
        guard setsockopt(self.s, SOL_SOCKET, SO_REUSEADDR, &value,
            socklen_t(sizeof(Int32))) != -1 else {
            fatalError("setsockopt(...) failed.")
        }

        // bind socket to host and port
        var addr = sockaddr_in(sin_len: __uint8_t(sizeof(sockaddr_in)),
            sin_family: sa_family_t(AF_INET),
            sin_port: Socket.porthtons(in_port_t(port)),
            sin_addr: in_addr(s_addr: inet_addr(host)),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        var saddr = sockaddr(sa_len: 0, sa_family: 0,
            sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        memcpy(&saddr, &addr, Int(sizeof(sockaddr_in)))
        guard bind(self.s, &saddr, socklen_t(sizeof(sockaddr_in))) != -1 else {
            fatalError("bind(...) failed.")
        }

        // begin listening on the socket
        guard listen(s, 20) != -1 else {
            fatalError("listen(...) failed.")
        }
    }

    // ---- [ instance methods ] ----------------------------------------------

    func acceptClientSocket() -> ClientSocket? {
        return ClientSocket(socket: s)
    }

    // ---- [ static methods ] ------------------------------------------------

    private static func porthtons(port: in_port_t) -> in_port_t {
        let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return isLittleEndian ? _OSSwapInt16(port) : port
    }
}
