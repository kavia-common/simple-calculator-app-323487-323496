import XCTest
@testable import Calculator
final class CalculatorTests: XCTestCase {
  func testAdd() {
    let c = Calculator()
    XCTAssertEqual(c.add(2,3), 5)
  }
}
