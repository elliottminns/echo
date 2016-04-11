import CUV

class ReadFileOperation {
    
    typealias Callback = (data: Data?, error: ErrorProtocol?) -> ()
    
    let path: String
    
    let callback: Callback
    
    var buffer: UnsafeMutablePointer<Int8>?
    
    init(path: String, callback: Callback) {
        self.path = path
        self.callback = callback
    }
    
}

extension ReadFileOperation: FileOperation {

    var permissions: [FileOpenPermissions] {
        return [.Read]
    }
    
    func fileOpened(req: UnsafeMutablePointer<uv_fs_t>) {
        readFile(req)
    }
    
    func fileOpenFailed() {
        
    }
    
    func fileRead(req: UnsafeMutablePointer<uv_fs_t>) {
        for i in 0 ..< 1024 {
            print(buffer?.advanced(by: i).pointee)
        }
    }
    
    func fileClosed(req: UnsafeMutablePointer<uv_fs_t>) {
        
    }
    
    func fileOpenFailed(req: UnsafeMutablePointer<uv_fs_t>) {
        
    }
/*
//    extension FileOperation {
    
        func start() {
            openFile(permissions: self.permissions)
        }
        
        func openFile(permissions permissions: FileOpenPermissions) -> UnsafeMutablePointer<uv_fs_t> {
            
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
            
            let buffer = UnsafeMutablePointer<Int8>(allocatingCapacity: 1024)
            uv_buf_init(buffer, 1024)
            
            let buf = UnsafePointer<uv_buf_t>(buffer)
            
            //        self.buffer = buffer
            
            uv_fs_read(EchoLoop.instance.loop, fs, Int32(fsOpen.pointee.result), buf, 1024, -1, fs_read_callback)
            
            return fs
        }
    }*/
}