import Combine
import XCTest
@testable import SwiftEndpoint

final class Publisher_ValidateTests: XCTestCase {

  var subject: PassthroughSubject<Int, Error>!
  var validationFailure: Error?
  
  var didValidateValues: [Int]!
  var didReceiveValues: [Int]!
  var didComplete: Subscribers.Completion<Error>?
  
  var cancellables = Set<AnyCancellable>()
  
  override func setUp() {
    super.setUp()
    subject = PassthroughSubject()
    didValidateValues = []
    didReceiveValues = []
    subject
      .validate { value in
        self.didValidateValues.append(value)
        if let error = self.validationFailure {
			return .failure(error)
        }
		return .success(())
    }
    .sink(receiveCompletion: { completion in
      self.didComplete = completion
    }, receiveValue: { value in
      self.didReceiveValues.append(value)
    })
      .store(in: &cancellables)
  }
  
  override func tearDown() {
    super.tearDown()
    subject = nil
    validationFailure = nil
    didValidateValues = nil
    didReceiveValues = nil
    didComplete = nil
    cancellables.removeAll()
  }
  
  func testValidation() {
    subject.send(1337)
    XCTAssertEqual(didValidateValues, [1337])
    XCTAssertEqual(didReceiveValues, [1337])
    XCTAssertNil(didComplete)
  }
  
  func testValidationFailure() {
    validationFailure = NSError(domain: "", code: 0, userInfo: nil)
    subject.send(1337)
    XCTAssertEqual(didValidateValues, [1337])
    XCTAssertEqual(didReceiveValues, [])
    XCTAssertNotNil(didComplete)
    if case .failure(let error) = didComplete {
      XCTAssertEqual(error as NSError, validationFailure as NSError?)
    } else {
      XCTFail()
    }
  }

}
