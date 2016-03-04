//
//  main.swift
//  Echo-Example
//
//  Created by Elliott Minns on 12/02/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Echo

class Delegate: ServerDelegate {
    func didRecieveConnection(connection: Connection) {
        print(try? connection.data.toString())
    }
}

let server = Server(delegate: Delegate())
do {
    try server.listen(3500)
} catch {
    
}