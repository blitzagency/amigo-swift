//
//  SQLiteCompilerTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
@testable import Amigo

class SQLiteCompilerTests: XCTestCase {

    var engine: SQLiteEngineFactory!
    var meta: MetaData!
    
    override func setUp() {
        super.setUp()

        meta = MetaData()
        engine = SQLiteEngine(":memory:")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    var amigo: Amigo{
        let name = "App"
        let bundle = NSBundle(forClass: self.dynamicType)
        let url = NSURL(string:bundle.pathForResource(name, ofType: "momd")!)!
        let mom = NSManagedObjectModel(contentsOfURL: url)!
        let engine = SQLiteEngineFactory(":memory:", echo: true)

        return Amigo(mom, factory: engine)
    }

    func testCreateTable() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("name", type: String.self)
        )

        let sql = engine.compiler.compile(CreateTable(t1))
        let expected = "CREATE TABLE IF NOT EXISTS dogs (" +
              "\n\t" + "id INTEGER PRIMARY KEY NOT NULL," +
              "\n\t" + "name TEXT NULL" +
                "\n" + ");"

        XCTAssertEqual(sql, expected)
    }

    func testCreateTableWithIndex() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("name", type: String.self),
            Column("color", type: String.self),
            Index("dogs_name_idx", "name"),
            Index("dogs_color_idx", "color")
        )
        
        let sql = engine.compiler.compile(CreateTable(t1))
        let expected = "CREATE TABLE IF NOT EXISTS dogs (" +
            "\n\t" + "id INTEGER PRIMARY KEY NOT NULL," +
            "\n\t" + "name TEXT NULL," +
            "\n\t" + "color TEXT NULL" +
            "\n" + ");" +
            "\n" + "CREATE INDEX IF NOT EXISTS dogs_name_idx ON dogs (name);" +
            "\n" + "CREATE INDEX IF NOT EXISTS dogs_color_idx ON dogs (color);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnOptional() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self)
        )

        let sql = engine.compiler.compile(CreateColumn(t1.c["id"]!))
        let expected = "id INTEGER NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnRequired() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, optional: false)
        )

        let sql = engine.compiler.compile(CreateColumn(t1.c["id"]!))
        let expected = "id INTEGER NOT NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnPrimaryKey() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true)
        )

        let sql = engine.compiler.compile(CreateColumn(t1.c["id"]!))
        let expected = "id INTEGER PRIMARY KEY NOT NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnForeignKeyOptional() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: String.self, primaryKey: true)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("dog_id", type: ForeignKey(t1))
        )

        XCTAssertEqual(t2.indexes.count, 1)

        let column = engine.compiler.compile(CreateColumn(t2.c["dog_id"]!))
        let index = engine.compiler.compile(CreateIndex(t2.indexes[0]))
        let expectedColumn = "dog_id TEXT NULL"
        let expectedIndex = "CREATE INDEX IF NOT EXISTS people_dog_id_idx ON people (dog_id);"

        XCTAssertEqual(column, expectedColumn)
        XCTAssertEqual(index, expectedIndex)
    }

    func testCreateColumnForeignKeyRequired() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: String.self, primaryKey: true)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("dog_id", type: ForeignKey(t1), optional:false)
        )

        let sql = engine.compiler.compile(CreateColumn(t2.c["dog_id"]!))
        let expected = "dog_id TEXT NOT NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexImplicit() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, indexed: true)
        )

        let sql = engine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexSingle() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self),
            Index("dogs_id_idx", "id")
        )

        let sql = engine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexMultiple() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self),
            Column("label", type: String.self),
            Index("dogs_id_idx", "id", "label")
        )

        let sql = engine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id, label);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexUnique() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self),
            Column("label", type: String.self),
            Index("dogs_id_idx", unique: true, "id")
        )

        let sql = engine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE UNIQUE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateJoin() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1))
        )

        let join = t2.join(t1)
        let sql = engine.compiler.compile(join)
        let expected = "LEFT JOIN dogs ON people.dog_id = dogs.id"

        XCTAssertEqual(sql, expected)
    }

    func testCreateSelect() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let select = Select(t1)
        let sql = engine.compiler.compile(select)
        let expected = "SELECT dogs.id, dogs.label" +
                "\n" + "FROM dogs;"

        XCTAssertEqual(sql, expected)
    }

    func testCreateSelectSingleJoin() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1))
        )

        let j1 = t2.join(t1)
        let select = Select(t2, t1).selectFrom(j1)

        let sql = engine.compiler.compile(select)

        let expected = "SELECT people.id, people.label, people.dog_id, dogs.id, dogs.label" +
                "\n" + "FROM people" +
                "\n" + "LEFT JOIN dogs ON people.dog_id = dogs.id;"


        XCTAssertEqual(sql, expected)
    }

    func testCreateSelectMultipleJoin() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t2 = Table("cats", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t3 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1)),
            Column("cat_id", type: ForeignKey(t2))
        )

        let j1 = t3.join(t1)
        let j2 = t3.join(t2)
        let select = Select(t3, t1, t2).selectFrom(j1, j2)


        let sql = engine.compiler.compile(select)

        let expected = "SELECT people.id, people.label, people.dog_id, people.cat_id, dogs.id, dogs.label, cats.id, cats.label" +
                "\n" + "FROM people" +
                "\n" + "LEFT JOIN dogs ON people.dog_id = dogs.id" +
                "\n" + "LEFT JOIN cats ON people.cat_id = cats.id;"

        XCTAssertEqual(sql, expected)
    }

    func testComparisionPredicateColumns() {
        let query = amigo.query(Dog).filter("id = label")
        if let(sql, params) = query.compileFilter(){
            XCTAssertEqual("amigotests_dog.id = amigotests_dog.label", sql)
            print(sql)
            print(params)
            XCTAssert(params.count == 0)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateEqual() {
        let query = amigo.query(Dog).filter("id = 1")
        if let(sql, params) = query.compileFilter(){
            XCTAssertEqual("amigotests_dog.id = ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateGreaterThan() {
        let query = amigo.query(Dog).filter("id > 1")
        if let(sql, params) = query.compileFilter(){
            XCTAssertEqual("amigotests_dog.id > ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateGreaterThanEqual() {
        let query = amigo.query(Dog).filter("id >= 1")
        if let(sql, params) = query.compileFilter(){
            XCTAssertEqual("amigotests_dog.id >= ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateLessThan() {
        let query = amigo.query(Dog).filter("id < 1")
        if let(sql, params) = query.compileFilter(){
            XCTAssertEqual("amigotests_dog.id < ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateLessThanEqual() {
        let query = amigo.query(Dog).filter("id <= 1")
        if let(sql, params) = query.compileFilter(){
            XCTAssertEqual("amigotests_dog.id <= ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateForeignKey() {
        let query = amigo.query(People).selectRelated("dog").filter("dog.id = 1")
        if let(sql, params) = query.compileFilter(){
            XCTAssertEqual("amigotests_dog.id = ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testCompoundPredicate() {
        // (id > 1 AND id < 20) OR id == 22 OR (id == 26 AND id != 15)
        let query = amigo.query(Dog).filter("id > 1 && id < 20 || id = 22 OR id = 26 AND id != 15")

        //let query = amigo.query(Dog).filter("id > 1 and id < 20")

        if let(sql, params) = query.compileFilter(){
            let expected = "(amigotests_dog.id > ? AND amigotests_dog.id < ?) OR amigotests_dog.id = ? OR (amigotests_dog.id = ? AND amigotests_dog.id != ?)"
            XCTAssertEqual(expected, sql)
            XCTAssert(params.count == 5)
            XCTAssert(params.map{$0.integerValue} == [1, 20, 22, 26, 15])
        } else {
            XCTFail()
        }
    }

}
