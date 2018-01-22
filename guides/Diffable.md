## I want to have diffing in tests

Template used to generate much better output when using equality in tests, instead of having to read wall of text it's used to generate precise property level differences. This template uses [Sourcery Diffable implementation](../SourceryRuntime/Sources/Diffable.swift)

from this:
<img width="600" alt="before" src="https://cloud.githubusercontent.com/assets/1468993/21425370/0e3dd990-c849-11e6-877a-6dc80ae8f039.png">

to this:
<img width="373" alt="after" src="https://cloud.githubusercontent.com/assets/1468993/21425376/11e9ad94-c849-11e6-882a-e7927a3b2b08.png">


### [Stencil Template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Sourcery/Templates/Diffable.stencil)

#### Available annotations:

- `skipEquality` allows you to skip variable from being compared.
