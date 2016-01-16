Setup
=================================


Carthage
----------------------------------

FMDB (https://github.com/ccgus/fmdb),
as of v 2.6 FMDB, does suport Carthage.

Drop this into your :code:`Cartfile`:

::

    github "blitzagency/amigo-swift" ~> 0.3.0

Admittedly, we are probably not the best at the whole,
*"How do you share an Xcode Project"* thing, so any recommendations
to imporve this process are welcome.



Initialization Using A Closure
----------------------------------

Initialize Amigo into a global variable so all the initialization
is done in one place:

 .. code-block:: swift

    import Amigo


    class Dog: AmigoModel{
        dynamic var id = 0
        dynamic var label = ""
    }

    let amigo: Amigo = {
        let dog = ORMModel(Dog.self,
            IntegerField("id", primaryKey: true),
            CharField("label")
        )

        // now initialize Amigo
        // specifying 'echo: true' will have amigo print out
        // all of the SQL commands it's generating.
        let engine = SQLiteEngineFactory(":memory:", echo: true)
        let amigo = Amigo([dog], factory: engine)
        amigo.createAll()

        return amigo
    }()


.. note::

    This creates the :code:`amigo` object lazily, which means it's not
    created until it's actually needed. This delays the initial
    output of the app information details. Because of this,
    we recommend forcing the :code:`amigo` object to be created
    at app launch by just referencing :code:`amigo` at the top of
    your :code:`didFinishLaunching` method if you don't
    already use the :code:`amigo` object for something on app launch.
    This style and description was taken directly from [XCGLogger]_



Contents:

.. toctree::
   :maxdepth: 2

   engine


.. [XCGLogger] XCGLogger Closure Initialization
   https://github.com/DaveWoodCom/XCGLogger#initialization-using-a-closure
