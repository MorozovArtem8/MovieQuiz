import XCTest

@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let arra = [1,2,3,4,5]
        // When
        let value = arra[safe: 2]
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let arra = [1,2,3,4,5]
        // When
        let value = arra[safe: 7]
        //Then
        XCTAssertNil(value)
    }
}
