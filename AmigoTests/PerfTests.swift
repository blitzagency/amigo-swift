//
//  PerfTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/28/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import Amigo
import CoreData

class PerfTests: XCTestCase {

    var amigo: Amigo!
    var engine: SQLiteEngineFactory!

    override func setUp() {
        super.setUp()
        let name = "App"
        let bundle = NSBundle(forClass: self.dynamicType)
        let url = NSURL(string:bundle.pathForResource(name, ofType: "momd")!)!
        let mom = NSManagedObjectModel(contentsOfURL: url)!

        engine = SQLiteEngineFactory(":memory:")
        amigo = Amigo(mom, factory: engine)
        amigo.createAll()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        (amigo.config.engine as! SQLiteEngine).db.close()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        let session = amigo.session
        var statements = [String]()
        measureBlock{
            for _ in 0..<10000{
                let d = Dog()
                d.label = "foo"

                session.add(d)
            }

            session.commit()
        }
    }

    func testBatchCreateItems() {
        var statements = [String]()

        self.measureBlock{
            for _ in 0..<10000{
                let d = Dog()
                d.label = "foo"
                statements.append("INSERT INTO amigotests_dog (label) VALUES ('foo');")
            }
        }

    }

    func testBatchJoinItem() {
        var statements = [String]()

        for _ in 0..<20000{
            let d = Dog()
            d.label = "foo"
            statements.append("INSERT INTO amigotests_dog (label) VALUES ('foo');")
        }

        self.measureBlock{
            statements.joinWithSeparator("\n")
        }
        
    }

    func testBatchMerge() {
        let a1 = [1, 2]
        let a2 = [3, 4]
        var out = [Int]()

        out.appendContentsOf(a1)
        out.appendContentsOf(a2)

        print(out)

        
    }

}
