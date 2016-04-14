//
//  Write.swift
//  Echo
//
//  Created by Elliott Minns on 14/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation
import CUV

class io {
    
}

typealias write_callback = (handle: UnsafeMutablePointer<uv_write_t>!, size: Int) -> ()

extension io {

    class func write(_ req: UnsafeMutablePointer<uv_write_t>!,
                     _ handle: UnsafeMutablePointer<uv_stream_t>!,
                     _ bufs: UnsafePointer<uv_buf_t>!,
                     _ nbufs: UInt32,
                     _ cb: write_callback!) -> Int32 {
        
        let holder = Unmanaged.passRetained(WriteCallback(callback: cb))
        let opaque = OpaquePointer(bitPattern: holder)
        req.pointee.data = UnsafeMutablePointer<Void>(opaque)
        
        return uv_write(req, handle, bufs, nbufs, write_cb)
    }
}

class WriteCallback {
    
    let callback: write_callback
    
    init(callback: write_callback) {
        self.callback = callback
    }
}

func write_cb(handle: UnsafeMutablePointer<uv_write_t>!, size: Int32) {
    guard let opaque = OpaquePointer(handle.pointee.data) else { return }
    let unmanaged = Unmanaged<WriteCallback>.fromOpaque(opaque)
    let callback = unmanaged.takeUnretainedValue()
    callback.callback(handle: handle, size: Int(size))
    unmanaged.release()
}

