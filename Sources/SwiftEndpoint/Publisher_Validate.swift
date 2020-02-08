import Combine

public extension Publisher {
  func validate(_ validator: @escaping (Output) throws -> Void) -> AnyPublisher<Output, Error> {
    tryMap { value in
      try validator(value)
      return value
    }.eraseToAnyPublisher()
  }
}
