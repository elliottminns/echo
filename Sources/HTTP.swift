//
//  HTTP.swift
//  Echo
//
//  Created by Elliott Minns on 15/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation


public class HTTP {
    
    private static let instance = HTTP()
    
    private var connections: Set<URLConnection>
    
    var current = 1
    
    private init() {
        connections = []
    }
    
    private func perform(request: URLRequest, callback: (response: URLResponse?, error: ErrorProtocol?) -> ()) {
        let connection = URLConnection(request: request)
        connection.identifier = current
        current += 1
        connections.insert(connection)
        connection.perform { (response, error) in
            callback(response: response, error: error)
            self.connections.remove(connection)
        }
    }
}

extension HTTP {
    public class func perform(request: URLRequest, callback: (response: URLResponse?, error: ErrorProtocol?) -> ()) {
        HTTP.instance.perform(request: request, callback: callback)
    }
}