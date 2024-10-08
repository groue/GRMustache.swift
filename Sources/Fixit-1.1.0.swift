// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


@available(*, unavailable, message:"Use nil instead.")
public func Box() -> MustacheBox { return .empty }

extension Template {
    @available(*, unavailable, renamed:"register(_:forKey:)")
    public func registerInBaseContext(_ key: String, _ value: Any?) { }
}

extension Context {
    @available(*, unavailable, renamed:"mustacheBox(forKey:)")
    public func mustacheBoxForKey(_ key: String) -> MustacheBox { return .empty }

    @available(*, unavailable, renamed:"mustacheBox(forExpression:)")
    public func mustacheBoxForExpression(_ string: String) throws -> MustacheBox { return .empty }

    @available(*, unavailable, renamed:"extendedContext(withRegisteredValue:forKey:)")
    func contextWithRegisteredKey(_ key: String, box: MustacheBox) -> Context { return self }
}

extension MustacheBox {
    @nonobjc @available(*, unavailable, renamed:"mustacheBox(forKey:)")
    public func mustacheBoxForKey(_ key: String) -> MustacheBox { return .empty }
}
