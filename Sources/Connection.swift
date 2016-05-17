//
//  Connection.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

#if os(Linux)
import Dispatch
#endif

public class Connection {
    
    let socket: Socket
    
    let readBuffer: Buffer
    
    var writeData: Data
    
    init(socket: Socket) {
        self.socket = socket
        self.readBuffer = Buffer(size: 1024)
        self.writeData = Data()
    }
    
    func read(callback: (data: Buffer) -> ()) {
        
        let readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                                UInt(socket.raw),
                                                0,
                                                dispatch_get_main_queue())!
        

        dispatch_source_set_event_handler(readSource) {
            
            let amount = systemRead(self.socket.raw, self.readBuffer.buffer,
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
        
        #if os(Linux)
        dispatch_resume(dispatch_object_t(_ds: readSource))
        #else
        dispatch_resume(readSource)
        #endif
        
    }

    public func write(_ string: String) {

        let writeData = Data(string: string)
        write(data: writeData)
    }

    public func write(data: Data) {
        self.writeData = data
        let writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE,
                                                 UInt(socket.raw),
                                                 0,
                                                 dispatch_get_main_queue())!

        var amount = 0
        dispatch_source_set_event_handler(writeSource) {

            amount += systemWrite(self.socket.raw,
                                  data.raw.advanced(by: amount),
                                  data.size - amount)

            if amount < 0 {
                dispatch_source_cancel(writeSource)
            } else if amount == data.size {
                dispatch_source_cancel(writeSource)
            }
            
        }

        #if os(Linux)
        dispatch_resume(dispatch_object_t(_ds: writeSource))
        #else
        dispatch_resume(writeSource)
        #endif
        
        dispatch_source_set_cancel_handler(writeSource) { 
            self.socket.shutdown()
        }
    }
}
