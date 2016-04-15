import Foundation

public enum StringEncodingType {
    case UTF8

    var typeForEncoding: Any.Type {

        let type: Any.Type
        switch self {
        case UTF8:
            type = UInt8.self
        }

        return type
    }

    var encoding: UInt {
        switch self {
        case UTF8:
            return NSUTF8StringEncoding
        }
    }
}

public protocol ByteType {
    static var encodingType: StringEncodingType { get }
    static func from(string: String) -> [Self]
}

extension UInt8: ByteType {
    public static var encodingType: StringEncodingType {
        return .UTF8
    }

    public static func from(string: String) -> [UInt8] {
        let buf = [UInt8](string.utf8)
        return buf
    }
}

enum EncodingError: ErrorProtocol {
    case Failed
}

public struct Data {

    public var bytes: [UInt8]

    public var size: Int {
        return self.bytes.count
    }
    
    init() {
        self.bytes = []
    }

    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    public init(string: String) {
        self.bytes = UInt8.from(string: string)
    }
    
    public init(base: UnsafeMutablePointer<Int8>, length: Int) {
        let ubase = UnsafeMutablePointer<UInt8>(base)
        self.bytes = Array(UnsafeBufferPointer(start: ubase, count: length))
    }

    public func toString() throws -> String {
        var bytes = self.bytes
        guard let str = String(bytesNoCopy: &bytes,
            length: bytes.count * sizeof(UInt8),
            encoding: UInt8.encodingType.encoding,
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
