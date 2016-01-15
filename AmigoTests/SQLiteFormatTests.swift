//
//  SQLiteFormatTests.swift
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import XCTest
import Amigo

class SQLiteFormatTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEscapeNilWithQuotes() {
        let value: String? = nil
        let result = SQLiteFormat.escapeWithQuotes(value)
        XCTAssert(result == "NULL")
    }

    func testEscapeNilWithoutQuotes() {
        let value: String? = nil
        let result = SQLiteFormat.escapeWithoutQuotes(value)
        XCTAssert(result == "(NULL)")
    }

    func testEscapeWithQuotes() {
        let value = "test's"
        let result = SQLiteFormat.escapeWithQuotes(value)
        XCTAssert(result == "'test''s'")
    }

    func testEscapeWithoutQuotes() {
        let value = "test's"
        let result = SQLiteFormat.escapeWithoutQuotes(value)
        XCTAssert(result == "test''s")
    }
}
