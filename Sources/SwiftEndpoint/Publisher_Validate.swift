import Combine

public extension Publisher {
  /// Validate each emitted value using provided validator function
  /// - Parameter validator: function that accepts a value and optionally throws validation error
  /// - Returns: publisher that emitts validated values or fails with validation error
  func validate(_ validator: @escaping (Output) throws -> Void) -> AnyPublisher<Output, Error> {
    tryMap { value in
      try validator(value)
      return value
    }.eraseToAnyPublisher()
  }
}
