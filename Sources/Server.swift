//
//  Server.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

#if os(Linux)
import Glibc
import Dispatch
#endif

public protocol ServerDelegate {
    func server(_ server: Server, didCreateConnection connection: Connection)
}

public class Server {
    
    let type: SocketType

    let socket: Socket
    
    let port: Int
    
    let dispatcher: dispatch_source_t
    
    let delegate: ServerDelegate
    
    init(socket: Socket, port: Int, delegate: ServerDelegate, type: SocketType = .TCP) {
        self.socket = socket
        self.port = port
        self.delegate = delegate
        self.type = type
        dispatcher = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                            UInt(socket.raw),
                                            0, dispatch_get_main_queue())
    }
    
    public convenience init(port: Int, delegate: ServerDelegate, type: SocketType) throws {
        let socket = try Socket()
        self.init(socket: socket, port: port, delegate: delegate)
    }
    
    func listen() throws {
        
        let address = try Address(address: "0.0.0.0", port: self.port)
        
        var value = 1
        
        if setsockopt(socket.raw, SOL_SOCKET, SO_REUSEADDR,
                      &value, socklen_t(sizeof(Int32))) == -1 {
            throw SocketError.CouldNotListen
        }
        
	#if !os(Linux)
        var no_sig_pipe: Int32 = 1
        setsockopt(socket.raw, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(sizeof(Int32)))
        #endif

        try bind(socket: socket, address: address)
        
        if (systemListen(socket.raw, 128) < 0) {
            throw SocketError.CouldNotListen
        }
        
        dispatch_source_set_event_handler(dispatcher, {
            if let connection = try? self.accept() {
                self.delegate.server(self, didCreateConnection: connection)
            }
        })
        
        #if os(Linux)
        dispatch_resume(dispatch_object_t(_ds: dispatcher))
        #else
        dispatch_resume(dispatcher)
        #endif
    }
    
    func accept() throws -> Connection {
        let addr = UnsafeMutablePointer<sockaddr>(allocatingCapacity: 1)
        var len = socklen_t(0)
        let fd = systemAccept(self.socket.raw, addr, &len)
        let client = try Socket(raw: fd)
        return Connection(socket: client)
    }
    
    private func bind(socket: Socket, address: Address) throws {
        let r = systemBind(socket.raw,
                            UnsafeMutablePointer<sockaddr>(address.raw),
                            socklen_t(sizeof(sockaddr_in)))
        if r < 0 {
            throw SocketError.CouldNotBind
        }
    }
    
}
