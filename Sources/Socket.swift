
import Darwin

enum SocketError: ErrorType {
    case NoFileDescriptor
    case CouldNotBind
    case CouldNotListen
}

public enum SocketType {
    case TCP
}

extension SocketType {
    var sockValue: Int32 {
        switch self {
        case TCP:
            return SOCK_STREAM
        }
    }
}

struct Socket {
    
    var type: SocketType
    
    var raw: Int32
    
    init(raw: Int32, type: SocketType = .TCP) throws {
        
        let flags = fcntl(raw, F_GETFL, 0)
        let status = fcntl(raw, F_SETFL, flags | O_NONBLOCK);
        
        if raw < 0 {
            throw SocketError.NoFileDescriptor
        }
        
        if status < 0 {
            close(raw)
            throw SocketError.NoFileDescriptor
        }
        
        self.raw = raw
        self.type = type
    }
    
    init() throws {
        
        let fd = socket(AF_INET, SOCK_STREAM, 0)
        try self.init(raw: fd)
    }
    
    func shutdown() {
        
        Darwin.close(raw)
        Darwin.shutdown(raw, SHUT_WR)
        
    }
}