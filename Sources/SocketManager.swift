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
import Darwin
#endif


public class SocketManager {

    func createListenSocket(port: Int,
        pendingConnectionCount: Int32 = SOMAXCONN) throws -> Socket {

        let port = UInt16(port)

        #if os(Linux)
            let socketStream = Int32(SOCK_STREAM.rawValue)
        #else
            let socketStream = SOCK_STREAM
        #endif

        let rawSocket = socket(AF_INET, socketStream, 0)

        if rawSocket == -1 {
            throw SocketError.SocketCreationFailed(Socket.descriptionOfLastError())
        }

        var value: Int32 = 1

        if setsockopt(rawSocket, SOL_SOCKET, SO_REUSEADDR,
            &value, socklen_t(sizeof(Int32))) == -1 {
                let details = Socket.descriptionOfLastError()
                SocketManager.closeRawSocket(rawSocket)
                throw SocketError.SocketSettingReUseAddrFailed(details)
        }

        Socket.setNoSigPipe(rawSocket)

        var socketAddress = sockaddr_in()
        socketAddress.sin_family = sa_family_t(AF_INET)
        socketAddress.sin_port = Socket.htonsPort(port)
        #if os(Linux)
            socketAddress.sin_addr = in_addr(s_addr: in_addr_t(0))
        #else
            socketAddress.sin_len = __uint8_t(sizeof(sockaddr_in))
            socketAddress.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        #endif

        socketAddress.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)

        var bindAddress = sockaddr()

        memcpy(&bindAddress, &socketAddress, Int(sizeof(sockaddr_in)))

        if bind(rawSocket, &bindAddress, socklen_t(sizeof(sockaddr_in))) == -1 {
            let details = Socket.descriptionOfLastError()
            SocketManager.closeRawSocket(rawSocket)
            throw SocketError.BindFailed(details)
        }

        if listen(rawSocket, pendingConnectionCount ) == -1 {
            let details = Socket.descriptionOfLastError()
            SocketManager.closeRawSocket(rawSocket)
            throw SocketError.ListenFailed(details)
        }

        return Socket(rawSocket: rawSocket)

    }

    class func closeSocket(socket: Socket) {
        closeRawSocket(socket.rawSocket)
    }

    class func shutdownSocket(socket: Socket) {
        shutdownRawSocket(socket.rawSocket)
    }

    class func closeRawSocket(socket: Int32) {
        SocketManager.shutdownRawSocket(socket)
        close(socket)
    }

    class func shutdownRawSocket(socket: Int32) {
        #if os(Linux)
            shutdown(socket, Int32(SHUT_RDWR))
        #else
            Darwin.shutdown(socket, SHUT_RDWR)
        #endif
    }

}
