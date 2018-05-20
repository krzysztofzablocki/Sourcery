## I want to generate `Equatable` implementation


Template used to generate equality for all types that either conform to the `AutoEquatable` protocol or are [annotated](Writing%20templates.md#using-source-annotations) with `AutoEquatable` annotation, allowing us to avoid writing boilerplate code.

It adds `:Equatable` conformance to all types, except protocols (because it would require turning them into PAT's).
For protocols it's just generating `func ==`.

### [Stencil template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/AutoEquatable.stencil)

#### Available variable annotations:

- `skipEquality` allows you to skip variable from being compared.
- `arrayEquality` mark this to use array comparsion for variables that have array of items that don't implement `Equatable` but have `==` operator e.g. Protocols

#### Example output:

```swift
// MARK: - AdNodeViewModel AutoEquatable
extension AdNodeViewModel: Equatable {}

internal func == (lhs: AdNodeViewModel, rhs: AdNodeViewModel) -> Bool {
    guard lhs.remoteAdView == rhs.remoteAdView else { return false }
    guard lhs.hidesDisclaimer == rhs.hidesDisclaimer else { return false }
    guard lhs.type == rhs.type else { return false }
    guard lhs.height == rhs.height else { return false }

    guard lhs.attributedDisclaimer == rhs.attributedDisclaimer else { return false }

    return true
}
```
