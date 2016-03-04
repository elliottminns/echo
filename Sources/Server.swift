
import CUV

enum ServerError: ErrorType {
    case ListenError
}

internal func uv_connection_cb(request: UnsafeMutablePointer<uv_stream_t>, status: Int32) {
    let data = request.memory.data
    let server = unsafeBitCast(data, Server.self)
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
        tcp = UnsafeMutablePointer<uv_tcp_t>.alloc(1)
        bind_addr = UnsafeMutablePointer<sockaddr_in>.alloc(1)
        connections = []
        currentIdentifier = 0
        tcp.memory.data = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        
    }
    
    deinit {
        tcp.destroy()
        bind_addr.destroy()
    }
    
    public func listen(port: Int, handler: (error: ErrorType?) -> ()) {
        
        uv_tcp_init(uv_default_loop(), tcp)
        
        uv_ip4_addr("0.0.0.0", Int32(port), bind_addr)
        
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
    
    func connection(connection: Connection, didReadData: Data) {
        self.delegate?.server(self, didRecieveConnection: connection)
    }
    
    func connectionDidFinish(connection: Connection) {
        connections.remove(connection)
    }
}