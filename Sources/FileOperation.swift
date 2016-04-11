import CUV

enum FileOpenPermissions {
    case Read
    case Write
}

func fs_open_callback(req: UnsafeMutablePointer<uv_fs_t>) {
    let memory = unsafeBitCast(req.pointee.data, to: ReadFileOperation.self)
    if req.pointee.result >= 0 {
        memory.fileOpened(req)
    } else {
        memory.fileOpenFailed(req)
    }
}

func fs_read_callback(req: UnsafeMutablePointer<uv_fs_t>) {
    let memory = unsafeBitCast(req.pointee.data, to: ReadFileOperation.self)
    if req.pointee.result >= 0 {
        print(req.pointee.result)
        memory.fileRead(req)
    } else {
        
    }
}

func fs_close_callback(req: UnsafeMutablePointer<uv_fs_t>) {
    let memory = unsafeBitCast(req.pointee.data, to: ReadFileOperation.self)
    if req.pointee.result >= 0 {
        memory.fileClosed(req)
    } else {
        
    }
}

protocol FileOperation: class {
    
    var path: String { get }
    
    var buffer: UnsafeMutablePointer<Int8>? { get set }
    
    var permissions: [FileOpenPermissions] { get }
    
    func fileOpened(req: UnsafeMutablePointer<uv_fs_t>)
    
    func fileOpenFailed(req: UnsafeMutablePointer<uv_fs_t>)

    func fileRead(req: UnsafeMutablePointer<uv_fs_t>)
    
    func fileClosed(req: UnsafeMutablePointer<uv_fs_t>)
    
}

extension ReadFileOperation {
    
    func start() {
        openFile(permissions: self.permissions)
    }
    
    func openFile(permissions permissions: [FileOpenPermissions]) -> UnsafeMutablePointer<uv_fs_t> {
        
        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
        
        fs.pointee.data = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        
        if let cPath = path.cString(usingEncoding: NSUTF8StringEncoding) {
            uv_fs_open(EchoLoop.instance.loop, fs, cPath, O_RDONLY, 0, fs_open_callback)
        }
        
        return fs
    }
    
    func readFile(fsOpen: UnsafeMutablePointer<uv_fs_t>) -> UnsafeMutablePointer<uv_fs_t> {

        let fs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)

        fs.pointee.data = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        
        let buffer = UnsafeMutablePointer<Int8>(allocatingCapacity: 1025)
        uv_buf_init(buffer, 1024)
        
        let buf = UnsafePointer<uv_buf_t>(buffer)

        self.buffer = buffer
        
        uv_fs_read(EchoLoop.instance.loop, fs, Int32(fsOpen.pointee.result), buf, 1024, -1, fs_read_callback)
        
        return fs
    }
}

