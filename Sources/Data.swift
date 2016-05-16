import Foundation

enum EncodingError: ErrorProtocol {
	case Failed
}

public struct Data {

	public var bytes: [UInt8]

	public var size: Int {
		return bytes.count
	}

	public var raw: UnsafeMutablePointer<UInt8> {
		return UnsafeMutablePointer<UInt8>(bytes)
	}

	public init() {
		self.bytes = []
	}

	public init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    public init(string: String) {
        self.bytes = [UInt8](string.utf8)
    }
    
    public init(base: UnsafeMutablePointer<Int8>, length: Int) {
        let ubase = UnsafeMutablePointer<UInt8>(base)
        self.bytes = Array(UnsafeBufferPointer(start: ubase, count: length))
    }

    public func toString() throws -> String {
        var bytes = self.bytes
        guard let str = String(bytesNoCopy: &bytes,
            length: bytes.count * sizeof(UInt8),
            encoding: NSUTF8StringEncoding,
            freeWhenDone: false) else {
                throw EncodingError.Failed
        }

        return str
    }
    
    public mutating func append(_ bytes: [UInt8]) {
        self.bytes += bytes
    }
    
    public mutating func append(_ buffer: UnsafePointer<Void>, length: Int) {
        guard length > 0 else { return } 
        let bytes = UnsafePointer<UInt8>(buffer)
        let buf = UnsafeBufferPointer(start: bytes, count: length)
        self.bytes.append(contentsOf: buf)
    }
}