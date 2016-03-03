import PackageDescription

let package = Package(
    name: "Echo",
    dependencies: [
        .Package(url: "https://github.com/elliottminns/vaquita.git",
            majorVersion: 0)
    ]
)
