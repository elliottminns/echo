import CUV
import Foundation

protocol ReadFileOperationDelegate: class {
    func operation(operation: ReadFileOperation, didCompleteWithData data: Data)
}

class ReadFileOperation {
    
    let path: String
    
    var buffer: UnsafeMutablePointer<Int8>

    let bufferSize: Int
    
    var data: Data
    
    var openFs: UnsafeMutablePointer<uv_fs_t>
    
    var id: Int = 0

    weak var delegate: ReadFileOperationDelegate?

    init(identifier: Int, path: String, delegate: ReadFileOperationDelegate) {
        self.id = identifier
        self.path = path
        self.data = Data(bytes: [])
        let size = 65536
        self.bufferSize = size
        self.buffer = UnsafeMutablePointer<Int8>(allocatingCapacity: size)
        self.openFs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        self.delegate = delegate
    }
    
    deinit {
        self.buffer.deallocateCapacity(self.bufferSize)
    }
}

extension ReadFileOperation {
    
    func start() {
        open(permissions: self.permissions)
    }
    
    func open(permissions: [FileOpenPermissions]) {
        
        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        
        fs.pointee.data = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        
        #if os(Linux)
            let cPath = path.cStringUsingEncoding(NSUTF8StringEncoding)
        #else
            let cPath = path.cString(using: NSUTF8StringEncoding)
        #endif
        
        if let p = cPath {
            uv_fs_open(uv_default_loop(), fs, p, O_RDONLY, 0, fs_open_callback)
        }
    }
    
    func read(file fsOpen: UnsafeMutablePointer<uv_fs_t>) {
        
        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        
        fs.pointee.data = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        
//        let buffer = UnsafeMutablePointer<uv_buf_t>(allocatingCapacity: 1024)
        
//        buffer.pointee = uv_buf_t(base: self.buffer, len: self.bufferSize)
        
        var buf = uv_buf_init(self.buffer, UInt32(self.bufferSize))
        
        uv_fs_read(uv_default_loop(),
                   fs,
                   Int32(fsOpen.pointee.result),
                   &buf,
                   1,
                   Int64(self.data.bytes.count),
                   fs_read_callback)
    }
    
    func close(file fs: UnsafeMutablePointer<uv_fs_t>) {
        
        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        
        fs.pointee.data = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        
        uv_fs_close(uv_default_loop(), fs, fs.pointee.file, nil)
        
        self.delegate?.operation(operation: self, didCompleteWithData: data)
    }
}

extension ReadFileOperation: FileOperation {

    var hashValue: Int {
        return id
    }
    
    var permissions: [FileOpenPermissions] {
        return [.Read]
    }
    
    func fileOpened(req: UnsafeMutablePointer<uv_fs_t>) {
        openFs = req
        read(file: req)
    }
    
    func fileOpenFailed() {
        
    }
    
    func fileRead(req: UnsafeMutablePointer<uv_fs_t>) {
        
        let size = req.pointee.result
            
        if size <= bufferSize {
            data.append(buffer, length: size)
        }
        
        if size != bufferSize {
            close(file: openFs)
        } else {
            read(file: openFs)
        }
        
    }
    
    func fileClosed(req: UnsafeMutablePointer<uv_fs_t>) {
        
    }
    
    func fileOpenFailed(req: UnsafeMutablePointer<uv_fs_t>) {
        
    }
}

func ==(lhs: ReadFileOperation, rhs: ReadFileOperation) -> Bool {
    return lhs.id == rhs.id
}