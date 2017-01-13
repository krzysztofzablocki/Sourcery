### AutoLenses
_Contributed by [@filip_zawada](http://twitter.com/filip_zawada)_

What are Lenses? Great explanation by @mbrandonw

This script assumes you follow swift naming convention, e.g. structs start with an upper letter.

### [Stencil template](AutoLenses.stencil)

### Available variable annotations:

- `skipHashing` allows you to skip variable from being compared.
- `includeInHashing` is only applied on enums and allows us to add some computed variable into hashing logic

### Example output:

```swift
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
  ...
```
