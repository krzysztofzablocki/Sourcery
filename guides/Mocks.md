## I want to generate test mocks for protocols

_Contributed by [@marinbenc](http://twitter.com/marinbenc)_

#### For each protocol implementing `AutoMockable` protocol or [annotated](Writing%20templates.md#using-source-annotations) with `AutoMockable` annotation it will...
Create a class called `ProtocolNameMock` in which it will...

**For each function:**
 - Implement the function
 - Add a `functionCalled` boolean to check if the function was called
 - Add a `functionReceivedArguments` tuple to check the arguments that were passed to the function
 - Add a `functionReturnValue` variable and return it when the function is called.

**For each variable:**
 - Add a gettable and settable variable with the same name and type

#### Issues and limitations:
* Overloaded methods will produce compiler errors since the variables above the functions have the same name. Workaround: delete the variables on top of one of the functions, or rename them.
* Handling success/failure cases (for callbacks) is tricky to do automatically, so you have to do that yourself.
* This is **not** a full replacement for hand-written mocks, but it will get you 90% of the way there. Any more complex logic than changing return types, you will have to implement yourself. This only removes the most boring boilerplate you have to write.

### [Stencil template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/AutoMockable.stencil)

#### Example output:

```swift
class MockableServiceMock: MockableService {
    //MARK: - functionWithArguments
    var functionWithArgumentsCalled = false
    var functionWithArgumentsReceivedArguments: (firstArgument: String, onComplete: (String)-> Void)?

    //MARK: - functionWithCallback
    var functionWithCallbackCalled = false
    var functionWithCallbackReceivedArguments: (firstArgument: String, onComplete: (String)-> Void)?

    func functionWithCallback(_ firstArgument: String, onComplete: @escaping (String)-> Void) {
        functionWithCallbackCalled = true
        functionWithCallbackReceivedArguments = (firstArgument: firstArgument, onComplete: onComplete)
    }
  ...
```
