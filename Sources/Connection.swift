import CUV

enum ConnectionError: ErrorType {
    case CouldNotAccept
}

func alloc_buffer(handle: UnsafeMutablePointer<uv_handle_t>, size: size_t, buffer: UnsafeMutablePointer<uv_buf_t>) {
    buffer.memory = uv_buf_init(UnsafeMutablePointer<Int8>.alloc(size), UInt32(size))
}

func read_callback(stream: UnsafeMutablePointer<uv_stream_t>, size: Int, buffer: UnsafePointer<uv_buf_t>) {
    let data = stream.memory.data
    let callback = unsafeBitCast(data, ConnectionCallback.self)
    var connection = callback.connection
    connection.read(stream, size: size, buffer: buffer)
}

class ConnectionCallback {
    
    let connection: Connection
    
    init(connection: Connection) {
        self.connection = connection
    }
    
}

public struct Connection {
    
    var client: UnsafeMutablePointer<uv_tcp_t>
    
    public var data: Data
    
    init(connection: UnsafeMutablePointer<uv_stream_t>) throws {
        
        client = UnsafeMutablePointer<uv_tcp_t>.alloc(1)
        
        data = Data(bytes: [])
        
        let callback = ConnectionCallback(connection: self)
        
        client.memory.data = unsafeBitCast(callback, UnsafeMutablePointer<Void>.self)
        
        uv_tcp_init(uv_default_loop(), client)
        
        let stream = UnsafeMutablePointer<uv_stream_t>(client)
        
        guard uv_accept(connection, stream) == 0 else {
            uv_close(UnsafeMutablePointer<uv_handle_t>(stream), nil)
            throw ConnectionError.CouldNotAccept
        }
        
        uv_read_start(stream, alloc_buffer, read_callback)
    }
    
    mutating func read(stream: UnsafeMutablePointer<uv_stream_t>, size: Int, buffer: UnsafePointer<uv_buf_t>) {
        data.append(buffer.memory.base, length: size)
        print(try? data.toString())
    }
}