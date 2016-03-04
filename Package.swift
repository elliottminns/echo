import PackageDescription

let package = Package(
    name: "Echo",
    dependencies: [
        .Package(url: "https://github.com/elliottminns/uv-module.git",
                 majorVersion: 0)
    ]
)
