# SwiftEndpoint

![Swift v5.1](https://img.shields.io/badge/swift-v5.1-orange.svg)
![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-✓-green.svg)

## Description

`Endpoint` is a function that transforms `Request` to `Response` publisher:
 
```swift
typealias Endpoint<Request, Response> = (Request) -> AnyPublisher<Response, Error>
```

`urlEndpoint` function creates an endpoint that uses [Foundation](https://developer.apple.com/documentation/foundation)'s networking:

```swift
func urlEndpoint<Request, Response>(
  requestFactory: (Request) throws -> URLRequest,
  publisherFactory: (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error>,
  responseValidator: (Data, URLResponse) throws -> Void,
  responseDecoder: (Data, URLResponse) throws -> Response
) -> Endpoint<Request, Response>
```

## Installation

SwiftEndpoint is compatible with [Swift Package Manager](https://swift.org/package-manager/). You can add it as a dependency to your [Xcode project](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) or [swift package](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#defining-dependencies).

## Development

Running tests:

```sh
swift test
```

Developing in [Xcode](https://developer.apple.com/xcode/):

```sh
swift package generate-xcodeproj
open -a SwiftEndpoint.xcodeproj
```

## License

Copyright © 2020 Dariusz Rybicki Darrarski

License: *TBD*
