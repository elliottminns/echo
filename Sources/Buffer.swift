//
//  Buffer.swift
//  Echo
//
//  Created by Elliott Minns on 14/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation
import CUV

class Buffer {
    
    let size: Int
    let raw: UnsafeMutablePointer<uv_buf_t>
    let bits: UnsafeMutablePointer<Int8>
    let alloced: Bool
    let data: Data?
    
    init(size: Int = 1024) {
        self.size = size
        bits = UnsafeMutablePointer<Int8>(allocatingCapacity: size)
        raw = UnsafeMutablePointer<uv_buf_t>(allocatingCapacity: 1)
        raw.pointee = uv_buf_t(base: bits, len: size)
        alloced = true
        data = nil
    }
    
    init(data: Data) {
        self.size = data.size
        self.data = data
        raw = UnsafeMutablePointer<uv_buf_t>(allocatingCapacity: 1)
        bits = UnsafeMutablePointer<Int8>(data.bytes)
        raw.pointee = uv_buf_t(base: bits, len: size)
        alloced = true
    }
    
    init(size: size_t, raw: UnsafeMutablePointer<uv_buf_t>) {
        self.size = Int(size)
        self.bits = UnsafeMutablePointer<Int8>(allocatingCapacity: Int(size))
        self.raw = raw
        alloced = false
        self.data = nil
    }
    
    deinit {
        if data == nil {
            bits.deallocateCapacity(size)
        }
        if alloced {
            raw.deallocateCapacity(1)
        }
    }
    
}
