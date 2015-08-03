Querying
===================================

Querying with :code:`Amigo` is similar to querying with Django or
SQLAlchemy. Lets run though a few examples. In each of the following
examples we will assume we have already done our model mapping
and we have an :code:`amigo` instance available to us. For
more information on model mapping see: :doc:`models/index`


Get an object by id:
---------------------

:code:`get` returns an optional model as it may fail if the id
is not present.

.. code-block:: swift

    let session = amigo.session
    let maybeDog: Dog? = session.query(Dog).get(1)


Get all objects:
----------------------------------

:code:`all`

.. code-block:: swift

    let session = amigo.session
    let dogs: [Dog] = session.query(Dog).all()


Order objects:
----------------------------------

:code:`orderBy`

.. code-block:: swift

    let session = amigo.session
    let dogs: [Dog] = session
        .query(Dog)
        .orderBy("label", ascending: false) // by default ascending is true
        .all()


FIlter objects:
----------------------------------

:code:`filter`

.. code-block:: swift

    let session = amigo.session
    let dogs: [Dog] = session
        .query(Dog)
        .filter("id > 3")
        .all()


Full foreign key in 1 query
-----------------------------

:code:`selectRelated`

.. code-block:: swift

    let dog = ORMModel(Dog.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
    )

    // You can use the ORMModel
    let person = ORMModel(Person.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
        Column("dog", type: ForeignKey(dog))
    )

    let engine = SQLiteEngineFactory(":memory:", echo: true)
    amigo = Amigo([dog, person], factory: engine)
    amigo.createAll()

    let session = amigo.session

    let d1 = Dog()
    d1.label = "Lucy"

    let p1 = Person()
    p1.label = "Foo"
    p1.dog = d1

    session.add(d1, p1)

    let result = session
        .query(Person)
        .selectRelated("dog")
        .all()


Filter and Order By related fields
-----------------------------------

:code:`filter`
:code:`orderBy`

.. code-block:: swift

    let dog = ORMModel(Dog.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
    )

    // You can use the ORMModel
    let person = ORMModel(Person.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
        Column("dog", type: ForeignKey(dog))
    )

    let engine = SQLiteEngineFactory(":memory:", echo: true)
    amigo = Amigo([dog, person], factory: engine)
    amigo.createAll()

    let session = amigo.session

    let d1 = Dog()
    d1.label = "Lucy"

    let p1 = Person()
    p1.label = "Foo"
    p1.dog = d1

    session.add(d1, p1)

    let result = session
        .query(Person)
        .selectRelated("dog")
        .filter("id > 1 AND dog.id > 1") // note the dot notation
        .orderBy("dog.id", ascending: false) // note the dot notation
        .all()
