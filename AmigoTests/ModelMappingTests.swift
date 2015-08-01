//
//  ModelMappingTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/31/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import Amigo

class ModelMappingTests: XCTestCase {
    var amigo: Amigo!

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOneToMany() {
        let dog = ORMModel(Dog.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            OneToMany("people", using: People.self, on: "dog")
        )

        let people = ORMModel(People.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog", type: ForeignKey(dog))
        )

        let engine = SQLiteEngineFactory(":memory:", echo: true)
        amigo = Amigo([dog, people], factory: engine)
        amigo.createAll()

        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1

        let p2 = People()
        p2.label = "Bar"
        p2.dog = d1

        session.add(d1, p1, p2)

        var results = session
            .query(People)
            .using(d1)
            .relationship("people")
            .all()

        XCTAssertEqual(results.count, 2)

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
