## I want to generate `Hashable` implementation

Template used to generate hashing for all types that conform to `:AutoHashable`, allowing us to avoid writing boilerplate code.

It adds `:Hashable` conformance to all types, except protocols (because it would require turning them into PAT's).
For protocols it's just generating `var hashValue` comparator.

### [Stencil template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/AutoHashable.stencil)

#### Available variable annotations:

- `skipHashing` allows you to skip variable from being compared.
- `includeInHashing` is only applied on enums and allows us to add some computed variable into hashing logic

#### Example output:

```swift
// MARK: - AdNodeViewModel AutoHashable
extension AdNodeViewModel: Hashable {

    internal var hashValue: Int {
        return combineHashes(remoteAdView.hashValue, hidesDisclaimer.hashValue, type.hashValue, height.hashValue, attributedDisclaimer.hashValue, 0)
    }
}
```