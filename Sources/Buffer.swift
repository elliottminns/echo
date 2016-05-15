//
//  Buffer.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

class Buffer {
    
    let size: Int
    
    let buffer: UnsafeMutablePointer<Void>
    
    // Used to prevent the string from dying.
    private var bytes: [UInt8] = []
    
    init(string: String) {
        self.bytes = [UInt8](string.utf8)
        let bytes = UnsafeMutablePointer<UInt8>(self.bytes)
        self.buffer = UnsafeMutablePointer<Void>(bytes)
        self.size = self.bytes.count
    }
    
    init(size: Int) {
        self.size = size
        self.buffer = UnsafeMutablePointer<Void>.alloc(size)
    }
    
    deinit {
//        self.buffer.dealloc(size)
    }
    
    func toString() -> String {
        let string = String(bytesNoCopy: buffer, length: size,
                            encoding: NSUTF8StringEncoding,
                            freeWhenDone: false) ?? ""
        return string
    }
    
}