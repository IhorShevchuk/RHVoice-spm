// swift-tools-version: 5.7

//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

import PackageDescription
import Foundation

let package = Package(
    name: "RHVoice",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
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
        /// This is a forked repo of https://github.com/GigaBitcoin/Boost.swift
        .package(url: "https://github.com/IhorShevchuk/Boost.swift.git", .upToNextMajor(from: "1.80.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "RHVoiceCore",
            dependencies: [
                .product(name: "algorithm", package: "Boost.swift"),
                .product(name: "array", package: "Boost.swift"),
                .product(name: "assert", package: "Boost.swift"),
                .product(name: "bind", package: "Boost.swift"),
                .product(name: "concept_check", package: "Boost.swift"),
                .product(name: "config", package: "Boost.swift"),
                .product(name: "container", package: "Boost.swift"),
                .product(name: "container_hash", package: "Boost.swift"),
                .product(name: "core", package: "Boost.swift"),
                .product(name: "date_time", package: "Boost.swift"),
                .product(name: "detail", package: "Boost.swift"),
                .product(name: "foreach", package: "Boost.swift"),
                .product(name: "function", package: "Boost.swift"),
                .product(name: "integer", package: "Boost.swift"),
                .product(name: "io", package: "Boost.swift"),
                .product(name: "iterator", package: "Boost.swift"),
                .product(name: "lexical_cast", package: "Boost.swift"),
                .product(name: "move", package: "Boost.swift"),
                .product(name: "mpl", package: "Boost.swift"),
                .product(name: "multi_index", package: "Boost.swift"),
                .product(name: "numeric_conversion", package: "Boost.swift"),
                .product(name: "optional", package: "Boost.swift"),
                .product(name: "preprocessor", package: "Boost.swift"),
                .product(name: "range", package: "Boost.swift"),
                .product(name: "serialization", package: "Boost.swift"),
                .product(name: "signals2", package: "Boost.swift"),
                .product(name: "smart_ptr", package: "Boost.swift"),
                .product(name: "static_assert", package: "Boost.swift"),
                .product(name: "throw_exception", package: "Boost.swift"),
                .product(name: "tokenizer", package: "Boost.swift"),
                .product(name: "tuple", package: "Boost.swift"),
                .product(name: "type_index", package: "Boost.swift"),
                .product(name: "type_traits", package: "Boost.swift"),
                .product(name: "utility", package: "Boost.swift"),
                .product(name: "variant", package: "Boost.swift")
            ],
            path: "RHVoice/src/",
            exclude: [
                // Files that are not compiled because they are included into sources directly
                "core/unidata.cpp",
                "core/userdict_parser.c",
                "core/emoji_data.cpp",
                // Platform audio files that shouldn't be compiled for iOS and macOS(at least in scope of this package)
                "audio/libao.cpp",
                "audio/portaudio.cpp",
                "audio/pulse.cpp",
                // cmake files
                "core/CMakeLists.txt",
                "hts_engine/CMakeLists.txt",
                "audio/CMakeLists.txt",
                "lib/CMakeLists.txt",
                // Scons files
                "audio/SConscript",
                "core/SConscript",
                "hts_engine/SConscript",
                "lib/SConscript",
                "pkg/SConscript",
                // Not used on Apple platfroms since config path is set during runtime
                "core/config.h.in",
                // Not used on Apple platforms
                "core/userdict_parser.g"
            ],
            sources: [
                "core",
                "hts_engine",
                "lib",
                "audio"
            ],
            publicHeadersPath: "include/",
            cSettings: [
                .headerSearchPath("include/**"),
                .headerSearchPath("hts_engine"),
                .headerSearchPath("third-party/utf8"),
                .headerSearchPath("third-party/rapidxml"),
                .headerSearchPath("../../Sources/Mock"),
                .define("RHVOICE"),
                .define("PACKAGE", to: "\"RHVoice\""),
                .define("DATA_PATH", to: "\"\""),
                .define("CONFIG_PATH", to: "\"\""),
                .define("ANDROID"),
                .define("TARGET_OS_IPHONE", .when(platforms: [.iOS])),
                .define("TARGET_OS_MAC", .when(platforms: [.macOS]))
            ]
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
