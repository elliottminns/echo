//
//  main.swift
//  Echo-Example
//
//  Created by Elliott Minns on 12/02/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Echo

class Delegate: HTTPServerDelegate {
    func server(server: HTTPServer, didRecieveRequest request: HTTPRequest, response: HTTPResponse) {
        let html = "<h1>Hello World</h1><p>The Swift Web Server is Working</p>"
        response.send(html: html)
    }
}

let server = HTTPServer(delegate: Delegate())

do {
    try server.listen(4000)
    print("Server listening on port: \(server.port)" )
} catch {
    print("Something went wrong")
}


NSRunLoop.mainRunLoop().run()