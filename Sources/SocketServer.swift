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

import Foundation

#if os(Linux)
    import Glibc
#endif

public protocol SocketServerDelegate: class {
    func socketServer(socketServer: SocketServer,
                      didRecieveRequestOnSocket socket: Socket)
}

public class SocketServer {

    public let socketManager: SocketManager

    private var listenSocket: Socket = Socket(rawSocket: -1)

    private var clientSockets: Set<Socket> = []

    private var clientSocketsLock = NSLock()

    private var queue: dispatch_queue_t

    public weak var delegate: SocketServerDelegate?

    public init() {
        socketManager = SocketManager()
        queue = dispatch_queue_create("blackfish.queue.request", DISPATCH_QUEUE_CONCURRENT)
    }

    public func start(listenPort: Int) throws {

        self.stop()

        self.listenSocket = try socketManager.createListenSocket(listenPort)

        dispatch_async(self.queue) {

            while let socket = try? self.listenSocket.acceptClientSocket() {

                self.lock(self.clientSocketsLock) {
                    self.clientSockets.insert(socket)
                }

                dispatch_async(self.queue) {
                    self.handleConnection(socket)
                    self.lock(self.clientSocketsLock) {
                        self.clientSockets.remove(socket)
                    }
                }
            }

            self.stop()
        }
    }

    public func loop() {
        Echo.beginEventLoop()
    }

    public func handleConnection(socket: Socket) {
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.socketServer(self, didRecieveRequestOnSocket: socket)
        }
    }

    public func stop() {

        self.listenSocket.release()

        self.lock(self.clientSocketsLock) {
            for socket in self.clientSockets {
                socket.release()
            }
            self.clientSockets.removeAll(keepCapacity: true)
        }
    }

    private func lock(handle: NSLock, closure: () -> ()) {
        handle.lock()
        closure()
        handle.unlock();
    }
}
