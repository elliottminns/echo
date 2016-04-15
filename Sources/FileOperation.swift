import CUV
import Foundation

enum FileOpenPermissions {
    case Read
    case Write
}

typealias uv_fs = ImplicitlyUnwrappedOptional<UnsafeMutablePointer<uv_fs_t>>

typealias fs_callback = (req: UnsafeMutablePointer<uv_fs_t>!) -> ()

class FsCallback {
    let callback: fs_callback
    init(callback: fs_callback) {
        self.callback = callback
    }
}

private func fs_cb(req: UnsafeMutablePointer<uv_fs_t>!) {
    guard let opaque = OpaquePointer(req.pointee.data) else { return }
    let holder = Unmanaged<FsCallback>.fromOpaque(opaque)
    holder.takeUnretainedValue().callback(req: req)
}

extension io {
    class func fs_open(_ loop: UnsafeMutablePointer<uv_loop_t>,
                       _ req: UnsafeMutablePointer<uv_fs_t>,
                       _ path: String,
                       _ flags: Int32,
                       _ mode: Int32,
                       _ callback: fs_callback) {
        
        #if os(Linux)
            let cPath = path.cStringUsingEncoding(NSUTF8StringEncoding)
        #else
            let cPath = path.cString(using: NSUTF8StringEncoding)
        #endif

        if let cPath = cPath {
            let holder = Unmanaged.passRetained(FsCallback(callback: callback))
            let opaque = OpaquePointer(bitPattern: holder)
            req.pointee.data = UnsafeMutablePointer<Void>(opaque)
            uv_fs_open(loop, req, cPath, flags, mode, fs_cb)
        }
    }
    
    class func fs_read(_ loop: UnsafeMutablePointer<uv_loop_t>,
                       _ req: UnsafeMutablePointer<uv_fs_t>,
                       _ file: uv_file,
                       _ bufs: UnsafeMutablePointer<uv_buf_t>,
                       _ nbufs: UInt32,
                       _ offset: Int64,
                       _ callback: fs_callback) {
        
        let holder = Unmanaged.passRetained(FsCallback(callback: callback))
        let opaque = OpaquePointer(bitPattern: holder)
        req.pointee.data = UnsafeMutablePointer<Void>(opaque)
        
        uv_fs_read(loop, req, file, bufs, nbufs, offset, fs_cb)
    }
}

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
    
    var identifier: Int { get set }
    
    var path: String { get }

    var bufferSize: Int { get }
    
    var permissions: [FileOpenPermissions] { get }
    
    func fileOpened(req: UnsafeMutablePointer<uv_fs_t>)
    
    func fileOpenFailed(req: UnsafeMutablePointer<uv_fs_t>)

    func fileRead(req: UnsafeMutablePointer<uv_fs_t>)
    
    func fileClosed(req: UnsafeMutablePointer<uv_fs_t>)
    
}
