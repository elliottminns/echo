import CUV
import Foundation

enum FileSystemError: ErrorProtocol {
    case CouldNotOpenFile
}

class ReadFileOperation {
    
    let path: String
    
    let buf: UnsafeMutablePointer<uv_buf_t>
    
    let numBufs: UInt32

    let bufferSize: Int
    
    var data: Data
    
    var openedFile: UnsafeMutablePointer<uv_fs_t>
    
    var identifier: Int = 0

    var callback: ((data: Data?, error: ErrorProtocol?) -> ())?

    init(identifier: Int, path: String) {
        self.identifier = identifier
        self.path = path
        self.data = Data(bytes: [])
        self.numBufs = 1
        self.bufferSize = 16386
        self.buf = UnsafeMutablePointer<uv_buf_t>(allocatingCapacity: Int(numBufs))
        self.openedFile = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        loadBuffers()
    }
    
    func loadBuffers() {
        for i in 0 ..< numBufs {
            let buffer = UnsafeMutablePointer<Int8>(allocatingCapacity: bufferSize)
            buf.advanced(by: Int(i)).pointee = uv_buf_t(base: buffer, len: bufferSize)
        }
    }
    
    deinit {
        openedFile.deallocateCapacity(1)
        
        for i in 0 ..< numBufs {
            buf.advanced(by: Int(i)).pointee.base.deallocateCapacity(bufferSize)
        }
        
    }
}

extension ReadFileOperation {
    
    func start(callback: (data: Data?, error: ErrorProtocol?) -> ()) {
        self.callback = callback
        open(permissions: self.permissions)
    }
    
    func open(permissions: [FileOpenPermissions]) {
        
        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
            
        io.fs_open(uv_default_loop(), fs, path, O_RDONLY, 0) { (req) in
            self.openedFile = fs
            self.read(file: req)
        }
    }
   
    func read(file fsOpen: UnsafeMutablePointer<uv_fs_t>) {
        
        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        
        io.fs_read(uv_default_loop(), fs, Int32(fsOpen.pointee.result), buf, numBufs, Int64(data.bytes.count)) { (req) in
            self.fileRead(req: req)
        }
    }
    
    func close(file fs: UnsafeMutablePointer<uv_fs_t>) {
        
        let req = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        uv_fs_close(uv_default_loop(), req, Int32(fs.pointee.result), nil)
        req.deallocateCapacity(1)
        
        callback?(data: data, error: nil)
        callback = nil
    }
}

extension ReadFileOperation: Hashable {

    var hashValue: Int {
        return identifier
    }
    
    var permissions: [FileOpenPermissions] {
        return [.Read]
    }
    
    func fileOpened(req: UnsafeMutablePointer<uv_fs_t>) {
        openedFile = req
        read(file: req)
    }
    
    func fileOpenFailed() {
        callback?(data: nil, error: FileSystemError.CouldNotOpenFile)
        callback = nil
    }
    
    func fileRead(req: UnsafeMutablePointer<uv_fs_t>) {
        
        var size = req.pointee.result
        
        var buffersRead: UInt32 = 0
        
        var buffer = buf
        
        while size > 0 {
            
            let length = min(bufferSize, size)
            
            data.append(buffer.pointee.base, length: length)
            
            buffer = buffer.successor()
            size -= bufferSize
            buffersRead += 1
        }
        
        if buffersRead < numBufs || size % bufferSize != 0 {
            close(file: openedFile)
        } else {
            read(file: openedFile)
        }
        
    }

}

func ==(lhs: ReadFileOperation, rhs: ReadFileOperation) -> Bool {
    return lhs.identifier == rhs.identifier
}