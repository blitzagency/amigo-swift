Sessions
=================================


When you go though :code:`amigo.session` using the provided
:code:`SQLiteEngine` you automatically begin a SQL Transaction.

If you would like your information to actually be persisted you must
:code:`commit` the transaction. Once committed, the session will
automatically begin a new transaciton for you.


.. code-block:: swift

    import Amigo

    class Dog: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!
    }

    class Person: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!
        dynamic var dog: Dog!
    }

    let dog = ORMModel(Dog.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
        OneToMany("people", using: Person.self, on: "dog")
    )

    let person = ORMModel(Person.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
        Column("dog", type: ForeignKey(dog))
    )

    let engine = SQLiteEngineFactory(":memory:", echo: true)
    amigo = Amigo([dog, person], factory: engine)
    amigo.createAll()

    let session = amigo.session
    let d1 = Dog()
    let d2 = Dog()

    d1.label = "Lucy"
    d2.label = "Ollie"

    session.add(d1, d2)
    session.commit()

