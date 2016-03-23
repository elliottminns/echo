import PackageDescription

let package = Package(
    name: "Echo",
    dependencies: [
        .Package(url: "https://github.com/elliottminns/libuv-osx",
                 majorVersion: 0)
    ]
)
