import PackageDescription

#if os(Linux)
let uvModule = "https://github.com/elliottminns/uv-module-linux.git"
#else
let uvModule = "https://github.com/elliottminns/uv-module.git"
#endif

let package = Package(
    name: "Echo",
    dependencies: [
        .Package(url: uvModule
                 majorVersion: 0)
    ]
)
