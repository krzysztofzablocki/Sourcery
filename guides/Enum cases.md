## I want to list all cases in an enum

Generate `count` and `allCases` for any enumeration that is marked with `AutoCases` phantom protocol.

### [Stencil Template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/AutoCases.stencil)

#### Example output:

```swift
extension BetaSettingsGroup {
  static var count: Int { return 8 }

  static var allCases: [BetaSettingsGroup] {
    return [
      .featuresInDevelopment,
      .advertising,
      .analytics,
      .marketing,
      .news,
      .notifications,
      .tech,
      .appInformation
    ]
  }
}
```
