import XCTest
@testable import OrderedIDSet

final class OrderedIDSetTests: XCTestCase {
    
    struct TestElement: Identifiable, Hashable {
        let id: Int
        let value: String
    }
    
    func testEmptyInitialization() {
        let emptySet = OrderedIDSet<TestElement>()
        XCTAssertTrue(emptySet.isEmpty)
        XCTAssertEqual(emptySet.count, 0)
    }
    
    func testInitializationWithElements() {
        let element1 = TestElement(id: 1, value: "One")
        let element2 = TestElement(id: 2, value: "Two")
        let set = OrderedIDSet(elements: element1, element2)
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set.elements, [element1, element2])
    }
    
    func testInsert() {
        var set = OrderedIDSet<TestElement>()
        let element1 = TestElement(id: 1, value: "One")
        
        // вставка нового
        let result1 = set.insert(element1)
        XCTAssertTrue(result1.inserted)
        XCTAssertEqual(set.count, 1)
        
        // вставка дубликата
        let result2 = set.insert(element1)
        XCTAssertFalse(result2.inserted)
        XCTAssertEqual(set.count, 1)
        
        // вставка еще одного нового
        let element2 = TestElement(id: 2, value: "Two")
        let result3 = set.insert(element2)
        XCTAssertTrue(result3.inserted)
        XCTAssertEqual(set.count, 2)
    }
    
    func testUpdate() {
        var set = OrderedIDSet<TestElement>()
        let element1 = TestElement(id: 1, value: "One")
        let element2 = TestElement(id: 1, value: "Uno") // дубликат по id
        
        // обнолвние в пустом сете
        let oldElement1 = set.update(with: element1)
        XCTAssertNil(oldElement1)
        XCTAssertEqual(set.count, 1)
        
        // обновление существуюшего
        let oldElement2 = set.update(with: element2)
        XCTAssertEqual(oldElement2?.value, "One")
        XCTAssertEqual(set.count, 1)
        XCTAssertEqual(set[id: element1.id]?.value, "Uno")
    }
    
    func testUpdateWithSequence() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two")
        ]
        
        set.update(with: elements)
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set.elements, elements)
        
        let newElements = [
            TestElement(id: 2, value: "Deux"),
            TestElement(id: 3, value: "Three")
        ]
        set.update(with: newElements)
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set[id: 2]?.value, "Deux")
        XCTAssertNotNil(set[id: 3])
    }
    
    func testRemove() {
        var set = OrderedIDSet<TestElement>()
        let element1 = TestElement(id: 1, value: "One")
        let element2 = TestElement(id: 2, value: "Two")
        
        set.insert(element1)
        set.insert(element2)
        
        // удаление существующего
        let removedElement = set.remove(element1)
        XCTAssertEqual(removedElement, element1)
        XCTAssertEqual(set.count, 1)
        XCTAssertFalse(set.contains(element1))
        
        // удаление не существующего
        let removedElementNil = set.remove(element1)
        XCTAssertNil(removedElementNil)
        XCTAssertEqual(set.count, 1)
    }
    
    func testRemoveByID() {
        var set = OrderedIDSet<TestElement>()
        let element = TestElement(id: 1, value: "One")
        set.insert(element)
        
        let removedElement = set.remove(byId: 1)
        XCTAssertEqual(removedElement, element)
        XCTAssertEqual(set.count, 0)
    }
    
    func testRemoveItemsWithIDs() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two"),
            TestElement(id: 3, value: "Three")
        ]
        set.update(with: elements)
        
        set.removeItems(withIDs: [1, 3])
        XCTAssertEqual(set.count, 1)
        XCTAssertNil(set[id: 1])
        XCTAssertNotNil(set[id: 2])
        XCTAssertNil(set[id: 3])
    }
    
    func testRemoveAllWhere() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two"),
            TestElement(id: 3, value: "Three")
        ]
        set.update(with: elements)
        
        set.removeAll { $0.id % 2 == 0 } // удалить четные
        XCTAssertEqual(set.count, 2)
        XCTAssertNotNil(set[id: 1])
        XCTAssertNil(set[id: 2])
        XCTAssertNotNil(set[id: 3])
    }
    
    func testContains() {
        var set = OrderedIDSet<TestElement>()
        let element = TestElement(id: 1, value: "One")
        set.insert(element)
        
        XCTAssertTrue(set.contains(element))
        
        let otherElement = TestElement(id: 2, value: "Two")
        XCTAssertFalse(set.contains(otherElement))
    }
    
    func testSubscriptByID() {
        var set = OrderedIDSet<TestElement>()
        let element = TestElement(id: 1, value: "One")
        set.insert(element)
        
        let retrievedElement = set[id: element.id]
        XCTAssertEqual(retrievedElement, element)
        
        let nonExistentElement = set[id: 2]
        XCTAssertNil(nonExistentElement)
    }
    
    func testIteration() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two"),
            TestElement(id: 3, value: "Three")
        ]
        set.update(with: elements)
        
        var iteratedElements: [TestElement] = []
        for element in set {
            iteratedElements.append(element)
        }
        
        XCTAssertEqual(iteratedElements, elements)
    }
    
    func testSorting() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 3, value: "Three"),
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two")
        ]
        set.update(with: elements)
        
        set.sort { $0.id < $1.id }
        XCTAssertEqual(set.elements.map { $0.id }, [1, 2, 3])
    }
    
    func testRandomAccessCollectionConformance() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two"),
            TestElement(id: 3, value: "Three")
        ]
        set.update(with: elements)
        
        XCTAssertEqual(set.startIndex, 0)
        XCTAssertEqual(set.endIndex, 3)
        XCTAssertEqual(set[0], elements[0])
        XCTAssertEqual(set[1], elements[1])
        XCTAssertEqual(set[2], elements[2])
        
        let index = set.index(set.startIndex, offsetBy: 2)
        XCTAssertEqual(set[index], elements[2])
    }
    
    func testEquatableConformance() {
        let element1 = TestElement(id: 1, value: "One")
        let element2 = TestElement(id: 2, value: "Two")
        
        var set1 = OrderedIDSet<TestElement>()
        set1.insert(element1)
        set1.insert(element2)
        
        var set2 = OrderedIDSet<TestElement>()
        set2.insert(element1)
        set2.insert(element2)
        
        XCTAssertEqual(set1, set2)
        
        set2.remove(element2)
        XCTAssertNotEqual(set1, set2)
    }
    
    func testHashableConformance() {
        let element1 = TestElement(id: 1, value: "One")
        let element2 = TestElement(id: 2, value: "Two")
        
        var set1 = OrderedIDSet<TestElement>()
        set1.insert(element1)
        set1.insert(element2)
        
        var set2 = OrderedIDSet<TestElement>()
        set2.insert(element1)
        set2.insert(element2)
        
        let dict: [OrderedIDSet<TestElement>: String] = [set1: "First"]
        XCTAssertEqual(dict[set2], "First")
    }
    
    func testExpressibleByArrayLiteral() {
        let element1 = TestElement(id: 1, value: "One")
        let element2 = TestElement(id: 2, value: "Two")
        
        let set: OrderedIDSet<TestElement> = [element1, element2]
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set.elements, [element1, element2])
    }
    
    func testGrouping() {
        let elements = [
            TestElement(id: 1, value: "Odd"),
            TestElement(id: 2, value: "Even"),
            TestElement(id: 3, value: "Odd"),
            TestElement(id: 4, value: "Even")
        ]
        let set = OrderedIDSet(elements: elements)
        
        let grouped = set.grouping { $0.id % 2 == 0 ? "Even" : "Odd" }
        XCTAssertEqual(grouped["Even"]?.count, 2)
        XCTAssertEqual(grouped["Odd"]?.count, 2)
    }
    
    func testRemoveAll() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two")
        ]
        set.update(with: elements)
        
        set.removeAll()
        XCTAssertTrue(set.isEmpty)
        XCTAssertEqual(set.count, 0)
    }
    
    func testLastProperty() {
        var set = OrderedIDSet<TestElement>()
        XCTAssertNil(set.last)
        
        let element1 = TestElement(id: 1, value: "One")
        let element2 = TestElement(id: 2, value: "Two")
        set.insert(element1)
        set.insert(element2)
        
        XCTAssertEqual(set.last, element2)
    }
    
    func testIndexing() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two"),
            TestElement(id: 3, value: "Three")
        ]
        set.update(with: elements)
        
        let index = set.firstIndex { $0.id == 2 }
        XCTAssertEqual(index, 1)
        XCTAssertEqual(set[index!], elements[1])
    }
    
    func testReplaceSubrange() {
        var set = OrderedIDSet<TestElement>()
        let elements = [
            TestElement(id: 1, value: "One"),
            TestElement(id: 2, value: "Two"),
            TestElement(id: 3, value: "Three")
        ]
        set.update(with: elements)
        
        let newElements = [
            TestElement(id: 2, value: "Deux"),
            TestElement(id: 4, value: "Four")
        ]
        set.replaceSubrange(1...2, with: newElements)
        
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set.elements.map { $0.id }, [1, 2, 4])
        XCTAssertEqual(set[id: 2]?.value, "Deux")
    }
}
