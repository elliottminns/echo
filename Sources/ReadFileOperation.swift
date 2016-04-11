import CUV

class ReadFileOperation {
    
    typealias Callback = (data: Data?, error: ErrorProtocol?) -> ()
    
    let path: String
    
    let callback: Callback
    
    var buffer: UnsafeMutablePointer<Int8>

    var bufferSize: Int
    
    var data: Data
    
    var openFs: UnsafeMutablePointer<uv_fs_t>
    
    init(path: String, callback: Callback) {
        self.path = path
        self.callback = callback
        self.data = Data(bytes: [])
        let size = 1024
        self.bufferSize = size
        self.buffer = UnsafeMutablePointer<Int8>(allocatingCapacity: size + 40)
        openFs = UnsafeMutablePointer<uv_fs_t>(allocatingCapacity: 1)
    }
    
    deinit {
        print("deinint")
    }
}

extension ReadFileOperation: FileOperation {

    var permissions: [FileOpenPermissions] {
        return [.Read]
    }
    
    func fileOpened(req: UnsafeMutablePointer<uv_fs_t>) {
        openFs = req
        readFile(req)
    }
    
    func fileOpenFailed() {
        
    }
    
    func fileRead(req: UnsafeMutablePointer<uv_fs_t>) {
        
        let size = req.pointee.result
            
        if size <= bufferSize {
            data.append(buffer, length: size)
        }
        
        if size != bufferSize {
            print("closing")
            closeFile(openFs)
            let d = NSData(bytes: &data.bytes, length: data.bytes.count)
            try? d.write(toFile: "/Users/Elliott/Desktop/test.png", options: .atomicWrite)
        } else {
            print("More to read")
            readFile(openFs)
            
        }
    }
    
    func fileClosed(req: UnsafeMutablePointer<uv_fs_t>) {
        
    }
    
    func fileOpenFailed(req: UnsafeMutablePointer<uv_fs_t>) {
        
    }
}