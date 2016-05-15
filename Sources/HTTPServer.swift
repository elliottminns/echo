//
//  HTTPServer.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

public protocol HTTPServerDelegate {
    func server(server: HTTPServer, didRecieveRequest request: HTTPRequest, response: HTTPResponse)
}

public class HTTPServer {
    
    public var port: Int {
        return currentPort
    }
    
    var currentPort: Int
    
    var server: Server?
    
    var delegate: HTTPServerDelegate?
    
    public init(delegate: HTTPServerDelegate) {
        currentPort = 80
        self.delegate = delegate
    }
    
    public func listen(port: Int) throws {
        self.currentPort = port
        if server == nil {
            server = try Server(port: port, delegate: self, type: .TCP)
            try server?.listen()
        }
    }
    
    func sendErrorResponse(toConnection connection: Connection) {
        let response = "HTTP/1.1 400 Client Error"
        connection.write(response)
    }
    
}

extension HTTPServer: ServerDelegate {
    
    public func server(server: Server, didCreateConnection connection: Connection) {
        
        connection.read { data in
            
            do {
                let request = try HTTPParser(buffer: data).parse()
                request.connection = connection
                
                let response = HTTPResponse(connection: connection)
                self.delegate?.server(self, didRecieveRequest: request,
                    response: response)
            } catch {
                if let error = error as? ParserError {
                    print(error.message)
                    print(error.problemArea)
                }
                self.sendErrorResponse(toConnection: connection)
            }
        }
    }
}