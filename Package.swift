// swift-tools-version: 5.7

//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

import PackageDescription
import Foundation

func boostHeaders() -> [CSetting] {
    let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
    let RHVoicePath = packageURL
        .appendingPathComponent("RHVoice")
    let boostRoot = RHVoicePath
        .appendingPathComponent("external")
        .appendingPathComponent("libs")
        .appendingPathComponent("boost")
        .appendingPathComponent("libs")

    let fileManager = FileManager()
    guard let folderEnumerator = fileManager.enumerator(at: boostRoot, includingPropertiesForKeys: nil) else {
        return []
    }

    folderEnumerator.skipDescendants()

    var result: [CSetting] = []
    for folder in folderEnumerator {
        guard let folderPath = folder as? URL else {
            continue
        }

        let includePath = folderPath.appendingPathComponent("include").path
        if fileManager.fileExists(atPath: includePath) {
            let path = includePath.replacingOccurrences(of: RHVoicePath.path + "/", with: "")
            result.append(.headerSearchPath(path))
        }
    }

    return result
}

let package = Package(
    name: "RHVoice",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "RHVoice",
            targets: ["RHVoice"]),
        .plugin(name: "PackDataPlugin", targets: [
            "PackDataPlugin"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "RHVoiceCore",
            dependencies: [
            ],
            path: "RHVoice/",
            exclude: [
                // Files that are not compiled because they are included into sources directly
                "src/core/unidata.cpp",
                "src/core/userdict_parser.c",
                "src/core/emoji_data.cpp",
                // Platform audio files that shouldn't be compiled for iOS and macOS(at least in scope of this package)
                "src/audio/libao.cpp",
                "src/audio/portaudio.cpp",
                "src/audio/pulse.cpp",
                // cmake files
                "src/core/CMakeLists.txt",
                "src/hts_engine/CMakeLists.txt",
                "src/audio/CMakeLists.txt",
                "src/lib/CMakeLists.txt",
                // Scons files
                "src/audio/SConscript",
                "src/core/SConscript",
                "src/hts_engine/SConscript",
                "src/lib/SConscript",
                "src/pkg/SConscript",
                // Not used on Apple platfroms since config path is set during runtime
                "src/core/config.h.in",
                // Not used on Apple platforms
                "src/core/userdict_parser.g"
            ],
            sources: [
                "src/core",
                "src/hts_engine",
                "src/lib",
                "src/audio"
            ],
            publicHeadersPath: "src/include/",
            cSettings: [
                .headerSearchPath("src/include/**"),
                .headerSearchPath("src/hts_engine"),
                .headerSearchPath("src/third-party/utf8"),
                .headerSearchPath("src/third-party/rapidxml"),
                .headerSearchPath("../Sources/Mock"),
                .define("RHVOICE"),
                .define("PACKAGE", to: "\"RHVoice\""),
                .define("DATA_PATH", to: "\"\""),
                .define("CONFIG_PATH", to: "\"\""),
                .define("ANDROID"),
                .define("TARGET_OS_IPHONE", .when(platforms: [.iOS])),
                .define("TARGET_OS_MAC", .when(platforms: [.macOS]))
            ] + boostHeaders()
        ),
        .target(name: "RHVoice",
                dependencies: [
                    .target(name: "RHVoiceCore")
                ],
                path: "Sources",
                sources: [
                    "CoreLib",
                    "RHVoice",
                    "Utils"
                ],
                publicHeadersPath: "RHVoice/PublicHeaders/",
                cSettings: [
                    .headerSearchPath("../RHVoice/src/third-party/utf8"),
                    .headerSearchPath("../RHVoice/src/third-party/rapidxml"),
                    .headerSearchPath("RHVoice/Logger"),
                    .headerSearchPath("RHVoice/PrivateHeaders"),
                    .headerSearchPath("Utils"),
                    .headerSearchPath("CoreLib"),
                    .headerSearchPath("Mock"),
                    .define("ANDROID"),
                    .define("TARGET_OS_IPHONE", .when(platforms: [.iOS])),
                    .define("TARGET_OS_MAC", .when(platforms: [.macOS]))
                ],
                linkerSettings: [
                    .linkedFramework("AVFAudio")
                ]
               ),
        /// Plugin to copy languages and voices data files
        .executableTarget(
            name: "PackDataExecutable",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/Plugins/PackDataExecutable"
        ),
        .plugin(name: "PackDataPlugin",
                capability: .buildTool(),
                dependencies: [
                    .target(name: "PackDataExecutable")
                ],
                path: "Sources/Plugins/PackData",
                sources: [
                    "PackDataPlugin.swift"
                ]
               )
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx11
)

func versionString(fileName: String) -> String {
    let defaultValue = "\"\""
    do {
        let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let input = packageURL.appendingPathComponent(fileName)
        let inputString = try String(contentsOf: input)
        guard let begin = inputString.range(of: "next_version=") else {
            return defaultValue
        }

        guard let end = inputString.range(of: "\n", range: begin.upperBound..<inputString.endIndex) else {
            return defaultValue
        }

        return String(inputString[begin.upperBound..<end.lowerBound])
    } catch {

    }
    return defaultValue
}

let version = versionString(fileName: "RHVoice/SConstruct")
package.targets.first?.cSettings?.append(.define("VERSION", to: "\(version)"))
