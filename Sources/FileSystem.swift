
import CUV

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public class FileSystem {
    
    var current: Int = 0
    
    static let sharedInstance = FileSystem()
    
    var operations: [ReadFileOperation: (data: Data?, error: ErrorProtocol?) -> ()] = [:]
    
    init() {
        
    }
    
    func removeOperation(_ operation: ReadFileOperation) {
        
    }
    
    func readFile(atPath path: String, callback: (data: Data?, error: ErrorProtocol?) -> ()) {
        let op = ReadFileOperation(identifier: current, path: path, delegate: self)
        current += 1
        operations[op] = callback
        op.start()
    }

    static public func readFile(atPath path: String, callback: (data: Data?, error: ErrorProtocol?) -> ()) {
        sharedInstance.readFile(atPath: path, callback: callback)
    }
}

extension FileSystem: ReadFileOperationDelegate {
    func operation(operation: ReadFileOperation, didCompleteWithData data: Data) {
        let callback = operations[operation]
        operations[operation] = nil
        callback?(data: operation.data, error: nil)
    }
}