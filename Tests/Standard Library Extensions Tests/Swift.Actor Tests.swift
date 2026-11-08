import Testing

@testable import Standard_Library_Extensions

actor Counter {
    var count = 0

    func increment() { count += 1 }
    func value() -> Int { count }

    enum Failure: Swift.Error { case belowZero }

    func decrement() throws(Failure) {

        guard count > 0 else { throw .belowZero }
        count -= 1
    }
}

actor Observer {
    func read(_ counter: Counter) async -> Int {
        await counter.value()
    }
}

final class Box {
    var value: Int
    init(_ value: Int) { self.value = value }
}

actor Holder {
    let stored = Box(42)
    func getStored() -> Box { stored }
}

struct UniqueResource: ~Copyable, Sendable {
    let id: Int
}

struct Handle: ~Copyable {
    let fd: Int32
}

actor ResourceFactory {
    private var counter = 0

    func make() -> UniqueResource {
        counter += 1
        return UniqueResource(id: counter)
    }

    func open() -> Handle {
        counter += 1
        return Handle(fd: Int32(counter))
    }

    enum Failure: Swift.Error { case depleted }

    func makeOrFail() throws(Failure) -> UniqueResource {
        guard counter < 5 else { throw .depleted }
        counter += 1
        return UniqueResource(id: counter)
    }
}

@Suite
struct `Actor - run sync` {

    @Test
    func `Synchronous multi-step access`() async {
        let counter = Counter()

        await counter.run { counter in
            counter.increment()
            counter.increment()
            counter.increment()
            #expect(counter.value() == 3)
        }
    }

    @Test
    func `Returns Sendable value across isolation boundary`() async {
        let counter = Counter()

        let result = await counter.run { counter in
            counter.increment()
            return counter.value()
        }

        #expect(result == 1)
    }

    @Test
    func `Propagates typed error`() async {
        let counter = Counter()

        await #expect(throws: Counter.Failure.belowZero) {
            try await counter.run { counter in
                try counter.decrement()
            }
        }
    }

    @Test
    func `No interleaving during run`() async {
        let counter = Counter()

        await counter.run { counter in
            for _ in 0..<100 {
                counter.increment()
            }
        }

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    await counter.run { counter in
                        let before = counter.value()
                        counter.increment()
                        let after = counter.value()
                        #expect(after - before == 1)
                    }
                }
            }
        }

        #expect(await counter.value() == 110)
    }
}

@Suite
struct `Actor - run async` {

    @Test
    func `Cross-actor call inside run`() async {
        let counter = Counter()
        let observer = Observer()

        await counter.run { counter in
            counter.increment()
            counter.increment()

            let observed = await observer.read(counter)
            #expect(observed == 2)
        }
    }

    @Test
    func `Returns value from async closure`() async {
        let counter = Counter()
        let observer = Observer()

        let result = await counter.run { counter in
            counter.increment()
            return await observer.read(counter)
        }

        #expect(result == 1)
    }

    @Test
    func `Propagates typed error from async closure`() async {
        let counter = Counter()
        let observer = Observer()

        await #expect(throws: Counter.Failure.belowZero) {
            try await counter.run { counter in

                _ = await observer.read(counter)
                try counter.decrement()
            }
        }
    }
}

@Suite
struct `Actor - sending return` {

    @Test
    func `Non-Sendable value constructed inline`() async {
        let holder = Holder()

        let box = await holder.run { _ in
            Box(7)
        }

        #expect(box.value == 7)
    }

    @Test
    func `Non-Sendable tuple constructed inline`() async {
        let holder = Holder()

        let (a, b) = await holder.run { _ in
            (Box(1), Box(2))
        }

        #expect(a.value == 1)
        #expect(b.value == 2)
    }

    @Test
    func `Non-Sendable array constructed inline`() async {
        let holder = Holder()

        let boxes = await holder.run { _ in
            (0..<5).map { Box($0) }
        }

        #expect(boxes.count == 5)
        #expect(boxes[3].value == 3)
    }

}

@Suite
struct `Actor - noncopyable sync` {

    @Test
    func `Returns Sendable noncopyable resource`() async {
        let factory = ResourceFactory()

        let resource = await factory.run { factory in
            factory.make()
        }

        #expect(resource.id == 1)
    }

    @Test
    func `Returns non-Sendable noncopyable handle`() async {
        let factory = ResourceFactory()

        let handle = await factory.run { factory in
            factory.open()
        }

        #expect(handle.fd == 1)
    }

    @Test
    func `Typed throws with noncopyable return`() async {
        let factory = ResourceFactory()

        await #expect(throws: ResourceFactory.Failure.depleted) {

            for _ in 0..<6 {
                _ = try await factory.run { factory in
                    try factory.makeOrFail()
                }
            }
        }
    }

    @Test
    func `Multi-step producing noncopyable result`() async {
        let factory = ResourceFactory()

        let resource = await factory.run { factory in

            _ = factory.make()
            _ = factory.make()

            return factory.make()
        }

        #expect(resource.id == 3)
    }
}

@Suite
struct `Actor - noncopyable async` {

    @Test
    func `Cross-actor call with noncopyable return`() async {
        let factory = ResourceFactory()
        let observer = Observer()

        let resource = await factory.run { factory in
            _ = await observer.read(Counter())
            return factory.make()
        }

        #expect(resource.id == 1)
    }
}
