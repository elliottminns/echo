//
//  HTTPRequest.swift
//  Echo
//
//  Created by Elliott Minns on 14/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import CUV

public enum RequestMethod {
    case GET
    case POST
    case DELETE
    case PUT
    
    var stringValue: String {
        switch self {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        case .DELETE:
            return "DELETE"
        case .PUT:
            return "PUT"
        }
    }
}

public enum EncodingType {
    case Form
    case JSON
}

public struct URLRequest {
    
    var headers: [String: String]
    
    public var method: RequestMethod
    
    public var encodingType: EncodingType
    
    public var body: Data
    
    public let host: String
    
    public let port: Int
    
    public let path: String
    
    public init(host: String, path: String, method: RequestMethod) {
        self.init(host: host, path: path, port: 80, method: method)
    }
    
    public init(host: String, path: String) {
        self.init(host: host, path: path, port: 80, method: .GET)
    }
    
    public init(host: String, path: String, port: Int) {
        self.init(host: host, path: path, port: port, method: .GET)
    }

    public init(host: String, path: String, port: Int, method: RequestMethod) {
        self.init(host: host, path: path, port: port, method: method,
                  encodingType: .Form)
    }
    
    public init(host: String, path: String, port: Int, method: RequestMethod,
                encodingType: EncodingType) {
        self.host = host
        self.path = path
        self.port = port
        self.method = method
        self.encodingType = encodingType
        
        self.headers = {
            let hostHeader: String = {
                var header = host
                if port != 80 {
                    header += ":\(port)"
                }
                return header
            }()
            return ["Host": hostHeader,
                    "User-Agent": "Echo/0.7.0",
                    "Accept": "*/*"]
        }()
        body = Data(bytes: [])
    }
    
    public func strippedHost() -> String {
        return self.host.components(separatedBy: "://").last ?? host
    }
    
    public mutating func add(header: String, value: String) {
        headers[header] = value
    }
    
    func data() -> Data {
        var headers = self.headers
        var string = "\(method.stringValue) \(path) HTTP/1.1\r\n"
        
        if let host = headers["Host"] {
            headers["Host"] = nil
            string += "Host" + ": \(host)\r\n"
        }
        
        if let agent = headers["User-Agent"] {
            headers["User-Agent"] = nil
            string += "User-Agent: " + agent + "\r\n"
        }
        
        if let accept = headers["Accept"] {
            headers["Accept"] = nil
            string += "Accept: " + accept + "\r\n"
        }
        
        if (body.size > 0) {
            string += "Content-Length: \(body.size)"
        }
        
        if method == .POST {
            switch encodingType {
            case .Form:
                    string += "Content-Type: application/x-www-form-urlencoded\r\n"
            case .JSON:
                    string += "Content-Type: application/json\r\n"
            }
        }
        
        string += "\r\n"
        
        var data = Data(string: string)
        data.append(body.bytes)
        
        print(string)
        
        return data
    }
}
