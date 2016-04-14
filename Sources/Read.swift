//
//  Read.swift
//  Echo
//
//  Created by Elliott Minns on 14/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation
import CUV

typealias read_callback = (stream: UnsafeMutablePointer<uv_stream_t>!, size: Int, buffer: UnsafePointer<uv_buf_t>!) -> ()

class ReadCallback {
    
    let callback: read_callback
    
    init(callback: read_callback) {
        self.callback = callback
    }
}

extension io {
    
    class func read_start(_ req: UnsafeMutablePointer<uv_stream_t>!,
                          _ alloc_cb: uv_alloc_cb!,
                          _ read_cb: read_callback) -> Int32 {
        
        let holder = Unmanaged.passRetained(ReadCallback(callback: read_cb))
        let opaque = OpaquePointer(bitPattern: holder)
        req.pointee.data = UnsafeMutablePointer<Void>(opaque)
        
        return uv_read_start(req, alloc_cb, on_read)
    }
}

private func on_read(stream: UnsafeMutablePointer<uv_stream_t>!, size: Int, buffer: UnsafePointer<uv_buf_t>!) {
    guard let opaque = OpaquePointer(stream.pointee.data) else { return }
    let unmanaged = Unmanaged<ReadCallback>.fromOpaque(opaque)
    let callback = unmanaged.takeUnretainedValue()
    callback.callback(stream: stream, size: size, buffer: buffer)
    unmanaged.release()
}