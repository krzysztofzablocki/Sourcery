//
// Created by Krzysztof Zabłocki on 23/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class DiffableSpec: QuickSpec {
    override func spec() {
        describe ("DiffableResults") {
            var sut = DiffableResult()

            beforeEach {
                sut = DiffableResult()
            }

            describe("isEmpty") {
                context("given its empty") {
                    it("returns true") {
                        expect(sut.isEmpty).to(beTrue())
                    }
                }

                context("given its not empty") {
                    it("returns false") {
                        sut.append("Something")

                        expect(sut.isEmpty).to(beFalse())
                    }
                }
            }

            it("appends element") {
                sut.append("Expected value")

                expect("\(sut)").to(equal("Expected value"))
            }

            it("ads newline separator between elements") {
                sut.append("Value 1")
                sut.append("Value 2")

                expect("\(sut)").to(equal("Value 1\nValue 2"))
            }

            it("processes identifier for all elements") {
                sut.identifier = "Prefixed"
                sut.append("Value 1")
                sut.append("Value 2")

                expect("\(sut)").to(equal("Prefixed Value 1\nValue 2"))
            }

            it("joins 2 diffable results") {
                sut.append("Value 1")
                sut.append(contentsOf: DiffableResult(results: ["Value 2"]))

                expect("\(sut)").to(equal("Value 1\nValue 2"))
            }

            describe("trackDifference") {
                context("given not diffable elements") {
                    it("ads them if they aren't equal") {
                        sut.trackDifference(actual: 3, expected: 5)

                        expect("\(sut)").to(equal("<expected: 5, received: 3>"))
                    }

                    it("doesn't add them if they are equal") {
                        sut.trackDifference(actual: 3, expected: 3)

                        expect("\(sut)").to(equal(""))
                    }
                }

                context("given diffable elements") {
                    it("ads them if they aren't equal") {
                        sut.trackDifference(actual: Type(name: "Foo"), expected: Type(name: "Bar"))

                        expect("\(sut)").to(equal("localName <expected: Bar, received: Foo>"))
                    }

                    it("doesn't add them if they are equal") {
                        sut.trackDifference(actual: Type(name: "Foo"), expected: Type(name: "Foo"))

                        expect("\(sut)").to(equal(""))
                    }

                    context("given arrays") {
                        it("finds difference in count") {
                            sut.trackDifference(
                                    actual: [Type(name: "Foo")],
                                    expected: [Type(name: "Foo"), Type(name: "Foo2")])

                            expect("\(sut)").to(equal("Different count, expected: 2, received: 1"))
                        }

                        it("finds difference at given idx") {
                            sut.trackDifference(
                                    actual: [Type(name: "Foo"), Type(name: "Foo")],
                                    expected: [Type(name: "Foo"), Type(name: "Foo2")])

                            expect("\(sut)").to(equal("idx 1: localName <expected: Foo2, received: Foo>"))
                        }

                        it("finds difference at multiple idx") {
                            sut.trackDifference(
                                    actual: [Type(name: "FooBar"), Type(name: "Foo")],
                                    expected: [Type(name: "Foo"), Type(name: "Foo2")])

                            expect("\(sut)").to(equal("idx 0: localName <expected: Foo, received: FooBar>\nidx 1: localName <expected: Foo2, received: Foo>"))
                        }
                    }

                    context("given dictionaries") {
                        it("finds difference in count") {
                            sut.trackDifference(
                                    actual: ["Key": Type(name: "Foo")],
                                    expected: ["Key": Type(name: "Foo"), "Something": Type(name: "Bar")])

                            expect("\(sut)").to(equal("Different count, expected: 2, received: 1\nMissing keys: Something"))
                        }

                        it("finds difference at given key count") {
                            sut.trackDifference(
                                    actual: ["Key": Type(name: "Foo"), "Something": Type(name: "FooBar")],
                                    expected: ["Key": Type(name: "Foo"), "Something": Type(name: "Bar")])

                            expect("\(sut)").to(equal("key \"Something\": localName <expected: Bar, received: FooBar>"))
                        }
                    }
                }
            }
        }
    }
}
