
#if os(Linux)
import Glibc
#else
import Darwin
#endif

enum SocketError: ErrorProtocol {
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
            return systemSockStream
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
    
    init(type: SocketType = .TCP) throws {
        
        let fd = socket(AF_INET, type.sockValue, 0)
        try self.init(raw: fd, type: type)
    }
    
    func shutdown() {
        
        systemClose(raw)
        systemShutdown(raw, systemSHUT_RDWR)
        
    }
}
