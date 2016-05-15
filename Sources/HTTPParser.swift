//
//  HTTPParser.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation



struct ParserError: ErrorType {
    let problemArea: String
    let message: String
}

struct HTTPParser {
    
    let buffer: Buffer
    
	init(buffer: Buffer) {
		self.buffer = buffer
	}

    func parse() throws -> HTTPRequest {
        
        let raw = self.buffer.toString()
        var lines = raw.componentsSeparatedByString("\r\n")
        let firstLine = lines.removeFirst()
        let route = try loadRoute(firstLine)
        let headers = loadHeaders(&lines)
        let body = lines.last ?? ""
        
        return HTTPRequest(headers: headers, method: route.method, body: body,
                           path: route.path, httpProtocol: route.httpProtocol)
    }
    
    func loadRoute(line: String) throws -> (method: HTTPMethod, path: String, httpProtocol: String) {
        let comps = line.componentsSeparatedByString(" ")
        guard let methodString = comps.first,
            httpProtocol = comps.last where
            comps.count == 3 else {
                throw ParserError(problemArea: line,
                                  message: "Missing a part of the route")
        }
        
        guard let method = HTTPMethod(string: methodString) else {
            throw ParserError(problemArea: "Method", message: "Method is unknown for type: \(methodString)")
        }
        
        return (method: method, path: comps[1], httpProtocol: httpProtocol)
    }
	
    func loadHeaders(inout lines: [String]) -> [String: String] {
        var headers: [String: String] = [:]
        
        var currentLine = lines.removeFirst()
        
        repeat {
            
            let comps = currentLine.componentsSeparatedByString(": ")
            
            if comps.count == 2 {
                
                headers[comps[0]] = comps.last
            }
            
            currentLine = lines.removeFirst()
        } while currentLine.utf8.count > 0
        
        return headers
    }

    
    
}