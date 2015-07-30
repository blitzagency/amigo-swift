//
//  AmigoSessionTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/23/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest

class AmigoSessionTests: AmigoTestBase {

    func testNestedTransactions(){
        let done  = expectationWithDescription("done")
        let queue = dispatch_queue_create("tests.queue", nil)

        amigo.createAll()

        let dog = amigo.query(Dog).get(1)
        let session = amigo.session

        XCTAssertNil(dog)

        let o1 = Dog()
        o1.label = "lucy"

        session.add(o1)

        dispatch_async(queue){
            let session = self.amigo.session

            var results = self.amigo.query(Dog).all()

            XCTAssert(results.count == 1)

            let o2 = Dog()
            o2.label = "ollie"

            session.add(o2)

            results = self.amigo.query(Dog).all()

            XCTAssert(results.count == 2)

            session.rollback()
            results = self.amigo.query(Dog).all()

            XCTAssert(results.count == 1)

            done.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testInsert(){

        XCTAssertNil(amigo.query(Dog).get(1))

        let session = amigo.session
        let o1 = Dog()
        o1.label = "lucy"

        XCTAssertNil(o1.id)

        session.add(o1)

        XCTAssertNotNil(o1.id)
        XCTAssertNotNil(amigo.query(Dog).get(1))
    }

    func testDelete(){
        let session = amigo.session
        let o1 = Dog()

        o1.label = "lucy"

        session.add(o1)

        XCTAssertNotNil(amigo.query(Dog).get(1))

        session.delete(o1)
        XCTAssertNil(amigo.query(Dog).get(1))
    }

    func testUpdate(){
        XCTAssertNil(amigo.query(Dog).get(1))

        let session = amigo.session
        let o1 = Dog()
        o1.label = "lucy"

        XCTAssertNil(o1.id)

        session.add(o1)

        o1.label = "ollie"

        session.add(o1)

        let dog = amigo.query(Dog).get(1)
        XCTAssertEqual(dog!.label, "ollie")
    }

    func testUpdateFromNoForeignKey(){

        let session = amigo.session

        let p1 = People()
        p1.label = "foo"

        let d1 = Dog()
        d1.label = "lucy"

        session.add(p1)

        XCTAssertEqual(p1.id, 1)
        XCTAssertNil(d1.id)

        p1.dog = d1

        session.add(p1)

        XCTAssertNotNil(d1.id)
        XCTAssertEqual(d1.id, 1)

    }

    func testUpdateWithNewForeignKey(){

        let session = amigo.session

        let p1 = People()
        p1.label = "foo"

        let d1 = Dog()
        d1.label = "lucy"

        let d2 = Dog()
        d2.label = "ollie"

        p1.dog = d1

        session.add(p1)
        session.add(d1)
        session.add(d2)

        var result = session
            .query(People)
            .selectRelated("dog")
            .get(1)!

        XCTAssertNotNil(result.dog)
        XCTAssertEqual(result.dog.id, d1.id)

        result.dog = d2
        session.add(result)

        result = session
            .query(People)
            .selectRelated("dog")
            .get(1)!

        XCTAssertNotNil(result.dog)
        XCTAssertEqual(result.dog.id, d2.id)
    }
    
}
