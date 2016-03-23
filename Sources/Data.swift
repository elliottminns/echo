import Foundation

public enum EncodingType {
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
    static var encodingType: EncodingType { get }
    static func fromString(string: String) -> [Self]
}

extension UInt8: ByteType {
    public static var encodingType: EncodingType {
        return .UTF8
    }

    public static func fromString(string: String) -> [UInt8] {
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
        return self.bytes.count * sizeof(UInt8)
    }

    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    public init(string: String) {
        self.bytes = UInt8.fromString(string)
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
    
    public mutating func append(bytes: [UInt8]) {
        self.bytes += bytes
    }
    
    public mutating func append(buffer: UnsafePointer<Void>, length: Int) {
        let bytes = UnsafePointer<UInt8>(buffer)
        var byteArray: [UInt8] = []
        for i in stride(from: 0, to: length, by: 1) {
            byteArray.append(bytes[i])
        }
        self.append(byteArray)
    }
}
