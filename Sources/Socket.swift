/*
Copyright (c) 2014, Damian Kołakowski
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the {organization} nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

public enum SocketType {
    case TCP
    case UDP
}

public enum SocketError: ErrorType {
    case SocketCreationFailed(String)
    case SocketSettingReUseAddrFailed(String)
    case BindFailed(String)
    case ListenFailed(String)
    case WriteFailed(String)
    case GetPeerNameFailed(String)
    case ConvertingPeerNameFailed
    case GetNameInfoFailed(String)
    case AcceptFailed(String)
    case RecvFailed(String)

    public var errorMessage: String? {
        switch self {
        case let .SocketCreationFailed(message):
            return message
        case let .SocketSettingReUseAddrFailed(message):
            return message
        case let .BindFailed(message):
            return message
        case let .ListenFailed(message):
            return message
        case let .WriteFailed(message):
            return message
        case let .GetPeerNameFailed(message):
            return message
        case let .GetNameInfoFailed(message):
            return message
        case let .AcceptFailed(message):
            return message
        case let .RecvFailed(message):
            return message
        default:
            return nil
        }
    }
}

public struct Socket {

    public let rawSocket: Int32

    var peerName: String?

    public init(rawSocket: Int32) {
        self.rawSocket = rawSocket
    }

    public func release() {
        SocketManager.closeRawSocket(rawSocket)
    }

    public func shutdown() {
        SocketManager.shutdownRawSocket(rawSocket)
    }

    public func acceptClientSocket() throws -> Socket {
        var addr = sockaddr()
        var len: socklen_t = 0
        let clientSocket = accept(rawSocket, &addr, &len)
        if clientSocket == -1 {
            throw SocketError.AcceptFailed(Socket.descriptionOfLastError())
        }
        Socket.setNoSigPipe(clientSocket)
        return Socket(rawSocket: clientSocket)
    }

    public func writeString(string: String) throws {
        let data = Data(string: string)
        try writeData(data)
    }

    public func writeData(data: Data) throws {
        try data.bytes.withUnsafeBufferPointer {

            var sent = 0

            while sent < data.bytes.count {

                #if os(Linux)
                    let s = send(self.rawSocket,
                        $0.baseAddress + sent, Int(data.size - sent),
                        Int32(MSG_NOSIGNAL))
                #else
                    let s = write(self.rawSocket,
                        $0.baseAddress + sent, Int(data.size - sent))
                #endif

                if s <= 0 {
                    throw SocketError.WriteFailed(Socket.descriptionOfLastError())
                }
                sent += s
            }
        }
    }

    public func read() throws -> UInt8 {
        var buffer = [UInt8](count: 1, repeatedValue: 0)
        let next = recv(self.rawSocket as Int32, &buffer, Int(buffer.count), 0)
        if next <= 0 {
            throw SocketError.RecvFailed(Socket.descriptionOfLastError())
        }
        return buffer[0]
    }

    private static let CR = UInt8(13)

    private static let NL = UInt8(10)

    public func readLine() throws -> String {
        var characters: String = ""
        var n: UInt8 = 0
        repeat {
            n = try self.read()
            if n > Socket.CR { characters.append(Character(UnicodeScalar(n))) }
        } while n != Socket.NL
        return characters
    }

    public func peername() throws -> String {

        var addr = sockaddr(), len: socklen_t = socklen_t(sizeof(sockaddr))

        if getpeername(self.rawSocket, &addr, &len) != 0 {
            throw SocketError.GetPeerNameFailed(Socket.descriptionOfLastError())
        }

        var hostBuffer = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)

        if getnameinfo(&addr, len, &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NUMERICHOST) != 0 {
            throw SocketError.GetNameInfoFailed(Socket.descriptionOfLastError())
        }

        guard let name = String.fromCString(hostBuffer) else {
            throw SocketError.ConvertingPeerNameFailed
        }

        return name
    }

    public static func descriptionOfLastError() -> String {
        return String.fromCString(UnsafePointer(strerror(errno))) ?? "Error: \(errno)"
    }

    public static func setNoSigPipe(socket: Int32) {
        #if os(Linux)
            // There is no SO_NOSIGPIPE in Linux (nor some other systems). You can instead use the MSG_NOSIGNAL flag when calling send(),
            // or use signal(SIGPIPE, SIG_IGN) to make your entire application ignore SIGPIPE.
        #else
            // Prevents crashes when blocking calls are pending and the app is paused ( via Home button ).
            var no_sig_pipe: Int32 = 1
            setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(sizeof(Int32)))
        #endif
    }

    public static func htonsPort(port: in_port_t) -> in_port_t {
        #if os(Linux)
            return port.bigEndian //use htons(). LLVM Crash currently
        #else
            let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
            return isLittleEndian ? _OSSwapInt16(port) : port
        #endif
    }
}

extension Socket: Hashable {

    public var hashValue: Int {

        return Int(self.rawSocket)
    }
}

extension Socket: Equatable {
}

public func ==(socket1: Socket, socket2: Socket) -> Bool {
    return socket1.rawSocket == socket2.rawSocket
}
