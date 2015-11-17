//A container for SimpleController
//(.free -> .remove)
x = Proto({

    var things = List();

    ~things = things;

    ~add = { |obj|
        things.add(obj);
    };

    ~remove = { |obj|
        things.remove(obj);
    };

    ~free = {
        ~things.do(_.remove);
    }

});

