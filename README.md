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

**`Endpoint`** is a generic function that transforms some `Request` into some `Response` publisher:
 
```swift
typealias Endpoint<Request, Response> = (Request) -> AnyPublisher<Response, Error>
```

### 🧩 Foundation URL networking

Set of helpers for building API clients based on the native [Foundation](https://developer.apple.com/documentation/foundation)'s networking.

**`urlEndpoint`** function creates an `Endpoint` that uses Foundation's networking:

```swift
func urlEndpoint<Request, Response>(
  requestFactory: @escaping URLRequestFactory<Request>,
  publisherFactory: @escaping URLResponsePublisherFactory,
  responseValidator: @escaping URLResponseValidator,
  responseDecoder: @escaping URLResponseDecoder<Response>
) -> Endpoint<Request, Response>
```

**`URLRequestFactory<Request>`** is a generic function that transforms some `Request` into `URLRequest`, optionally throwing an error:

```swift
typealias URLRequestFactory<Request> = (Request) throws -> URLRequest
```

**`URLResponsePublisherFactory`** is a function that transforms `URLRequest` into `URLResponsePublisher`:

```swift
typealias URLResponsePublisherFactory = (URLRequest) -> URLResponsePublisher
```

Convenience extension allows to use `URLSession` as a `URLResponsePublisherFactory`:

```swift
extension URLSession {
  var urlResponsePublisherFactory: URLResponsePublisherFactory { get }
}
```

**`URLResponsePublisher`** is a combine publisher emitting network responses or failing with networking error:

```swift
typealias URLResponsePublisher = AnyPublisher<(data: Data, response: URLResponse), Error>
```

**`URLResponseValidator`** is a function that validates response `Data` and `URLResponse`, optionally throwing validation error:

```swift
typealias URLResponseValidator = (Data, URLResponse) throws -> Void
```

**`URLResponseDecoder<Response>`** is a generic function that transforms response `Data` and `URLResponse` into some `Response`, optionally throwing decoding error:

```swift
typealias URLResponseDecoder<Response> = (Data, URLResponse) throws -> Response
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
