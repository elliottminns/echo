import CUV
import Foundation

enum FileOpenPermissions {
    case Read
    case Write
}

typealias uv_fs = ImplicitlyUnwrappedOptional<UnsafeMutablePointer<uv_fs_t>>

func fs_open_callback(req: uv_fs) {
    let memory = unsafeBitCast(req.pointee.data, to: ReadFileOperation.self)
    if req.pointee.result >= 0 {
        memory.fileOpened(req: req)
    } else {
        memory.fileOpenFailed(req: req)
    }
}

func fs_read_callback(req: uv_fs) {
    let memory = unsafeBitCast(req.pointee.data, to: ReadFileOperation.self)
    if req.pointee.result >= 0 {
        memory.fileRead(req: req)
    } else {
        memory.fileRead(req: req)
    }
}

func fs_close_callback(req: uv_fs) {
    let memory = unsafeBitCast(req.pointee.data, to: ReadFileOperation.self)
    memory.fileClosed(req: req)
}

protocol FileOperation: class, Hashable {
    
    var id: Int { get set }
    
    var path: String { get }

    var bufferSize: Int { get }
    
    var buffer: UnsafeMutablePointer<Int8> { get set }
    
    var permissions: [FileOpenPermissions] { get }
    
    func fileOpened(req: UnsafeMutablePointer<uv_fs_t>)
    
    func fileOpenFailed(req: UnsafeMutablePointer<uv_fs_t>)

    func fileRead(req: UnsafeMutablePointer<uv_fs_t>)
    
    func fileClosed(req: UnsafeMutablePointer<uv_fs_t>)
    
}

extension ReadFileOperation {
    
    func start(callback: Callback) {
        self.callback = callback
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
        
        let buffer = UnsafeMutablePointer<uv_buf_t>(allocatingCapacity: 1024)
        
        buffer.pointee = uv_buf_init(self.buffer, UInt32(self.bufferSize))
        
        uv_fs_read(uv_default_loop(),
                   fs,
                   Int32(fsOpen.pointee.result),
                   buffer,
                   1024,
                   Int64(self.data.bytes.count),
                   fs_read_callback)
    }
    
    func close(file fs: UnsafeMutablePointer<uv_fs_t>) {
        
        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        
        fs.pointee.data = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        
        uv_fs_close(uv_default_loop(), fs, fs.pointee.file, fs_close_callback)
    }
}

