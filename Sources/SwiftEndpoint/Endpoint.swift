import Combine

/// Generic function that transforms some `Request` into some `Response` publisher
public typealias Endpoint<Request, Response> = (Request) -> AnyPublisher<Response, Error>
