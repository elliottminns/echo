import PackageDescription

#if os(Linux)
let libuvURL = "https://github.com/elliottminns/libuv-linux.git"
#else
let libuvURL = "https://github.com/elliottminns/libuv-osx.git"
#endif

let package = Package(
    name: "Echo",
    dependencies: [
        .Package(url: libuvURL,
                 majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/http-parser.git",
                 majorVersion: 0)
    ]
)
