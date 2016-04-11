
import CUV

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public class FileSystem {
    
    var current: Int = 0
    
    static let sharedInstance = FileSystem()
    
    var operations: Set<ReadFileOperation> = []
    
    init() {
        
    }
    
    func removeOperation(operation: ReadFileOperation) {
        
    }
    
    static public func readFile(path: String, callback: (data: Data?, error: ErrorProtocol?) -> ()) {
        let op = ReadFileOperation(path: path)
        op.start { error in
            callback(data: op.data, error: error)
        }
    }
    
}
