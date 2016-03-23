import PackageDescription

#if os(Linux)
let libuvURL = "https://github.com/elliottminns/libuv-osx"
#else
let libuvURL = "https://github.com/elliottminns/libuv-linux"
#endif

let package = Package(
    name: "Echo",
    dependencies: [
        .Package(url: libuvURL,
                 majorVersion: 0)
    ]
)
