//
//  URLResponse.swift
//  Echo
//
//  Created by Elliott Minns on 15/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

enum Status {
    case OK, Created, Accepted, NoContent
    case MovedPermanently
    case BadRequest, Unauthorized, Forbidden, NotFound
    case Error
    case Unknown
    case Custom(Int, String)
    
    var code: Int {
        switch self {
        case .OK: return 200
        case .Created: return 201
        case .Accepted: return 202
        case .NoContent: return 204
            
        case .MovedPermanently: return 301
            
        case .BadRequest: return 400
        case .Unauthorized: return 401
        case .Forbidden: return 403
        case .NotFound: return 404
            
        case .Error: return 500
            
        case .Unknown: return 0
        case .Custom(let code, _):
            return code
        }
    }
    
    var description: String {
        switch self {
        case .OK:
            return "OK"
        case .Created:
            return "Created"
        case .Accepted:
            return "Accepted"
        case .NoContent:
            return "No Content"
        case .MovedPermanently:
            return "Moved Permanently"
        case .BadRequest:
            return "Bad Request"
        case .Unauthorized:
            return "Unauthorized"
        case .Forbidden:
            return "Forbidden"
        case .NotFound:
            return "Not Found"
        case .Error:
            return "Internal Server Error"
        case .Unknown:
            return "Unknown"
        case .Custom(_, let description):
            return description
        }
    }
    
    init(description: String) {
        switch description {
        case "OK":
            self = .OK
        case "Created":
            self = .Created
        case "Accepted":
            self = .Accepted
        case "No Content":
            self = .NoContent
        case "Moved Permanently":
            self = .MovedPermanently
        case "Bad Request":
            self = .BadRequest
        case "Unauthorized":
            self = .Unauthorized
        case "Forbidden":
            self = .Forbidden
        case "Not Found":
            self = .NotFound
        case "Internal Server Error":
            self = .Error
        case "Unknown":
            self = .Unknown
        default:
            self = .Custom(0, description)
        }
    }
}

public struct URLResponse {
    
    public var status: Int
    
    public var headers: [String: String]
    
    public var body: Data
    
    init() {
        status = 0
        headers = [:]
        body = Data()
    }
    
}