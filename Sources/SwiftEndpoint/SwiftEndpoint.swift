import Combine
import Foundation

/// Generic struct that wraps create function
/// - Parameter create: takes function that takes `Request` and returns either `URLRequest` or fails with generic`Failure`
public struct URLRequestFactory<Request, Failure: Error> {
	var create: (Request) -> Result<URLRequest, Failure>
	
	public init(
		create: @escaping (Request) -> Result<URLRequest, Failure>
	) {
		self.create = create
	}
}

/// Performs `URLRequest` and returns the `Foundation` result
/// - Parameter create: takes function that performs `URLRequest` and returns type erased `URLSession.DataTaskPublisher`
public struct URLResponseFactory<Failure: Error> {
	var create: (URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
	
	public init(
		create: @escaping (URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
	) {
		self.create = create
	}
}

/// Generic struct that wraps transform function
/// - Parameter transform: takes function that transforms `URLError` into gemeric `Failure`
public struct URLErrorMapper<Failure: Error> {
	var transform: (URLError) -> Failure
	
	public init(
		transform: @escaping (URLError) -> Failure
	) {
		self.transform = transform
	}
}

/// Generic struct that wraps transform function
/// - Parameter transform: takes function that transforms `URLSession.DataTaskPublisher.Output` into gemeric `Result<Response, Failure>`
public struct URLResponseHandler<Response, Failure: Error> {
	var transform: (URLSession.DataTaskPublisher.Output) -> Result<Response, Failure>
	
	public init(
		transform: @escaping (URLSession.DataTaskPublisher.Output) -> Result<Response, Failure>
	) {
		self.transform = transform
	}
}

/// Generic struct that wraps request function
/// It creates Pipeline for the requests
/// Individual components that are passed into the initializer might be easily reused and composed.
/// The endpoint usually describes single request
/// You can extend the enpodint with constrained generic types to create concrete implementations.
public struct Endpoint<Request, Response, Failure: Error> {
	public var request: (Request) -> AnyPublisher<Response, Failure>
}

public extension Endpoint {
	/// Initializer that takes structs that handle each state of URLRequest handling.
	init(
		requestFactory: URLRequestFactory<Request, Failure>,
		responseFactory: URLResponseFactory<Failure>,
		urlErrorMapper: URLErrorMapper<Failure>,
		responseValidator: URLResponseHandler<Void, Failure>,
		responseDecoder: URLResponseHandler<Response, Failure>
	) {
		request = { request in
			requestFactory.create(request)
				.publisher
				.flatMap {
					responseFactory.create($0)
						.mapError(urlErrorMapper.transform)
				}
				.validate(responseValidator.transform)
				.flatMap {
					responseDecoder.transform($0)
						.publisher
				}
				.eraseToAnyPublisher()
		}
	}
}




