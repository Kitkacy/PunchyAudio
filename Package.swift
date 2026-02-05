// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PunchyAudio",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PunchyAudio",
            targets: ["PunchyAudio"]),
    ],
    targets: [
        .executableTarget(
            name: "PunchyAudio",
            dependencies: [],
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/PunchyAudio/Info.plist"
                ])
            ]),
    ]
)
