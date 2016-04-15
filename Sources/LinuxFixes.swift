//
//  LinuxFixes.swift
//  Echo
//
//  Created by Elliott Minns on 15/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation

#if os(Linux)
    extension String {
        func components(separatedBy sep: String ) -> [String] {
            var out = [String]()
            
            withCString { (bytes) in
                sep.withCString { (sbytes) in
                    var bytes = UnsafeMutablePointer<Int8>(bytes)
                    
                    while true {
                        let start = strstr(bytes, sbytes) - UnsafeMutablePointer<Int8>(bytes)
                        if start < 0 {
                            out.append(String(cString: bytes))
                            break
                        }
                        bytes[start] = 0
                        out.append(String(cString: bytes))
                        bytes += start + Int(strlen( sbytes ))
                    }
                }
            }
            
            return out
        }
    }
#endif