
import CUV

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public class FileSystem {
    
    var current: Int = 0
    
    static let sharedInstance = FileSystem()
    
    var operations: Set<ReadFileOperation>
    
    private init() {
        operations = []
    }
    
    func removeOperation(_ operation: ReadFileOperation) {
        operations.remove(operation)
    }
    
    func readFile(atPath path: String, callback: (data: Data?, error: ErrorProtocol?) -> ()) {
        
        let op = ReadFileOperation(identifier: current, path: path)
        current += 1
        operations.insert(op)
        op.start { data, error in
            callback(data: data, error: error)
            self.operations.remove(op)
        }
    }

    static public func readFile(atPath path: String, callback: (data: Data?, error: ErrorProtocol?) -> ()) {
        sharedInstance.readFile(atPath: path, callback: callback)
    }
}