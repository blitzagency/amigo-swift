Querying
===================================

Querying with :code:`Amigo` is similar to querying with Django or
SQLAlchemy. Lets run though a few examples. In each of the following
examples we will assume we have already done our model mapping
and we have an :code:`amigo` instance available to us. For
more information on model mapping see: :doc:`/models/index`


Get an object by id
---------------------

:code:`get` returns an optional model as it may fail if the id
is not present.

.. code-block:: swift

    let session = amigo.session
    let maybeDog: Dog? = session.query(Dog).get(1)


Get all objects
----------------------------------

:code:`all`

.. code-block:: swift

    let session = amigo.session
    let dogs: [Dog] = session.query(Dog).all()


Order objects
----------------------------------

:code:`orderBy`

.. code-block:: swift

    let session = amigo.session
    let dogs: [Dog] = session
        .query(Dog)
        .orderBy("label", ascending: false) // by default ascending is true
        .all()


Filter objects
----------------------------------

:code:`filter`

.. code-block:: swift

    let session = amigo.session
    let dogs: [Dog] = session
        .query(Dog)
        .filter("id > 3")
        .all()

.. note ::

    Filter strings are converted into a :code:`NSPredicate` behind the
    scenes. When using the :code:`SQLiteEngine`, the constant params are
    extracted and replaced with `?` in generated query. The params are
    then passed to FMDB for escaping/replacement.


Full foreign key in one query (aka JOIN)
----------------------------------------

:code:`selectRelated`

See :ref:`foreign-key` for more.

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


One-To-Many Query
-----------------------------------

:code:`relationship`

See :ref:`one-to-many` for more.

.. code-block:: swift

    let session = amigo.session
    var results = session
        .query(People)
        .using(d1)
        .relationship("people")
        .all()


Many-To-Many Query
-----------------------------------

:code:`relationship`

See :ref:`many-to-many` for more.

.. code-block:: swift

    let session = amigo.session
    var results = session
        .query(Child)
        .using(p1)
        .relationship("children")
        .all()

