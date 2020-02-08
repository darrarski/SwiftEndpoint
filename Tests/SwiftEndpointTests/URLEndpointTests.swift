import Combine
import XCTest
@testable import SwiftEndpoint

final class URLEndpointTests: XCTestCase {
  
  class Request {}
  class Response {}
  
  var sut: Endpoint<Request, Response>!
  var urlRequest: URLRequest!
  var urlResponseSubject: PassthroughSubject<(data: Data, response: URLResponse), Error>!
  var response: Response!
  
  var urlRequestFactoryFailure: Error?
  var responseValidatorFailure: Error?
  var responseDecoderFailure: Error?
  
  var didCreateURLRequestForRequests: [Request]!
  var didCreateURLResponsePublisherForURLRequests: [URLRequest]!
  var didValidate: [(Data, URLResponse)]!
  var didDecode: [(Data, URLResponse)]!
  
  var cancellables = Set<AnyCancellable>()
  
  override func setUp() {
    super.setUp()
    
    urlRequest = URLRequest(url: URL(fileURLWithPath: "test"))
    urlResponseSubject = PassthroughSubject()
    response = Response()
    
    didCreateURLRequestForRequests = []
    didCreateURLResponsePublisherForURLRequests = []
    didValidate = []
    didDecode = []
    
    sut = urlEndpoint(requestFactory: { request -> URLRequest in
      self.didCreateURLRequestForRequests.append(request)
      if let error = self.urlRequestFactoryFailure { throw error }
      return self.urlRequest
    }, publisherFactory: { urlRequest in
      self.didCreateURLResponsePublisherForURLRequests.append(urlRequest)
      return self.urlResponseSubject.eraseToAnyPublisher()
    }, responseValidator: { (data, response) in
      self.didValidate.append((data, response))
      if let error = self.responseValidatorFailure { throw error }
    }, responseDecoder: { (data, response) -> Response in
      self.didDecode.append((data, response))
      if let error = self.responseDecoderFailure { throw error }
      return self.response
    })
  }
  
  override func tearDown() {
    super.tearDown()
    
    sut = nil
    urlRequest = nil
    urlResponseSubject = nil
    response = nil
    urlRequestFactoryFailure = nil
    responseValidatorFailure = nil
    responseDecoderFailure = nil
    didCreateURLRequestForRequests = nil
    didCreateURLResponsePublisherForURLRequests = nil
    didValidate = nil
    didDecode = nil
    cancellables.removeAll()
  }
  
  func testHappyPath() {
    let request = Request()
    var didReceiveCompletion: Subscribers.Completion<Error>?
    var didReceiveValues: [Response] = []
    
    sut(request)
      .sink(receiveCompletion: { completion in
        didReceiveCompletion = completion
      }, receiveValue: { value in
        didReceiveValues.append(value)
      })
      .store(in: &cancellables)
    
    XCTAssertEqual(didCreateURLRequestForRequests.count, 1)
    XCTAssert(didCreateURLRequestForRequests.first === request)
    XCTAssertEqual(didCreateURLResponsePublisherForURLRequests, [urlRequest])
    
    let data = "Test".data(using: .utf8)!
    let urlResponse = URLResponse()
    urlResponseSubject.send((data, urlResponse))
    
    XCTAssertEqual(didValidate.count, 1)
    XCTAssertEqual(didValidate.first?.0, data)
    XCTAssertEqual(didValidate.first?.1, urlResponse)
    XCTAssertEqual(didDecode.count, 1)
    XCTAssertEqual(didDecode.first?.0, data)
    XCTAssertEqual(didDecode.first?.1, urlResponse)
    XCTAssertEqual(didReceiveValues.count, 1)
    XCTAssert(didReceiveValues.first === response)
    XCTAssertNil(didReceiveCompletion)
  }
  
  func testURLRequestCreationFailure() {
    urlRequestFactoryFailure = NSError(domain: "test", code: 1, userInfo: nil)
    
    let request = Request()
    var didReceiveCompletion: Subscribers.Completion<Error>?
    var didReceiveValues: [Response] = []
    
    sut(request)
      .sink(receiveCompletion: { completion in
        didReceiveCompletion = completion
      }, receiveValue: { value in
        didReceiveValues.append(value)
      })
      .store(in: &cancellables)
    
    XCTAssert(didCreateURLResponsePublisherForURLRequests.isEmpty)
    XCTAssert(didValidate.isEmpty)
    XCTAssert(didDecode.isEmpty)
    XCTAssert(didReceiveValues.isEmpty)
    if case .failure(let error) = didReceiveCompletion {
      XCTAssertEqual(error as NSError, urlRequestFactoryFailure as NSError?)
    } else {
      XCTFail()
    }
  }
  
  func testResponseValidationFailure() {
    responseValidatorFailure = NSError(domain: "test", code: 1, userInfo: nil)
    
    let request = Request()
    var didReceiveCompletion: Subscribers.Completion<Error>?
    var didReceiveValues: [Response] = []
    
    sut(request)
      .sink(receiveCompletion: { completion in
        didReceiveCompletion = completion
      }, receiveValue: { value in
        didReceiveValues.append(value)
      })
      .store(in: &cancellables)
    
    urlResponseSubject.send(("Test".data(using: .utf8)!, URLResponse()))
    
    XCTAssert(didDecode.isEmpty)
    XCTAssert(didReceiveValues.isEmpty)
    XCTAssertNotNil(didReceiveCompletion)
    if case .failure(let error) = didReceiveCompletion {
      XCTAssertEqual(error as NSError, responseValidatorFailure as NSError?)
    } else {
      XCTFail()
    }
  }
  
  func testResponseDecodingFailure() {
    responseDecoderFailure = NSError(domain: "test", code: 1, userInfo: nil)
    
    let request = Request()
    var didReceiveCompletion: Subscribers.Completion<Error>?
    var didReceiveValues: [Response] = []
    
    sut(request)
      .sink(receiveCompletion: { completion in
        didReceiveCompletion = completion
      }, receiveValue: { value in
        didReceiveValues.append(value)
      })
      .store(in: &cancellables)
    
    urlResponseSubject.send(("Test".data(using: .utf8)!, URLResponse()))
    
    XCTAssert(didReceiveValues.isEmpty)
    XCTAssertNotNil(didReceiveCompletion)
    if case .failure(let error) = didReceiveCompletion {
      XCTAssertEqual(error as NSError, responseDecoderFailure as NSError?)
    } else {
      XCTFail()
    }
  }

}
