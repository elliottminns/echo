//
//  HTTPMethod.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

public enum HTTPMethod {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

extension HTTPMethod {
    
    init?(string: String) {
        switch string {
        case "GET":
            self = GET
        case "POST":
            self = POST
        case "PUT":
            self = PUT
        case "DELETE":
            self = DELETE
        case "PATCH":
            self = PATCH
        default: 
            return nil
        }
    }
    
}