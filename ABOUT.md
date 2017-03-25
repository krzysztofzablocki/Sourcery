## What is Sourcery?
_**Sourcery** scans your source code, applies your personal templates and generates Swift code for you, allowing you to use meta-programming techniques to save time and decrease potential mistakes._

Using it offers many benefits:

- Write less repetitive code and make it easy to adhere to [DRY principle](https://en.wikipedia.org/wiki/Don't_repeat_yourself).
- It allows you to create better code, one that would be hard to maintain without it, e.g. [performing automatic property level difference in tests](https://github.com/krzysztofzablocki/Sourcery/blob/master/Sourcery/Templates/Diffable.stencil)
- Limits the risk of introducing human error when refactoring.
- Sourcery **doesn't use runtime tricks**, in fact, it allows you to leverage compiler, even more, creating more safety.
- **Immediate feedback:** Sourcery features built-in daemon support, enabling you to write your templates in real-time side-by-side with generated code.

**Sourcery is so meta that it is used to code-generate its boilerplate code**

## Why?

Swift features very limited runtime and no meta-programming features. Which leads our projects to contain boilerplate code.

Sourcery exists to allow Swift developers to stop doing the same thing over and over again while still maintaining strong typing, preventing bugs and leveraging compiler.

Have you ever?

- Had to write equatable/hashable?
- Had to write NSCoding support?
- Had to implement JSON serialization?
- Wanted to use Lenses?

If you did then you probably found yourself writing repetitive code to deal with those scenarios, does this feel right?

Even worse, if you ever add a new property to a type all of those implementations have to be updated, or you will end up with bugs.
In those scenarios usually **compiler will not generate the error for you**, which leads to error prone code.

