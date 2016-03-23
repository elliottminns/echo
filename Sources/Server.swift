
import CUV

enum ServerError: ErrorProtocol {
    case ListenError
}

internal func uv_connection_cb(request: UnsafeMutablePointer<uv_stream_t>, status: Int32) {
    let data = request.pointee.data
    let server = unsafeBitCast(data, to: Server.self)
    server.handleConnection(request)
}

public protocol ServerDelegate: class {
    func server(server: Server, didRecieveConnection connection: Connection)
}

public final class Server {
    
    var tcp: UnsafeMutablePointer<uv_tcp_t>
    
    var bind_addr: UnsafeMutablePointer<sockaddr_in>
    
    public weak var delegate: ServerDelegate?
    
    var connections: Set<Connection>
    
    var currentIdentifier: Int
    
    public init() {
        tcp = UnsafeMutablePointer<uv_tcp_t>(allocatingCapacity: 1)
        bind_addr = UnsafeMutablePointer<sockaddr_in>(allocatingCapacity: 1)
        connections = []
        currentIdentifier = 0
        tcp.pointee.data = unsafeBitCast(self,
                                         to: UnsafeMutablePointer<Void>.self)
        
    }
    
    deinit {
        tcp.deinitialize(count: 1)
        bind_addr.deinitialize(count: 1)
    }
    
    public func listen(port: Int, handler: (error: ErrorProtocol?) -> ()) {
        
        uv_ip4_addr([Int8(0),Int8(0),Int8(0),Int8(0)], Int32(port), bind_addr)
        
        uv_tcp_init(uv_default_loop(), tcp)
        
        uv_tcp_bind(tcp, UnsafePointer<sockaddr>(bind_addr), 0)
        
        let stream = UnsafeMutablePointer<uv_stream_t>(tcp)
        
        let result = uv_listen(stream, 1000, uv_connection_cb)
        
        guard result == 0 else {
            handler(error: ServerError.ListenError)
            return
        }
        
        handler(error: nil)
        
        uv_run(uv_default_loop(), UV_RUN_DEFAULT)
    }
    
    public func handleConnection(stream: UnsafeMutablePointer<uv_stream_t>) {
        let connection = Connection(connection: stream, delegate: self, identifier: currentIdentifier)
        currentIdentifier += 1
        connections.insert(connection)
        do {
            try connection.beginRead()
        } catch {
            connections.remove(connection)
        }
    }
}

extension Server: ConnectionDelegate {
    
    func connection(connection: Connection, didReadData data: Data) {
        self.delegate?.server(self, didRecieveConnection: connection)
    }
    
    func connectionDidFinish(connection: Connection) {
        connections.remove(connection)
    }
}
