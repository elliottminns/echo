//
//  URLConnection.swift
//  Echo
//
//  Created by Elliott Minns on 14/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation
import CUV

enum URLConnectionError: ErrorProtocol {
    case ConnectionFailed
}

private func on_read(stream: UnsafeMutablePointer<uv_stream_t>!, size: Int, buffer: UnsafePointer<uv_buf_t>!) {
    let data = stream.pointee.data
    let connection = unsafeBitCast(data, to: URLConnection.self)
    connection.read(stream: stream, size: size, buffer: buffer)
}

private func on_resolved(resolver: UnsafeMutablePointer<uv_getaddrinfo_t>!,
                         status: Int32,
                         res: UnsafeMutablePointer<Foundation.addrinfo>!) {
    
    guard let opaque = OpaquePointer(resolver.pointee.data) else { return }
    let holder = Unmanaged<URLConnection>.fromOpaque(opaque)
    let connection = holder.takeUnretainedValue()
    connection.onResolved(resolver: resolver, status: status, res: res)
    holder.release()
}

public class URLConnection {
    
    let socket: UnsafeMutablePointer<uv_tcp_t>
    let connect: UnsafeMutablePointer<uv_connect_t>
    let addr: UnsafeMutablePointer<sockaddr_in>
    let writer: UnsafeMutablePointer<uv_write_t>
    let request: URLRequest
    let buffer: Buffer
    var readData: Data
    var callback: ((error: ErrorProtocol?) -> ())?
    var connection: Connection?
    let hints: UnsafeMutablePointer<addrinfo>
    let resolver: UnsafeMutablePointer<uv_getaddrinfo_t>
    let resolvedIP: UnsafeMutablePointer<Int8>
    
    public init(request: URLRequest) {
        socket = UnsafeMutablePointer<uv_tcp_t>(allocatingCapacity: 1)
        connect = UnsafeMutablePointer<uv_connect_t>(allocatingCapacity: 1)
        addr = UnsafeMutablePointer<sockaddr_in>(allocatingCapacity: 1)
        writer = UnsafeMutablePointer<uv_write_t>(allocatingCapacity: 1)
        buffer = Buffer(data: request.data())
        readData = Data(string: "")
        hints = UnsafeMutablePointer<addrinfo>(allocatingCapacity: 1)
        resolver = UnsafeMutablePointer<uv_getaddrinfo_t>(allocatingCapacity: 1)
        resolvedIP = UnsafeMutablePointer<Int8>(allocatingCapacity: 17)
        self.request = request
    }
    
    deinit {
        socket.deallocateCapacity(1)
        connect.deallocateCapacity(1)
        addr.deallocateCapacity(1)
        writer.deallocateCapacity(1)
        hints.deallocateCapacity(1)
        resolvedIP.deallocateCapacity(17)
    }
    
    public func perform(callback: (error: ErrorProtocol?) -> ()) {
        
        self.callback = callback
        
        uv_tcp_init(EchoLoop.instance.loop, socket)
        
        resolveDNS()
    }
    
    func connect(addr: UnsafeMutablePointer<sockaddr_in>) {
        
//
        
        let add = UnsafeMutablePointer<sockaddr>(addr)
        
        io.tcp_connect(connect, socket, add) { (handle, status) in
            self.onConnection(handle: handle, status: status)
        }
    }
    
    func resolveDNS() {
        hints.pointee.ai_family = PF_INET;
        hints.pointee.ai_socktype = SOCK_STREAM;
        hints.pointee.ai_protocol = IPPROTO_TCP;
        hints.pointee.ai_flags = 0;
        let loop = EchoLoop.instance.loop
    
        let unmanaged = Unmanaged.passRetained(self)
        let opaque = OpaquePointer(bitPattern: unmanaged)
        let raw = UnsafeMutablePointer<Void>(opaque)
        
        resolver.pointee.data = raw
        
        uv_getaddrinfo(loop, resolver, on_resolved,
                       request.strippedHost(), "\(request.port)", hints);
    }
    
    func onResolved(resolver: UnsafeMutablePointer<uv_getaddrinfo_t>!,
                    status: Int32,
                    res: UnsafeMutablePointer<Foundation.addrinfo>!) {
        if status < 0 {
            uv_ip4_addr(request.host, Int32(request.port), self.addr)
            connect(addr: self.addr)
            return;
        }
        
        let addr = UnsafeMutablePointer<sockaddr_in>(res.pointee.ai_addr)!
        uv_ip4_name(addr, self.resolvedIP, 16)

        connect(addr: addr)
        uv_freeaddrinfo(res)
    }
    
    func onConnection(handle: UnsafeMutablePointer<uv_connect_t>!, status: Int) {
        if status == 0 {
            
            let stream = handle.pointee.handle
            
            io.write(writer, stream, buffer.raw, 1) { handle, size in
                print("written")
                print(try? self.request.data().toString())
            }
            
            io.read_start(stream, alloc_buffer) { stream, size, buffer in
                self.read(stream: stream, size: size, buffer: buffer)
            }
            
        } else {
            callback?(error: URLConnectionError.ConnectionFailed)
        }
    }
    
    func read(stream: UnsafeMutablePointer<uv_stream_t>!, size: Int, buffer: UnsafePointer<uv_buf_t>!) {
        readData.append(buffer.pointee.base, length: size)
        buffer.pointee.base.deallocateCapacity(size)
        
        if (size < 0) {
            print(try? readData.toString())
            uv_close(UnsafeMutablePointer<uv_handle_t>(stream), nil)
        }
    }
    
}