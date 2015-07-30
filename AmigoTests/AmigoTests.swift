//
//  AmigoTests.swift
//  AmigoTests
//
//  Created by Adam Venturella on 6/29/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import FMDB
import Amigo

class AmigoTests: AmigoTestBase {

    func testSelectRelated(){
        let select: Select
        let sql: String
        let query = amigo.query(People)
        query.selectRelated("dog", "cat")

        select = query.compile()
        sql = amigo.config.engine.compiler.compile(select)
        print(sql)
    }

    func testSelectValues(){
        let select: Select
        let sql: String
        let query = amigo.query(People)
        query.selectRelated("dog")
        query.values("id", "label", "dog.id")

        select = query.compile()
        sql = amigo.config.engine.compiler.compile(select)
        print(sql)
    }

//    func testMappingToModels(){
//        let done  = expectationWithDescription("done")
//        amigo.createAll()
//        amigo.execute("INSERT INTO amigotests_dog (label) VALUES ('lucy'), ('ollie');")
//
//        let query = self.amigo.query(Dog)
//
//        query.all{ (results:[Dog]) in
//            XCTAssert(results.count == 2)
//            XCTAssert(results[0].label == "lucy")
//            XCTAssert(results[1].label == "ollie")
//            done.fulfill()
//        }
//
//        waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//
//    func testMappingToModelsRelatedNil(){
//        let done  = expectationWithDescription("done")
//        amigo.createAll()
//
//        amigo.execute("INSERT INTO amigotests_dog (label) VALUES ('lucy'), ('ollie');")
//        amigo.execute("INSERT INTO amigotests_people (label, dog_id) VALUES ('Adam', 1), ('Danica', 2);")
//
//        let query = self.amigo.query(People)
//
//        query.all{ (results:[People]) in
//            XCTAssert(results.count == 2)
//            XCTAssertNil(results[0].dog)
//            XCTAssertNil(results[1].dog)
//            done.fulfill()
//        }
//
//        waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//
//    func testMappingToModelsRelatedNotNil(){
//        let done  = expectationWithDescription("done")
//        amigo.createAll()
//
//        amigo.execute("INSERT INTO amigotests_dog (label) VALUES ('lucy'), ('ollie');")
//        amigo.execute("INSERT INTO amigotests_people (label, dog_id) VALUES ('Adam', 1), ('Danica', 2);")
//
//        let query = self.amigo.query(People).selectRelated("dog")
//
//        query.all{ (results:[People]) in
//            XCTAssert(results.count == 2)
//            XCTAssertNotNil(results[0].dog)
//            XCTAssertNotNil(results[1].dog)
//            done.fulfill()
//        }
//
//        waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//
//    func testMappingToModelsMultipleRelatedNotNil(){
//        let done  = expectationWithDescription("done")
//        amigo.createAll()
//
//        amigo.execute("INSERT INTO amigotests_dog (label) VALUES ('lucy'), ('ollie');")
//        amigo.execute("INSERT INTO amigotests_cat (label) VALUES ('foo'), ('bar');")
//        amigo.execute("INSERT INTO amigotests_people (label, dog_id, cat_id) VALUES ('Adam', 1, 1), ('Danica', 2, 2);")
//
//        let query = self.amigo.query(People).selectRelated("dog", "cat")
//
//        query.all{ (results:[People]) in
//            XCTAssert(results.count == 2)
//            XCTAssertNotNil(results[0].dog)
//            XCTAssertNotNil(results[1].dog)
//            XCTAssertNotNil(results[0].cat)
//            XCTAssertNotNil(results[1].cat)
//            XCTAssert(results[0].cat.label == "foo")
//            done.fulfill()
//        }
//
//        waitForExpectationsWithTimeout(5.0, handler: nil)
//    }


    

    func testBlocks(){
        let queue = dispatch_queue_create("test.queue", nil)
        let background = dispatch_queue_create("test.backgrond", nil)

        dispatch_async(background){
            print("+++++++")
            dispatch_sync(queue){
                print("11111111")
                let x = 1
            }
            print("222222222")
        }
    }

    func testDelete(){
        let done  = expectationWithDescription("done")

        amigo.createAll()

        let session = self.amigo.session
        let o1 = Dog()

        o1.label = "lucy"
//        session.add(o1){
//            print(o1.id)
//            done.fulfill()
//        }
//        //session.commit()
//
//        amigo.query(Dog).get(1){
//            XCTAssertNotNil($0)
//
//            let x = o1.id
//            session.delete(o1)
//
//            self.amigo.query(Dog).get(1){
//                print($0)
//                XCTAssertNil($0)
//                done.fulfill()
//            }
//        }


//        let action : () -> () = {
//            let session = self.amigo.session
//            let o1 = Dog()
//
//            o1.label = "lucy"
//            session.add(o1)
//            session.commit()
//
//            self.amigo.query(Dog).get(1){
//                XCTAssertNotNil($0)
//                done.fulfill()
//            }
//        }
//
//        amigo.query(Dog).get(1){ dog in
//            XCTAssertNil(dog)
//            action()
//        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

//    func testGet(){
//        let done  = expectationWithDescription("done")
//
//        amigo.createAll()
//        amigo.execute("INSERT INTO amigotests_dog (label) VALUES ('lucy'), ('ollie');")
//
//        amigo.query(Dog).get(1){ dog in
//            if let dog = dog{
//                XCTAssertEqual(dog.id, 1)
//                XCTAssertEqual(dog.label, "lucy")
//                done.fulfill()
//            } else{
//                XCTFail()
//            }
//        }
//
//        waitForExpectationsWithTimeout(5.0, handler: nil)
//    }


















//
//    func x_testRemove() {
//        let session = amigo.session
//
//        let obj1 = session.new(Publication)
//        obj1.label = "This is a test"
//
//        var results = session.query(Publication).all()
//
//        print("-----> \(results.count)")
//        XCTAssert(results.count == 1)
//        session.delete(obj1)
//
//        results = session.query(Publication).all()
//        XCTAssert(results.count == 0)
//    }
//
//    func x_testCount(){
//        let session = amigo.session
//        let value = session.query(Post).count()
//        //print(value)
//    }
//
//    func x_testCreateRecord(){
//        let session = amigo.session
//        let author = session.new(Author)
//        let post = session.new(Post)
//
//        author.firstName = "Lucy"
//        author.lastName = "Bark-N-Woof"
//
//        post.title = "Walking Time!"
//        post.author = author
//
//        session.commit()
//    }

//    func x_testNonAmigoFetch(){
//        amigo.mainSession
//        let results: [Post]
//        let post: Post
//        let ctx = Amigo._mainManagedObjectContext
//        let request = NSFetchRequest(entityName: "Post")
//
//        //request.entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: ctx)
//        request.relationshipKeyPathsForPrefetching = ["author.firstName"]
//        request.returnsObjectsAsFaults = false
//        request.includesSubentities = true
//
//        do {
//            results = try ctx.executeFetchRequest(request) as! [Post]
//
//        } catch _{
//            results = []
//        }
//
//        post = results[0]
//        XCTAssert(true)
//    }

    func testDoStuff(){
//        let model = amigo.managedObjectModel
//        print("---------->")
//        //        print(model.entitiesByName)
//        print(model.entitiesByName["Post"])
//        print("---------->")
//
//        let p = NSPredicate(format: "Foo.Id = 1")
//
//        switch p{
//        case let expression as  NSComparisonPredicate:
//            print("\(expression) -> COMPARE")
//            print(expression.leftExpression.keyPath)
//
//        case let expression as NSCompoundPredicate:
//            print("\(expression) -> COMPOUND")
//        case let expression as NSExpression:
//            print("\(expression) -> EXPRESSION")
//        default: break
//        }

//        let compare = p as! NSComparisonPredicate
//        compare.leftExpression

        XCTAssert(true)
    }

//    func x_testForeignKey() {
//
//        var results: [Post]
//        var post: Post!
//        let session = amigo.session
//
//
//        results = session.query(Post).selectRelated("author").all()
//        //results = session.query(Post).all()
//        post = results[0]
//
//        XCTAssert(true)
////
//
////        print("-----> \(results.count)")
////        XCTAssert(results.count == 1)
////        session.delete(obj1)
////
////        results = session.query(Publication).all()
////        XCTAssert(results.count == 0)
//    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
