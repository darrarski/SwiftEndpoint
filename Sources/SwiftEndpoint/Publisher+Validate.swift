import Combine

extension Publisher {
	/// Validate each emitted value using provided validator function
	/// - Parameter validator: function that accepts a value and optionally throws validation error
	/// - Returns: publisher that emitts validated values or fails with validation error
	func validate(
		_ validator: @escaping (Output) -> Result<Void, Failure>
	) -> AnyPublisher<Output, Failure> {
		flatMap { value in
			validator(value)
				.map { _ in value }
				.publisher
		}
		.eraseToAnyPublisher()
	}
}
