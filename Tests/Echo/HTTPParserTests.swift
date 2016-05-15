//
//  HTTPParserTests.swift
//  Echo
//
//  Created by Elliott Minns on 14/05/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import XCTest
@testable import Echo

class HTTPParserTests: XCTestCase {
    
    var httpString: String = ""
    var buffer: Buffer!
    var parser: HTTPParser!

    override func setUp() {
        super.setUp()
        httpString = "GET / HTTP/1.1\r\nHost: localhost:4001\r\nUser-Agent: curl/7.43.0\r\nAccept: */*\r\n\r\n"
        buffer = Buffer(string: httpString)
        parser = HTTPParser(buffer: buffer)
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testParsingWorks() {
        let request = try? parser.parse()
        XCTAssertNotNil(request)
    }
    
    func testParsingWorksMethod() {
        let request = try? parser.parse()
        XCTAssertNotNil(request)
        
        if let request = request {
            XCTAssertEqual(request.method, HTTPMethod.GET)
        }
    }
    
    func testParsingWorksHeader() {
        let request = try? parser.parse()
        XCTAssertNotNil(request)
        
        if let request = request {
            XCTAssertEqual(request.headers.count, 3)
            XCTAssertEqual(request.headers["Host"], "localhost:4001")
            XCTAssertEqual(request.headers["User-Agent"], "curl/7.43.0")
            XCTAssertEqual(request.headers["Accept"], "*/*")
        }
    }
    
    func testParsingWorksPath() {
        if let request = try? parser.parse() {
            XCTAssertEqual(request.path, "/")
        }
    }
    
    func testParsingWorksProtocol() {
        if let request = try? parser.parse() {
            XCTAssertEqual(request.httpProtocol, "HTTP/1.1")
        }
    }

}
