//
//  main.swift
//  Echo-Example
//
//  Created by Elliott Minns on 12/02/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Echo

let file = "/Users/Elliott/Desktop/ss.png"



class Delegate: ServerDelegate {
    
    func server(server: Server, didRecieveConnection connection: Connection) {
        
    }
}

let server = Server()

server.delegate = Delegate()

server.listen(3600) { error in
    print(error == nil ? "Listening on port 3500" : "error listening")
    FileSystem.readFile(file) { (data, error) in
        
    }
}