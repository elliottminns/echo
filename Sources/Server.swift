
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
    func didRecieveConnection(connection: Connection)
}

public final class Server {
    
    var tcp: UnsafeMutablePointer<uv_tcp_t>
    
    var bind_addr: UnsafeMutablePointer<sockaddr_in>
    
    unowned let delegate: ServerDelegate
    
    public init(delegate: ServerDelegate) {
        tcp = UnsafeMutablePointer<uv_tcp_t>.alloc(1)
        bind_addr = UnsafeMutablePointer<sockaddr_in>.alloc(1)
        self.delegate = delegate
        tcp.memory.data = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
    }
    
    deinit {
        tcp.destroy()
        bind_addr.destroy()
    }
    
    public func listen(port: Int) throws {
        
        uv_tcp_init(uv_default_loop(), tcp)
        
        uv_ip4_addr("0.0.0.0", Int32(port), bind_addr)
        
        uv_tcp_bind(tcp, UnsafePointer<sockaddr>(bind_addr), 0)
        
        let stream = UnsafeMutablePointer<uv_stream_t>(tcp)
        
        let result = uv_listen(stream, 1000, uv_connection_cb)
        
        guard result == 0 else {
            throw ServerError.ListenError
        }
        
        uv_run(uv_default_loop(), UV_RUN_DEFAULT)
    }
    
    public func handleConnection(stream: UnsafeMutablePointer<uv_stream_t>) {
        do {
            let connection = try Connection(connection: stream)
            self.delegate.didRecieveConnection(connection)
        } catch {
            
        }
    }
}