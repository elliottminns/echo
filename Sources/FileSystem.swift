
import CUV
import Darwin

public class FileSystem {
    
    static let sharedInstance = FileSystem()
    
    var operations: [FileOperation] = []
    
    init() {
        
    }
    
    static public func readFile(path: String, callback: (data: Data?, error: ErrorProtocol?) -> ()) {
        let op = ReadFileOperation(path: path, callback: callback)
        sharedInstance.operations.append(op)
        op.start()
    }
    
}