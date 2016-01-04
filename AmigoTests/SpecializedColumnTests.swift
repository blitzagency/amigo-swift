//
//  SpecializedColumnTests.swift
//  Amigo
//
//  Created by Adam Venturella on 1/3/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import XCTest
import Amigo


class UUIDModel: AmigoModel{
    dynamic var id: Int = 0
    dynamic var objId: String!
}


class SpecializedColumnTests: XCTestCase {

    let amigo: Amigo = {

        let uuid = ORMModel(UUIDModel.self,
            IntegerField("id", primaryKey: true),
            UUIDField("objId", indexed: true, unique: true)
        )

        // now initialize Amigo
        let engine = SQLiteEngineFactory(":memory:", echo: true)
        let amigo = Amigo([uuid], factory: engine)
        amigo.createAll()
        
        return amigo
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUUIDColumn() {
        let objId = NSUUID().UUIDString
        let uuid = UUIDModel()
        uuid.objId = objId

        let session = amigo.session

        session.add(uuid)

        if let results = session.query(UUIDModel).all().first{
            XCTAssert(results.id == 1)
            XCTAssert(results.objId == objId)
        } else {
            XCTFail()
        }

    }

    func testUUIDColumnFilter() {
        let objId = NSUUID().UUIDString
        let uuid = UUIDModel()
        uuid.objId = objId

        let session = amigo.session

        session.add(uuid)

        let query = session
        .query(UUIDModel)
        .filter("objId = '\(objId)'")

        if let results = query.all().first{
            XCTAssert(results.id == 1)
            XCTAssert(results.objId == objId)
        } else {
            XCTFail()
        }
        
    }
}
