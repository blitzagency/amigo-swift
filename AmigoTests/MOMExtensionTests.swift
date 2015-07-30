//
//  MOMExtensionTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/14/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo

class MOMExtensionTests: XCTestCase {

    var mom: NSManagedObjectModel!

    override func setUp() {
        super.setUp()
        let name = "App"
        let bundle = NSBundle(forClass: self.dynamicType)
        let url = NSURL(string:bundle.pathForResource(name, ofType: "momd")!)!
        mom = NSManagedObjectModel(contentsOfURL: url)!

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDependencyList() {
        let list = mom.buildDependencyList()

        let author = mom.entitiesByName["Author"]!
        let cat = mom.entitiesByName["Cat"]!
        let dog = mom.entitiesByName["Dog"]!
        let people = mom.entitiesByName["People"]!
        let post = mom.entitiesByName["Post"]!
        let publication = mom.entitiesByName["Publication"]!

        //[Post: [Author, Publication], Dog: [], Author: [], People: [Cat, Dog], Cat: [], Publication: []]

        XCTAssert(list[author]!.count == 0)
        XCTAssert(list[post]!.count == 2)
        XCTAssert(list[people]!.count == 2)
        XCTAssert(list[publication]!.count == 0)
        XCTAssert(list[dog]!.count == 0)
        XCTAssert(list[cat]!.count == 0)
    }

    func testTopologicalSort() {

        let list = mom.buildDependencyList()
        let sorted = mom.topologicalSort(list)

        let author = mom.entitiesByName["Author"]!
        let cat = mom.entitiesByName["Cat"]!
        let dog = mom.entitiesByName["Dog"]!
        let people = mom.entitiesByName["People"]!
        let post = mom.entitiesByName["Post"]!
        let publication = mom.entitiesByName["Publication"]!

        // [Author, Cat, Dog, People, Publication, Post]
        let expected = [author, cat, dog, people, publication, post]
        XCTAssert(sorted == expected)

    }
    
}
