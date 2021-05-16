# 📦 SwiftEndpoint

![Swift v5.1](https://img.shields.io/badge/swift-v5.1-orange.svg)
![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-✓-green.svg)
![platforms iOS macOS](https://img.shields.io/badge/platforms-iOS%20macOS-blue.svg)

**SwiftEndpoint** is a lightweight library providing higher level of abstraction for implementing networking in iOS and macOS applications.

## 🛠 Tech stack

- [Swift](https://swift.org/) 5.1
- [Xcode](https://developer.apple.com/xcode/) 11.3.1
- [iOS](https://www.apple.com/pl/ios/) 13.0
- [macOS](https://www.apple.com/pl/macos/) 10.15

## 📝 Description

**`Endpoint`** is a generic struct that creates transformation pipline that takes some `Request` and turn it into some `Response` publisher:
 
```swift
public struct Endpoint<Request, Response, Failure: Error> {
	public var request: (Request) -> AnyPublisher<Response, Failure>
}
```

**`Endpoint`** initializer creates an `Endpoint` that uses some helpers to perform network request:

```swift
public extension Endpoint {
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
				.validate(responseValidator.run)
				.flatMap {
					responseDecoder.run($0)
						.publisher
				}
				.eraseToAnyPublisher()
		}
	}
}
```

### 🧩 Foundation URL networking

Set of helpers for building API clients based on the native [Foundation](https://developer.apple.com/documentation/foundation)'s networking.

**`URLRequestFactory<Request, Failure: Error>`** is a generic struct that transforms some `Request` into `URLRequest`, or returns generic `Error`:

```swift
public struct URLRequestFactory<Request, Failure: Error> {
	var create: (Request) -> Result<URLRequest, Failure>
}
```

**`URLResponseFactory<Failure: Error>`** is a generic struct that performs `URLRequest` and returns erased `URLSession.DataTaskPublisher`:

```swift
public struct URLResponseFactory<Failure: Error> {
	var create: (URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
	
	public init(
		create: @escaping (URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
	) {
		self.create = create
	}
}
```

**`URLErrorMapper<Failure: Error>`** is a struct that maps `URLError` into generic `Failure`:

```swift
public struct URLErrorMapper<Failure: Error> {
	var transform: (URLError) -> Failure
	
	public init(
		transform: @escaping (URLError) -> Failure
	) {
		self.transform = transform
	}
}
```

**`URLResponseHandler<Response, Failure: Error>`** is a struct that handles `URLSession.DataTaskPublisher.Output`. It's used for both: validating the request AND decoding the request. It returns generic `Failure`

```swift
public struct URLResponseHandler<Response, Failure: Error> {
	var run: (URLSession.DataTaskPublisher.Output) -> Result<Response, Failure>
	
	public init(
		run: @escaping (URLSession.DataTaskPublisher.Output) -> Result<Response, Failure>
	) {
		self.run = run
	}
}
```

## 🧰 Installation

**SwiftEndpoint** is compatible with [Swift Package Manager](https://swift.org/package-manager/). You can add it as a dependency to your [Xcode project](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) or [swift package](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#defining-dependencies).

## 🛠 Development

Running tests:

```sh
swift test
```

Developing in [Xcode](https://developer.apple.com/xcode/):

```sh
swift package generate-xcodeproj
open -a SwiftEndpoint.xcodeproj
```

## ☕️ Do you like the project?

<a href="https://www.buymeacoffee.com/darrarski" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60" width="217" style="height: 60px !important;width: 217px !important;" ></a>

## 📄 License

Copyright © 2020 Dariusz Rybicki Darrarski

License: [GNU GPLv3](LICENSE)
