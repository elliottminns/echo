import PackageDescription

#if os(Linux)
let libuvURL = "https://github.com/elliottminns/libuv-linux"
#else
let libuvURL = "https://github.com/elliottminns/libuv-osx"
#endif

let package = Package(
    name: "Echo",
    dependencies: [
        .Package(url: libuvURL,
                 majorVersion: 0)
    ]
)
