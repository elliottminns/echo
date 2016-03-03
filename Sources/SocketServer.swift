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
