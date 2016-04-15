//
//  HTTPParser.swift
//  Echo
//
//  Created by Elliott Minns on 15/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation
import CHttpParser

func getHolder(fromRaw parser: UnsafeMutablePointer<http_parser>!) -> Unmanaged<HTTPParser>? {
    guard let opaque = OpaquePointer(parser.pointee.data) else { return nil }
    let holder = Unmanaged<HTTPParser>.fromOpaque(opaque)
    return holder
}

func getParser(fromRaw parser: UnsafeMutablePointer<http_parser>!) -> HTTPParser? {
    guard let holder = getHolder(fromRaw: parser) else { return nil }
    let parser = holder.takeUnretainedValue()
    return parser
}

func on_status(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) -> Int32 {
    let p = getParser(fromRaw: parser)
    p?.onStatus(parser: parser, data: data, size: size)
    return 0
}

func on_header_value(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) -> Int32 {
    let p = getParser(fromRaw: parser)
    p?.onHeaderValue(parser: parser, data: data, size: size)
    return 0
}

func on_header_field(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) -> Int32 {
    let p = getParser(fromRaw: parser)
    p?.onHeaderField(parser: parser, data: data, size: size)
    return 0
    
}

func on_headers_complete(parser: UnsafeMutablePointer<http_parser>!) -> Int32 {
    let p = getParser(fromRaw: parser)
    p?.onHeadersComplete(parser: parser)
    return 0
}

func message_complete(parser: UnsafeMutablePointer<http_parser>!) -> Int32 {
    let p = getParser(fromRaw: parser)
    p?.completed()
    return 0
}

func on_body(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) -> Int32 {
    let p = getParser(fromRaw: parser)
    p?.onBody(parser: parser, data: data, size: size)
    return 0
}

func on_message_begin(parser: UnsafeMutablePointer<http_parser>!) -> Int32 {
    return 0
}

enum HTTPParserError: ErrorProtocol {
    case ParseError
}

protocol HTTPParserDelegate: class {
    func parser(_ parser: HTTPParser, didParseResponse response: URLResponse)
}

class HTTPParser {
    
    enum State {
        case Ready
        case Started
        case Status
        case Headers
    }
    
    let parser: UnsafeMutablePointer<http_parser>
    
    let parserSettings: UnsafeMutablePointer<http_parser_settings>
    
    var response: URLResponse
    
    var headers: [String: String]
    
    var currentHeader: String?
    
    var currentState: State
    
    weak var delegate: HTTPParserDelegate?
    
    init() {
        parser = UnsafeMutablePointer<http_parser>(allocatingCapacity: 1)
        http_parser_init(parser, HTTP_RESPONSE)
        parserSettings = UnsafeMutablePointer<http_parser_settings>(allocatingCapacity: 1)
        response = URLResponse()
        currentState = .Ready
        headers = [:]
        setupCallbacks()
    }
    
    func setupCallbacks() {
        let unmanaged = Unmanaged.passRetained(self)
        let opaque = OpaquePointer(bitPattern: unmanaged)
        let raw = UnsafeMutablePointer<Void>(opaque)
        parser.pointee.data = raw
        
        parserSettings.pointee.on_status = on_status
        parserSettings.pointee.on_header_field = on_header_field
        parserSettings.pointee.on_header_value = on_header_value
        parserSettings.pointee.on_headers_complete = on_headers_complete
        parserSettings.pointee.on_message_begin = on_message_begin
        parserSettings.pointee.on_message_complete = message_complete
        parserSettings.pointee.on_body = on_body
    }
    
    func exectue(data: Data) throws {
        
        let bytes = UnsafePointer<Int8>(data.bytes)
        let parsed = http_parser_execute(parser, parserSettings, bytes, data.size)
        
        if parsed != data.size {
            throw HTTPParserError.ParseError
        }
    }
    
    func completed() {
        getHolder(fromRaw: parser)?.release()
        parser.deallocateCapacity(1)
        parserSettings.deallocateCapacity(1)
        delegate?.parser(self, didParseResponse: response)
    }
}

// MARK: - Callbacks
extension HTTPParser {
    
    func onHeaderField(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) {
        currentState = State.Headers
        let field = Data(base: UnsafeMutablePointer<Int8>(data), length: size)
        currentHeader = try? field.toString()
    }
    
    func onHeadersComplete(parser: UnsafeMutablePointer<http_parser>) {
        response.headers = headers
    }
    
    func onHeaderValue(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) {
        let value = Data(base: UnsafeMutablePointer<Int8>(data), length: size)
        if let currentHeader = currentHeader {
            headers[currentHeader] = try? value.toString()
        }
    }
    
    func onStatus(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) {
        let value = Data(base: UnsafeMutablePointer<Int8>(data), length: size)
        let desc = (try? value.toString()) ?? "Unknown"
        let status = Status(description: desc)
        response.status = status.code
    }
    
    func onBody(parser: UnsafeMutablePointer<http_parser>!, data: UnsafePointer<Int8>!, size: Int) {
        response.body.append(data, length: size)
    }
}
