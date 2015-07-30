//
//  AmigoQuerySetTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/24/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo

class AmigoQuerySetTests: AmigoTestBase {


    func testMultipleForeignKeys(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let c1 = Cat()
        c1.label = "Ollie"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1
        p1.cat = c1

        session.add(p1)

        let people = session
            .query(People)
            .selectRelated("dog", "cat")
            .all()

        XCTAssertEqual(people.count, 1)
        XCTAssertNotNil(people[0].dog)
        XCTAssertNotNil(people[0].cat)
        XCTAssertEqual(people[0].dog.label, "Lucy")
        XCTAssertEqual(people[0].cat.label, "Ollie")
    }

    func testOrderByDifferentTable(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let d2 = Dog()
        d2.label = "Ollie"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1

        let p2 = People()
        p2.label = "Bar"
        p2.dog = d2

        session.add(p1)
        session.add(p2)

        let people = session
            .query(People)
            .selectRelated("dog")
            .orderBy("dog.label", ascending: false)
            .filter("dog.label = Lucy")
            .limit(1)
            .offset(1)
            .all()

        XCTAssertEqual(people.count, 2)
        XCTAssertEqual(people[0].id, 2)
        XCTAssertEqual(people[0].dog.label, "Ollie")
    }

    func testOrderBySameTable(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let d2 = Dog()
        d2.label = "Ollie"

        session.add(d1)
        session.add(d2)

        var dogs = session
            .query(Dog)
            .orderBy("label", ascending: false)
            .all()

        XCTAssertEqual(dogs.count, 2)
        XCTAssertEqual(dogs[0].id, 2)
        XCTAssertEqual(dogs[0].label, "Ollie")

        dogs = session
            .query(Dog)
            .orderBy("label")
            .all()

        XCTAssertEqual(dogs.count, 2)
        XCTAssertEqual(dogs[0].id, 1)
        XCTAssertEqual(dogs[0].label, "Lucy")
    }

    func testForeignKeyAutoSave(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let p1 = People()
        p1.label = "Ollie Cat"
        p1.dog = d1

        XCTAssertNil(session.query(Dog).get(1))

        session.add(p1)

        XCTAssertNotNil(session.query(Dog).get(1))
    }

    func testSelectRelated(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let p1 = People()
        p1.label = "Ollie Cat"
        p1.dog = d1

        session.add(p1)

        var person = session.query(People).get(1)!
        XCTAssertNil(person.dog)

        person = session
            .query(People)
            .selectRelated("dog")
            .get(1)!

        XCTAssertNotNil(person.dog)
        XCTAssertEqual(person.dog.label, "Lucy")
    }

    func testLimit(){
        let session = amigo.session

        let a1 = Author()
        a1.firstName = "Lucy"
        a1.lastName = "Dog"

        let a2 = Author()
        a2.firstName = "Ollie"
        a2.lastName = "Cat"

        session.add(a1)
        session.add(a2)

        let authors = session
            .query(Author)
            .limit(1)
            .all()

        XCTAssertEqual(authors.count, 1)
        XCTAssertEqual(authors[0].firstName, "Lucy")
        XCTAssertEqual(authors[0].lastName, "Dog")
    }

    func testOffset(){
        let session = amigo.session

        let a1 = Author()
        a1.firstName = "Lucy"
        a1.lastName = "Dog"

        let a2 = Author()
        a2.firstName = "Ollie"
        a2.lastName = "Cat"

        session.add(a1)
        session.add(a2)

        let authors = session
            .query(Author)
            .limit(1)
            .offset(1)
            .all()

        XCTAssertEqual(authors.count, 1)
        XCTAssertEqual(authors[0].firstName, "Ollie")
        XCTAssertEqual(authors[0].lastName, "Cat")
    }

    func testOneToMany(){

        let session = amigo.session

        let a1 = Author()
        a1.firstName = "Lucy"
        a1.lastName = "Dog"

        let a2 = Author()
        a2.firstName = "Ollie"
        a2.lastName = "Cat"
        
        let p1 = Post()
        p1.title = "The Story of Barking"
        p1.author = a1

        let p2 = Post()
        p2.title = "10 Things You Should Know When Chasing Squirrels"
        p2.author = a1

        let p3 = Post()
        p3.title = "The Story of Being a Cat"
        p3.author = a2

        session.add(a1)
        session.add(a2)
        session.add(p1)
        session.add(p2)
        session.add(p3)

        let posts = session.query(Post)
            .using(a1)
            .relationship("posts")
            .all()

        XCTAssertEqual(posts.count, 2)
    }

    func testAddManyToMany(){

        let session = amigo.session

        let p1 = Parent()
        p1.label = "foo"

        let p2 = Parent()
        p2.label = "bar"

        let c1 = Child()
        c1.label = "baz"

        session.add(p1)
        session.add(p2)
        session.add(c1)

        session.using(p1).relationship("children").add(c1)
        session.using(p2).relationship("children").add(c1)

        let parents = session
            .query(Parent)
            .using(c1)
            .relationship("parents")
            .all()

        XCTAssertEqual(parents.count, 2)
    }

    func testDeleteManyToMany(){

        let session = amigo.session

        let p1 = Parent()
        p1.label = "foo"

        let p2 = Parent()
        p2.label = "bar"

        let c1 = Child()
        c1.label = "baz"

        session.add(p1)
        session.add(p2)
        session.add(c1)

        session.using(p1).relationship("children").add(c1)
        session.using(p2).relationship("children").add(c1)

        var parents = session
            .query(Parent)
            .using(c1)
            .relationship("parents")
            .all()
        
        XCTAssertEqual(parents.count, 2)

        session.using(c1).relationship("parents").delete(p2)

        parents = session
            .query(Parent)
            .using(c1)
            .relationship("parents")
            .all()

        XCTAssertEqual(parents.count, 1)
        XCTAssertEqual(parents[0].label, "foo")
    }

    func testManyToManyThroughModelAddRejected(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        session.add(w1)
        session.add(e1)

        session.using(w1).relationship("exercises").add(e1)

    }

    func testManyToManyThroughModelAdd(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let w2 = Workout()
        w2.label = "bar"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        let e2 = WorkoutExercise()
        e2.label = "Push-Ups"

        let m1 = WorkoutMeta()
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        let m2 = WorkoutMeta()
        m2.workout = w1
        m2.exercise = e2
        m2.duration = 15
        m2.position = 2

        // intentionally add a new WorkoutMeta with
        // a different parent workout
        // so the id of the final WorkoutMeta will
        // not be consecutive
        let m3 = WorkoutMeta()
        m3.workout = w2
        m3.exercise = e2
        m3.duration = 60
        m3.position = 1

        let m4 = WorkoutMeta()
        m4.workout = w1
        m4.exercise = e2
        m4.duration = 25
        m4.position = 3

        session.add(w1)
        session.add(w2)
        session.add(e1)
        session.add(e2)
        session.add(m1)
        session.add(m2)
        session.add(m3)
        session.add(m4)

        let results = session
        // ensure we get back everything possible re: the selectRelated
        // you would likely only need "exercise" here not 
        // "exercise" and "workout" as we are `using(w1)` already
        // to generate the query.

        .query(WorkoutMeta)
        .using(w1)
        .selectRelated("exercise", "workout")
        .relationship("exercises")
        .orderBy("position", ascending: false)
        .all()

        XCTAssertEqual(results.count, 3)

        XCTAssertEqual(results[0].id, m4.id)
        XCTAssertEqual(results[0].duration, m4.duration)
        XCTAssertEqual(results[0].position, m4.position)
        XCTAssertNotNil(results[0].exercise)
        XCTAssertEqual(results[0].exercise.id, e2.id)
        XCTAssertEqual(results[0].exercise.label, e2.label)
        XCTAssertNotNil(results[0].workout)
        XCTAssertEqual(results[0].workout.id, w1.id)
        XCTAssertEqual(results[0].workout.label, w1.label)

        XCTAssertEqual(results[1].id, m2.id)
        XCTAssertEqual(results[1].duration, m2.duration)
        XCTAssertEqual(results[1].position, m2.position)
        XCTAssertNotNil(results[1].exercise)
        XCTAssertEqual(results[1].exercise.id, e2.id)
        XCTAssertEqual(results[1].exercise.label, e2.label)
        XCTAssertNotNil(results[1].workout)
        XCTAssertEqual(results[1].workout.id, w1.id)
        XCTAssertEqual(results[1].workout.label, w1.label)

        XCTAssertEqual(results[2].id, m1.id)
        XCTAssertEqual(results[2].duration, m1.duration)
        XCTAssertEqual(results[2].position, m1.position)
        XCTAssertNotNil(results[2].exercise)
        XCTAssertEqual(results[2].exercise.id, e1.id)
        XCTAssertEqual(results[2].exercise.label, e1.label)
        XCTAssertNotNil(results[2].workout)
        XCTAssertEqual(results[2].workout.id, w1.id)
        XCTAssertEqual(results[2].workout.label, w1.label)
    }

    func testManyToManyThroughModelDelete(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        let e2 = WorkoutExercise()
        e2.label = "Push-Ups"

        let m1 = WorkoutMeta()
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        let m2 = WorkoutMeta()
        m2.workout = w1
        m2.exercise = e2
        m2.duration = 15
        m2.position = 2

        let m3 = WorkoutMeta()
        m3.workout = w1
        m3.exercise = e2
        m3.duration = 25
        m3.position = 3


        session.add(w1)
        session.add(e1)
        session.add(e2)
        session.add(m1)
        session.add(m2)
        session.add(m3)

        var results = session
            .query(WorkoutMeta)
            .using(w1)
            .selectRelated("exercise")
            .relationship("exercises")
            .orderBy("position", ascending: false)
            .all()

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, m3.id)

        session.delete(m3)

        results = session
            .query(WorkoutMeta)
            .using(w1)
            .selectRelated("exercise")
            .relationship("exercises")
            .orderBy("position", ascending: false)
            .all()

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].id, m2.id)
    }

}
