// https://gist.github.com/ivanopcode/8251fce762c6206157ef6f545062b219
// https://gist.github.com/ivanopcode/376957326dd9ad87bcb28211d5781c9d
// MIT License
//
// Copyright (c) 2024 Ivan Oparin
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

/// # OrderedIDSet
///
/// `OrderedIDSet` представляет собой упорядоченное множество элементов, где уникальность элементов определяется их идентификатором `id`. Эта структура данных решает проблему, когда необходимо хранить коллекцию элементов с сохранением порядка вставки, обеспечивая при этом уникальность на основе бизнес-идентификатора, а не хэш-значения элемента.
///
/// В стандартной библиотеке Swift `Set` и `OrderedSet`(в пакете Swift Collections)  обеспечивают уникальность элементов на основе их хэш-значения, что может быть нежелательно, если требуется уникальность по определенному свойству, например, идентификатору. `OrderedIDSet` использует `Identifiable` протокол для определения уникальности элементов по их `id`, обеспечивая быстрый доступ и модификацию элементов.
///
/// ## Основные характеристики:
/// - **Упорядоченность**: Элементы сохраняют порядок вставки.
/// - **Уникальность по `id`**: Элементы уникальны на основе их идентификатора.
/// - **Быстрый доступ**: Использует `OrderedDictionary` для обеспечения эффективного доступа к элементам.
///
/// ## Пример использования:
/// ```swift
/// struct User: Identifiable, Hashable {
///     let id: Int
///     let name: String
/// }
///
/// var users = OrderedIDSet<User>()
/// users.insert(User(id: 1, name: "Alice"))
/// users.insert(User(id: 2, name: "Bob"))
/// ```
///
public struct OrderedIDSet<Element: Identifiable & Hashable> {
    /// Внутреннее хранилище элементов в виде упорядоченного словаря.
    @usableFromInline
    internal private(set) var _elements: OrderedDictionary<Element.ID, Element> = [:]
    
    /// Количество элементов в множестве.
    ///
    /// - Complexity: O(1)
    public var count: Int {
        _elements.count
    }
    
    /// Проверяет, является ли множество пустым.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        _elements.isEmpty
    }
    
    /// Представление содержимого этой коллекции только для чтения в виде значения массива.
    ///
    /// - Complexity: O(1)
    public var elements: Array<Element> {
        _elements.values.elements
    }
    
    /// Возвращает последний элемент упорядоченного множества.
    ///
    /// Если упорядоченное множество пусто, возвращает nil.
    ///
    /// - Complexity: O(1)
    public var last: Element? {
        _elements.values.last
    }
    
    /// Инициализатор с перечислением элементов.
    ///
    /// - Parameter elements: Элементы для добавления в множество.
    ///
    /// - Complexity: O(*n*), где *n* — количество элементов.
    public init(elements: Element...) {
        for element in elements {
            _elements[element.id] = element
        }
    }
    
    /// Инициализатор с массивом элементов.
    ///
    /// - Parameter elements: Массив элементов для добавления в множество.
    ///
    /// - Complexity: O(*n*), где *n* — количество элементов.
    public init(elements: [Element]) {
        for element in elements {
            _elements[element.id] = element
        }
    }
    
    /// Вставляет элемент в множество.
    ///
    /// - Parameter element: Элемент для вставки.
    /// - Returns: Кортеж, содержащий флаг успешной вставки и элемент после вставки.
    ///
    /// - Complexity: Амортизированная O(1)
    @discardableResult
    public mutating func insert(_ element: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let existingElement = _elements[element.id] {
            return (false, existingElement)
        } else {
            _elements[element.id] = element
            return (true, element)
        }
    }
    
    /// Обновляет элемент в множестве.
    ///
    /// - Parameter newMember: Новый элемент для обновления.
    /// - Returns: Старый элемент, если он существовал.
    ///
    /// - Complexity: Амортизированная O(1)
    // periphery:ignore
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        let oldMember = _elements.updateValue(newMember, forKey: newMember.id)
        return oldMember
    }
    
    /// Обновляет множество с помощью последовательности элементов.
    ///
    /// - Parameter elements: Последовательность элементов для обновления.
    ///
    /// - Complexity: O(*n*), где *n* — количество элементов в последовательности.
    public mutating func update<S: Sequence>(with elements: S) where S.Element == Element {
        for item in elements {
            _elements.updateValue(item, forKey: item.id)
        }
    }
    
    /// Удаляет элемент из множества.
    ///
    /// - Parameter member: Элемент для удаления.
    /// - Returns: Удаленный элемент, если он существовал.
    ///
    /// - Complexity: Амортизированная O(1)
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        return _elements.removeValue(forKey: member.id)
    }
    
    /// Удаляет элемент из множества.
    ///
    /// - Parameter member: Элемент для удаления.
    /// - Returns: Удаленный элемент, если он существовал.
    ///
    /// - Complexity: Амортизированная O(1)
    @discardableResult
    public mutating func remove(byId memberId: Element.ID) -> Element? {
        return _elements.removeValue(forKey: memberId)
    }
    
    /// Удаляет элементы из коллекции по предоставленному массиву идентификаторов.
    ///
    /// - Parameter ids: Массив идентификаторов элементов, которые необходимо удалить.
    ///
    /// - Complexity: O(k), где k - количество идентификаторов в массиве `ids`.
    ///   Для каждого идентификатора операция удаления выполняется за O(1).
    public mutating func removeItems(withIDs ids: [Element.ID]) {
        for id in ids {
            _elements.removeValue(forKey: id)
        }
    }
    
    /// Удаляет все элементы, удовлетворяющие заданному условию.
    ///
    /// - Parameter shouldBeRemoved: Замыкание, определяющее, должен ли элемент быть удален.
    ///
    /// - Complexity: O(*n*), где *n* — количество элементов в множестве.
    public mutating func removeAll(where shouldBeRemoved: (Element) -> Bool) {
        for key in _elements.keys {
            if let element = _elements[key], shouldBeRemoved(element) {
                _elements.removeValue(forKey: key)
            }
        }
    }
    
    /// Удаляет все элементы из множества.
    ///
    /// После вызова этого метода множество становится пустым.
    ///
    /// - Complexity: O(1)
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        _elements.removeAll(keepingCapacity: keepCapacity)
    }
    
    /// Проверяет, содержит ли множество заданный элемент.
    ///
    /// - Parameter element: Элемент для проверки.
    /// - Returns: `true`, если элемент существует в множестве, иначе `false`.
    ///
    /// - Complexity: O(1)
    public func contains(_ element: Element) -> Bool {
        _elements.keys.contains(element.id)
    }
}

extension OrderedIDSet {
    /// Сортирует элементы коллекции на месте в соответствии с предоставленным замыканием сравнения.
    ///
    /// - Parameter areInIncreasingOrder: Замыкание, которое определяет порядок сортировки.
    ///   Возвращает `true`, если первый элемент должен располагаться перед вторым
    ///   в отсортированной последовательности.
    ///
    /// - Complexity: O(n log n), где n - количество элементов в коллекции.
    // periphery:ignore
    mutating func sort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        let sortedElements = self.elements.sorted(by: areInIncreasingOrder)
        self = OrderedIDSet(elements: sortedElements)
    }
}

extension OrderedIDSet {
    /// Инициализатор для создания пустого множества
    ///
    /// Этот инициализатор эквивалентен инициализации с помощью пустого литерала массива.
    ///
    /// - Complexity: O(1)
    @inlinable
    public init() {
        _elements = [:]
    }
}

extension OrderedIDSet {
    // periphery:ignore
    /// Группирует элементы по заданному ключу.
    ///
    /// - Parameter keyForValue: Функция, возвращающая ключ для группировки каждого элемента.
    /// - Returns: Словарь, где ключи — результаты функции `keyForValue`, а значения — массивы элементов.
    ///
    /// - Complexity: O(*n*), где *n* — количество элементов в множестве.
    public func grouping<Key: Hashable>(by keyForValue: (Element) -> Key) -> [Key: [Element]] {
        var groupedDictionary: [Key: [Element]] = [:]
        
        for element in self {
            let key = keyForValue(element)
            groupedDictionary[key, default: []].append(element)
        }
        
        return groupedDictionary
    }
}

extension OrderedIDSet {
    /// Предоставляет доступ к элементу коллекции по его идентификатору.
    ///
    /// - Parameter id: Идентификатор искомого элемента.
    /// - Returns: Элемент с указанным идентификатором, если он существует; в противном случае `nil`.
    ///
    /// - Complexity: O(1)
    // periphery:ignore
    public subscript(id id: Element.ID) -> Element? {
        return _elements[id]
    }
}

internal extension OrderedIDSet {
    mutating func updateElements(_ elements: OrderedDictionary<Element.ID, Element>) {
        _elements = elements
    }
    
    mutating func updateElementById(_ elementId: Element.ID, element: Element) {
        _elements[elementId] = element
    }
}


extension OrderedIDSet: Equatable where Element: Equatable {}
extension OrderedIDSet: Hashable where Element: Hashable {}

//
//  OrderedIDSet+Collection.swift
import OrderedCollections

extension OrderedIDSet: Collection {
    /// Тип индекса для коллекции.
    public typealias Index = OrderedDictionary<Element.ID, Element>.Index
    
    /// Начальный индекс коллекции.
    public var startIndex: Index {
        _elements.elements.startIndex
    }
    
    /// Конечный индекс коллекции.
    public var endIndex: Index {
        _elements.elements.endIndex
    }
    
    /// Возвращает индекс после указанного.
    ///
    /// - Parameter i: Текущий индекс.
    /// - Returns: Следующий индекс в последовательности.
    public func index(after i: Index) -> Index {
        _elements.elements.index(after: i)
    }
    
    /// Возвращает элемент по индексу.
    ///
    /// - Parameter position: Индекс элемента.
    /// - Returns: Элемент по указанному индексу.
    public subscript(position: Index) -> Element {
        _elements.elements[position].value
    }
}


extension OrderedIDSet: ExpressibleByArrayLiteral {
    /// Инициализатор для создания множества из литерала массива.
    ///
    /// - Parameter elements: Элементы для добавления.
    ///
    /// - Complexity: O(*n*), где *n* — количество элементов.
    public init(arrayLiteral elements: Element...) {
        for element in elements {
            updateElementById(element.id, element: element)
        }
    }
}


import OrderedCollections

/// Расширение OrderedIDSet для реализации протокола RandomAccessCollection.
/// RandomAccessCollection позволяет осуществлять произвольный доступ к элементам коллекции
/// с константным временем O(1).
extension OrderedIDSet: RandomAccessCollection {
    /// Определяет тип индексов, используемый для доступа к элементам коллекции.
    public typealias Indices = OrderedDictionary<Element.ID, Element>.Values.Indices
    
    /// Возвращает индекс, непосредственно предшествующий указанному индексу.
    ///
    /// - Parameter i: Действительный индекс коллекции.
    /// - Returns: Индекс, находящийся непосредственно перед `i`.
    ///
    /// - Complexity: O(1)
    public func index(before i: Index) -> Index {
        _elements.values.index(before: i)
    }
    
    /// Возвращает индекс, смещенный на указанное расстояние от заданного индекса.
    ///
    /// - Parameters:
    ///   - i: Действительный индекс коллекции.
    ///   - distance: Величина смещения от индекса `i`.
    /// - Returns: Индекс, смещенный на расстояние `distance` от индекса `i`.
    ///
    /// - Complexity: O(1)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        _elements.values.index(i, offsetBy: distance)
    }
    
    /// Возвращает расстояние между двумя индексами.
    ///
    /// - Parameters:
    ///   - start: Начальный индекс.
    ///   - end: Конечный индекс.
    /// - Returns: Количество элементов между индексами `start` и `end`.
    ///
    /// - Complexity: O(1)
    public func distance(from start: Index, to end: Index) -> Int {
        _elements.values.distance(from: start, to: end)
    }
}

//
//  OrderedIDSet+RangeReplaceableCollection.swift

import OrderedCollections

extension OrderedIDSet: RangeReplaceableCollection {
    /// Заменяет элементы в указанном диапазоне новыми элементами.
    ///
    /// - Parameters:
    ///   - subrange: Диапазон для замены.
    ///   - newElements: Новые элементы для вставки.
    ///
    /// - Complexity: O(*m*) в среднем, где *m* — общее количество элементов в диапазоне и новых элементах.
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Index>,
        with newElements: C
    ) where C.Element == Element {
        
        var updatedDict = OrderedDictionary<Element.ID, Element>()
        
        // Копируем элементы до subrange
        for index in startIndex..<subrange.lowerBound {
            let element = self[index]
            updatedDict[element.id] = element
        }
        
        // Вставляем новые элементы
        for element in newElements {
            updatedDict[element.id] = element
        }
        
        // Копируем элементы после subrange
        for index in subrange.upperBound..<endIndex {
            let element = self[index]
            updatedDict[element.id] = element
        }
        
        updateElements(updatedDict)
    }
}

extension OrderedIDSet: Sequence {
    /// Создает итератор для перебора элементов множества.
    ///
    /// - Returns: Итератор по элементам множества.
    ///
    /// - Complexity: O(1)
    public func makeIterator() -> AnyIterator<Element> {
        var iterator = _elements.values.makeIterator()
        return AnyIterator {
            return iterator.next()
        }
    }
}

extension OrderedIDSet {
    /// Returns an `OrderedIDSet` containing the non-`nil` results of calling
    /// the given transformation with each element of this `OrderedIDSet`.
    ///
    /// - Parameter transform: A closure that accepts an element of this
    ///   `OrderedIDSet` as its argument and returns an optional value.
    /// - Returns: An `OrderedIDSet` of the non-`nil` results of calling
    ///   `transform` with each element of the `OrderedIDSet`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of this `OrderedIDSet`.
    @inlinable
    public func compactMap<Transformed>(
        _ transform: (Element) throws -> Transformed?
    ) rethrows -> OrderedIDSet<Transformed> where Transformed: Identifiable & Hashable {
        var newSet = OrderedIDSet<Transformed>()
        for element in self {
            if let transformed = try transform(element) {
                newSet.insert(transformed)
            }
        }
        return newSet
    }
}

// unchecked untill OrderedDictionary conforms to Sendable
extension OrderedIDSet: @unchecked Sendable {}
