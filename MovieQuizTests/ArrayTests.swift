
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        let array = [1, 1, 2, 3, 5]
        let value = array[2]
        
        //XCTAssertNil(value)
        XCTAssertEqual(value, 2)
    }
    
   
    
    func testGetOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]
        let value = array[safe: 20]
        
        XCTAssertNil(value)
        
    }
}
