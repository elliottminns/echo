//
//  Connection.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

public class Connection {
    
    let socket: Socket
    
    let readBuffer: Buffer
    
    var writeBuffer: Buffer
    
    init(socket: Socket) {
        self.socket = socket
        self.readBuffer = Buffer(size: 1024)
        self.writeBuffer = Buffer(size: 1024)
        setup()
    }
    
    func setup() {
    }

    func read(callback: (data: Buffer) -> ()) {
        
        let readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                                UInt(socket.raw),
                                                0,
                                                dispatch_get_main_queue())!
        
        dispatch_source_set_event_handler(readSource) {
            
            let amount = Darwin.read(self.socket.raw, self.readBuffer.buffer,
                                     self.readBuffer.size)
            if amount < 0 {
                print("Error with reading")
                dispatch_source_cancel(readSource)
            } else if amount == 0 {
                print("Amount was 0")
                callback(data: self.readBuffer)
                dispatch_source_cancel(readSource)
            } else {
                callback(data: self.readBuffer)
                dispatch_source_cancel(readSource)
            }
        }
        
        dispatch_resume(readSource)
        
    }
    
    public func write(_ string: String) {

        self.writeBuffer = Buffer(string: string)
        
        let writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE,
                                                 UInt(socket.raw),
                                                 0,
                                                 dispatch_get_main_queue())!
        dispatch_source_set_event_handler(writeSource) {
            let amount = Darwin.write(self.socket.raw, self.writeBuffer.buffer,
                                      self.writeBuffer.size)
            if amount < 0 {
                dispatch_source_cancel(writeSource)
            } else if amount == self.writeBuffer.size {
                dispatch_source_cancel(writeSource)
            }
            
        }
        dispatch_resume(writeSource)
        
        dispatch_source_set_cancel_handler(writeSource) { 
            self.socket.shutdown()
        }
    }
}