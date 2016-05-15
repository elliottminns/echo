//
//  Address.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

struct Address {

	let raw: UnsafeMutablePointer<sockaddr_in>

 	init(address: String, port: Int) throws  {

        let socketAddress = UnsafeMutablePointer<sockaddr_in>.alloc(1)

        socketAddress.memory.sin_family = sa_family_t(AF_INET)
        socketAddress.memory.sin_port = Address.htons(port: in_port_t(port))
        socketAddress.memory.sin_len = __uint8_t(sizeof(sockaddr_in))
        socketAddress.memory.sin_addr = in_addr(s_addr: inet_addr(address))
        socketAddress.memory.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)

        self.raw = socketAddress
    }
    
    static func htons(port port: in_port_t) -> in_port_t {
        let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return isLittleEndian ? _OSSwapInt16(port) : port
    }
}