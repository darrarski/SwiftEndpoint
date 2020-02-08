import Combine

public typealias Endpoint<Request, Response> = (Request) -> AnyPublisher<Response, Error>
