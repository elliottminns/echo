//
//  Connect.swift
//  Echo
//
//  Created by Elliott Minns on 14/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation
import CUV

typealias tcp_connect_callback = (handle: UnsafeMutablePointer<uv_connect_t>!,
    status: Int) -> ()

extension io {
    class func tcp_connect(_ req: UnsafeMutablePointer<uv_connect_t>,
                     _ socket: UnsafeMutablePointer<uv_tcp_t>,
                     _ addr: UnsafeMutablePointer<sockaddr>,
                     _ callback: tcp_connect_callback) -> Int32 {
        let holder = Unmanaged.passRetained(TCPConnectCallback(callback: callback))
        let opaque = OpaquePointer(bitPattern: holder)
        req.pointee.data = UnsafeMutablePointer<Void>(opaque)
        
        return uv_tcp_connect(req, socket, addr, on_connect)
    }
}

func on_connect(handle: UnsafeMutablePointer<uv_connect_t>!, status: Int32) {
    guard let opaque = OpaquePointer(handle.pointee.data) else { return }
    let unmanaged = Unmanaged<TCPConnectCallback>.fromOpaque(opaque)
    let callback = unmanaged.takeUnretainedValue()
    callback.callback(handle: handle, status: Int(status))
    unmanaged.release()
}

class TCPConnectCallback {
    
    let callback: tcp_connect_callback
    
    init(callback: tcp_connect_callback) {
        self.callback = callback
    }
}