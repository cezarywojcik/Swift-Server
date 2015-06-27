/**
 * File: utils.swift
 * Desc: Some utility functions
 * Auth: Cezary Wojcik
 */

// ---- [ helper functions ] --------------------------------------------------

@noreturn func handleError(message : String) {
  print(message)
  let errorCode = errno
  guard let errorText = String.fromCString(UnsafePointer(strerror(errorCode)))
    else {
    print("\(errorCode): Unknown error.")
    exit(2)
  }
  print("\(errorCode): \(errorText)")
  exit(2)
}

func porthtons(port: in_port_t) -> in_port_t {
  let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
  return isLittleEndian ? _OSSwapInt16(port) : port
}

func peername(socket: CInt) -> String? {
  var addr = sockaddr(), len: socklen_t = socklen_t(sizeof(sockaddr))
  guard getpeername(socket, &addr, &len) == 0 else {
    handleError("getpeername(...) failed.")
  }
  var hostBuffer = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
  guard getnameinfo(&addr, len, &hostBuffer, socklen_t(hostBuffer.count), nil,
      0, NI_NUMERICHOST) == 0  else {
    handleError("getnameinfo(...) failed.")
  }
  return String.fromCString(hostBuffer)
}
