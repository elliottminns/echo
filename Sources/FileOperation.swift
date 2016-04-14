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
