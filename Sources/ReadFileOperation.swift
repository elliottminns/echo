import CUV

class ReadFileOperation {
    
    typealias Callback = (error: ErrorProtocol?) -> ()
    
    let path: String
    
    var callback: Callback?
    
    var buffer: UnsafeMutablePointer<Int8>

    var bufferSize: Int
    
    var data: Data
    
    var openFs: UnsafeMutablePointer<uv_fs_t>
    
    var id: Int = 0
    
    init(path: String) {
        self.path = path
        self.data = Data(bytes: [])
        let size = 16384
        self.bufferSize = size
        self.buffer = UnsafeMutablePointer<Int8>(allocatingCapacity: size + 40)
        openFs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
    }
    
    deinit {
        print("deinint")
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
        callback?(error: nil)
    }
    
    func fileOpenFailed(req: UnsafeMutablePointer<uv_fs_t>) {
        
    }
}

func ==(lhs: ReadFileOperation, rhs: ReadFileOperation) -> Bool {
    return lhs.id == rhs.id
}