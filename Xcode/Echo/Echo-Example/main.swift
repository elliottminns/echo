//
//  main.swift
//  Echo-Example
//
//  Created by Elliott Minns on 12/02/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Echo

let file = "/Users/Elliott/Desktop/ss.png"

FileSystem.readFile(atPath: file) { (data, error) in
    print(data?.bytes.count)
}

class Delegate: ServerDelegate {
    
    func server(_ server: Server, didRecieveConnection connection: Connection) {
        _ = ""
    }
}

let server = Server()

server.delegate = Delegate()

server.listen(port: 3600) { error in
    print(error == nil ? "Listening on port 3500" : "error listening")

}