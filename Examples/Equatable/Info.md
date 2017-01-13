## AutoEquatable
Template used to generate equality for all types that conform to `:AutoEquatable`, allowing us to avoid writing boilerplate code.

It adds `:Equatable` conformance to all types, except protocols (because it would require turning them into PAT's), for protocols it generates `func ==`

### [Stencil template](AutoEquatable.stencil)

### Available variable annotations:

- `arrayEquality` will cause the comparsion to go over each item in an array and perform `==` on them, this is useful when a type has `==` operator but doesn't implement `Equatable` e.g. Protocols
- `skipEquality` allows you to skip variable from being compared.

### Example output:

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
