// swiftlint:disable variable_name
infix operator *~: MultiplicationPrecedence
infix operator |>: AdditionPrecedence

struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
}

func * <A, B, C> (lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return Lens<A, C>(
        get: { a in rhs.get(lhs.get(a)) },
        set: { (c, a) in lhs.set(rhs.set(c, lhs.get(a)), a) }
    )
}

func *~ <A, B> (lhs: Lens<A, B>, rhs: B) -> (A) -> A {
    return { a in lhs.set(rhs, a) }
}

func |> <A, B> (x: A, f: (A) -> B) -> B {
    return f(x)
}

func |> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

extension House {
  static let roomsLens = Lens<House, Room>(
    get: { $0.rooms },
    set: { rooms, house in
       House(rooms: rooms, address: house.address, size: house.size)
    }
  )
  static let addressLens = Lens<House, String>(
    get: { $0.address },
    set: { address, house in
       House(rooms: house.rooms, address: address, size: house.size)
    }
  )
  static let sizeLens = Lens<House, Int>(
    get: { $0.size },
    set: { size, house in
       House(rooms: house.rooms, address: house.address, size: size)
    }
  )
}
extension Person {
  static let nameLens = Lens<Person, String>(
    get: { $0.name },
    set: { name, person in
       Person(name: name)
    }
  )
}
extension Rectangle {
  static let xLens = Lens<Rectangle, Int>(
    get: { $0.x },
    set: { x, rectangle in
       Rectangle(x: x, y: rectangle.y)
    }
  )
  static let yLens = Lens<Rectangle, Int>(
    get: { $0.y },
    set: { y, rectangle in
       Rectangle(x: rectangle.x, y: y)
    }
  )
}
extension Room {
  static let peopleLens = Lens<Room, [Person]>(
    get: { $0.people },
    set: { people, room in
       Room(people: people, name: room.name)
    }
  )
  static let nameLens = Lens<Room, String>(
    get: { $0.name },
    set: { name, room in
       Room(people: room.people, name: name)
    }
  )
}
