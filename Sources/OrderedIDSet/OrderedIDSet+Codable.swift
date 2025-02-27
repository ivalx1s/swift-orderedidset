// MIT License
//
// Copyright (c) 2025 Ivan Oparin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import OrderedCollections

extension OrderedIDSet: Encodable where Element: Encodable {
    /// Encodes the elements of this ordered set into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: Any error thrown by the encoder.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the ordered set.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element)
        }
    }
}

extension OrderedIDSet: Decodable where Element: Decodable {
    /// Creates a new ordered set by decoding from the given decoder.
    ///
    /// This initializer decodes the ordered set from an unkeyed container.
    /// Elements with duplicate IDs will be handled according to the OrderedIDSet
    /// insertion rules (later elements with the same ID are ignored).
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: Any error thrown by the decoder.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the encoded sequence.
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        
        while !container.isAtEnd {
            let element = try container.decode(Element.self)
            elements.append(element)
        }
        
        self.init(elements: elements)
    }
}
