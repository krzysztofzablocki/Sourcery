## I want to generate simple decorator for my type

In Swift it can be cumbersome to write a simple decorator that decorates all the calls to decorated type methods, you basically have to do it manually for each single method. With this template you can generate simple decorator that generate all the methods and property calls automatically, skipping methods and properties already implemented manually.

You can use this template as a starting point for mor sophisticated implementations. This template also shows you some powers of swift templates, like using helper methods and whitespace control tags.

### [Swift template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/Decorator.swifttemplate)

#### Available annotations

- `decorate` - what type to decorate
- `decorateMethod` - code to decorate each method call with
- `decorateGet` - code to decorate each property getter
- `decorateSet` - code to decorate each property setter

**Example input:**

```swift
protocol Service {
    var prop1: Int { get }
    var prop2: Int { get set }
    func foo(f: Int, _ a: Int) throws -> Int
    func bar(_ b: String)
}

// sourcery: decorate = "Service"
// sourcery: decorateMethod = "print(#function)"
// sourcery: decorateGet = "print("get: \(#function)")"
// sourcery: decorateSet = "print("set: \(#function)")"
struct ServiceDecorator: Service {
	// generated code will go here
}

extension ServiceDecorator {
	 // manually implemented method
    internal func bar(_ b: String) {
        decorated.bar(b)
    }

}

```

**Example output:**

```swift
...

// sourcery: decorate = Service
// sourcery: decorateMethod = print(#function)
// sourcery: decorateGet = "print("get: \(#function)")"
// sourcery: decorateSet = "print("set: \(#function)")"
struct ServiceDecorator: Service {

// sourcery:inline:auto:ServiceDecorator.autoDecorated
    internal private(set) var decorated: Service

    internal init(decorated: Service) {
        self.decorated = decorated
    }

    internal var prop1: Int {
        print("get: \(#function)")
        return decorated.prop1
    }

    internal var prop2: Int {
        get {
            print("get: \(#function)")
            return decorated.prop2
        }
        set {
            print("set: \(#function)")
            decorated.prop2 = newValue
        }
    }

    internal func foo(f: Int, _ a: Int) throws -> Int {
        print(#function)
        return try decorated.foo(f: f, a)
    }
// sourcery:end
}
...
```
