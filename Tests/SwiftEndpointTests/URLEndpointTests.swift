import Combine
import XCTest
@testable import SwiftEndpoint

final class URLEndpointTests: XCTestCase {
	
	class Request {}
	class Response {}
	class ResponseError: Error, Equatable {
		
		var id: Int
		init(id: Int) {
			self.id = id
		}
		static func == (
			lhs: URLEndpointTests.ResponseError,
			rhs: URLEndpointTests.ResponseError
		) -> Bool {
			lhs.id == rhs.id
		}
	}
	
	var sut: Endpoint<Request, Response, ResponseError>!
	var urlRequest: URLRequest!
	var urlResponseSubject: PassthroughSubject<(data: Data, response: URLResponse), URLError>!
	var response: Response!
	
	var urlRequestFactoryFailure: ResponseError?
	var responseValidatorFailure: ResponseError?
	var responseDecoderFailure: ResponseError?
	
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
		sut = .init(
			requestFactory: .init { request in
				self.didCreateURLRequestForRequests.append(request)
				if let error = self.urlRequestFactoryFailure {
					return .failure(error)
				}
				return .success(self.urlRequest)
			},
			responseFactory: .init { urlRequest in
				self.didCreateURLResponsePublisherForURLRequests.append(urlRequest)
				return self.urlResponseSubject.eraseToAnyPublisher()
			},
			urlErrorMapper: .init { urlError in
				fatalError()
			},
			responseValidator: .init { data, response in
				self.didValidate.append((data, response))
				if let error = self.responseValidatorFailure {
					return .failure(error)
				}
				return .success(())
			},
			responseDecoder: .init { data, response in
				self.didDecode.append((data, response))
				if let error = self.responseDecoderFailure {
					return .failure(error)
				}
				return .success(self.response)
			}
		)
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
		var didReceiveCompletion: Subscribers.Completion<ResponseError>?
		var didReceiveValues: [Response] = []
		
		sut.request(request)
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
		urlRequestFactoryFailure = ResponseError(id: 1)
		
		let request = Request()
		var didReceiveCompletion: Subscribers.Completion<ResponseError>?
		var didReceiveValues: [Response] = []
		
		sut.request(request)
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
			XCTAssertEqual(error, urlRequestFactoryFailure)
		} else {
			XCTFail()
		}
	}
	
	func testResponseValidationFailure() {
		responseValidatorFailure = ResponseError(id: 1)
		
		let request = Request()
		var didReceiveCompletion: Subscribers.Completion<ResponseError>?
		var didReceiveValues: [Response] = []
		
		sut.request(request)
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
			XCTAssertEqual(error, responseValidatorFailure)
		} else {
			XCTFail()
		}
	}
	
	func testResponseDecodingFailure() {
		responseDecoderFailure = ResponseError(id: 1)
		
		let request = Request()
		var didReceiveCompletion: Subscribers.Completion<ResponseError>?
		var didReceiveValues: [Response] = []
		
		sut.request(request)
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
			XCTAssertEqual(error, responseDecoderFailure)
		} else {
			XCTFail()
		}
	}
	
}
