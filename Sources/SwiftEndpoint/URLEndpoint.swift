import Combine
import Foundation

public typealias URLResponsePublisher = AnyPublisher<(data: Data, response: URLResponse), Error>
public typealias URLResponsePublisherFactory = (URLRequest) -> URLResponsePublisher
public typealias URLRequestFactory<Request> = (Request) throws -> URLRequest
public typealias URLResponseDecoder<Response> = (Data, URLResponse) throws -> Response
public typealias URLResponseValidator = (Data, URLResponse) throws -> Void

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
  var urlResponsePublisherFactory: URLResponsePublisherFactory {
    return { request in
      self.dataTaskPublisher(for: request)
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }
  }
}
