import Combine
import Foundation

/// Combine publisher emitting network responses or failing with networking error
public typealias URLResponsePublisher = AnyPublisher<(data: Data, response: URLResponse), Error>

/// Function that transforms `URLRequest` into `URLResponsePublisher`
public typealias URLResponsePublisherFactory = (URLRequest) -> URLResponsePublisher

/// Generic function that transforms some `Request` into `URLRequest`,
/// optionally throwing an error
public typealias URLRequestFactory<Request> = (Request) throws -> URLRequest

/// Generic function that transforms response `Data` and `URLResponse` into some `Response`,
/// optionally throwing decoding error
public typealias URLResponseDecoder<Response> = (Data, URLResponse) throws -> Response

/// Function that validates response `Data` and `URLResponse`,
/// optionally throwing validation error
public typealias URLResponseValidator = (Data, URLResponse) throws -> Void

/// Creates an `Endpoint` using Foundation networking
/// - Parameters:
///   - createURLRequest: URL request factory
///   - createURLResponsePublisher: URL response publisher factory
///   - validateURLResponse: URL response validator
///   - decodeURLResponse: URL response decoder
/// - Returns: Endpoint
public func urlEndpoint<Request, Response>(
  requestFactory createURLRequest: @escaping URLRequestFactory<Request>,
  publisherFactory createURLResponsePublisher: @escaping URLResponsePublisherFactory,
  responseValidator validateURLResponse: @escaping URLResponseValidator,
  responseDecoder decodeURLResponse: @escaping URLResponseDecoder<Response>
) -> Endpoint<Request, Response> {
  { request in
    Just(request)
      .tryMap(createURLRequest)
      .flatMap(createURLResponsePublisher)
      .validate(validateURLResponse)
      .tryMap(decodeURLResponse)
      .eraseToAnyPublisher()
  }
}

public extension URLSession {
  /// Returns URLResponsePublisherFactory powered by URLSession
  var urlResponsePublisherFactory: URLResponsePublisherFactory {
    return { request in
      self.dataTaskPublisher(for: request)
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }
  }
}
