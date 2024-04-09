// swift-tools-version: 5.9

//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

import PackageDescription
import Foundation

func boostHeadersPaths() -> [String] {
    let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
    let RHVoicePath = packageURL
        .appendingPathComponent("RHVoice")
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

    var result: [String] = []
    for folder in folderEnumerator {
        guard let folderPath = folder as? URL else {
            continue
        }

        let includePath = folderPath.appendingPathComponent("include").path
        if fileManager.fileExists(atPath: includePath) {
            let path = includePath.replacingOccurrences(of: RHVoicePath.path + "/", with: "")
            result.append(path)
        }
    }

    return result
}

func boostHeaders(prefix: String = "") -> [CSetting] {
    return boostHeadersPaths().map { path in
        return .headerSearchPath(prefix + path)
    }
}

func commonHeaderSearchPath(prefix: String = "") -> [CSetting] {
    let headerPaths = [
        "RHVoice/src/third-party/utf8",
        "RHVoice/src/third-party/rapidxml",
        "RHVoice/src/include"
    ]

    return headerPaths.map { path in
        return .headerSearchPath(prefix + path)
    }
}

func commonCSettings(prefix: String = "") -> [CSetting] {

    return [                    .define("ANDROID"),
                                .define("TARGET_OS_IPHONE", .when(platforms: [.iOS])),
                                .define("TARGET_OS_MAC", .when(platforms: [.macOS]))]
    + boostHeaders(prefix: prefix + "RHVoice/")
    + commonHeaderSearchPath(prefix: prefix)
}

let package = Package(
    name: "RHVoice",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "RHVoiceObjC",
            targets: ["RHVoiceObjC"]),
        .plugin(name: "PackDataPlugin", targets: [
            "PackDataPlugin"
        ]),
        .library(name: "RHVoiceSwift",
                 targets: ["RHVoiceSwift"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "RHVoice",
            dependencies: [
            ],
            path: "RHVoice",
            exclude: [
                // Files that are not compiled because they are included into sources directly
                "RHVoice/src/core/unidata.cpp",
                "RHVoice/src/core/userdict_parser.c",
                "RHVoice/src/core/emoji_data.cpp",
                // Platform audio files that shouldn't be compiled for iOS and macOS(at least in scope of this package)
                "RHVoice/src/audio/libao.cpp",
                "RHVoice/src/audio/portaudio.cpp",
                "RHVoice/src/audio/pulse.cpp",
                // cmake files
                "RHVoice/src/core/CMakeLists.txt",
                "RHVoice/src/hts_engine/CMakeLists.txt",
                "RHVoice/src/audio/CMakeLists.txt",
                "RHVoice/src/lib/CMakeLists.txt",
                // Scons files
                "RHVoice/src/audio/SConscript",
                "RHVoice/src/core/SConscript",
                "RHVoice/src/hts_engine/SConscript",
                "RHVoice/src/lib/SConscript",
                "RHVoice/src/pkg/SConscript",
                // Not used on Apple platfroms since config path is set during runtime
                "RHVoice/src/core/config.h.in",
                // Not used on Apple platforms
                "RHVoice/src/core/userdict_parser.g"
            ],
            sources: [
                "RHVoice/src/core",
                "RHVoice/src/hts_engine",
                "RHVoice/src/lib",
                "RHVoice/src/audio"
            ],
            cSettings: [
                .headerSearchPath("RHVoice/src/hts_engine"),
                .headerSearchPath("../Sources/Mock"),
                .define("RHVOICE"),
                .define("PACKAGE", to: "\"RHVoice\""),
                .define("DATA_PATH", to: "\"\""),
                .define("CONFIG_PATH", to: "\"\"")
            ]
            + commonCSettings()
        ),
        .target(name: "RHVoiceObjC",
                dependencies: [
                    .target(name: "RHVoice")
                ],
                path: "Sources/RHVoiceObjC",
                publicHeadersPath: "PublicHeaders/",
                cSettings: [
                    .headerSearchPath("Logger"),
                    .headerSearchPath("PrivateHeaders"),
                    .headerSearchPath("Utils"),
                    .headerSearchPath("CoreLib"),
                    .headerSearchPath("../Mock")
                ]
                + commonCSettings(prefix: "../../RHVoice/")
                ,
                linkerSettings: [
                    .linkedFramework("AVFAudio")
                ]
               ),
        .target(name: "RHVoiceSwift",
                dependencies: [
                    .target(name: "RHVoice"),
                    .target(name: "PlayerLib")
                ],
                path: "Sources/RHVoiceSwift",
                cSettings: ([
                    .headerSearchPath("../Mock")
                ]
                            + commonCSettings(prefix: "../../RHVoice/")
                ),
                swiftSettings: [
                    .interoperabilityMode(.Cxx)
                ]
               ),
        .target(name: "PlayerLib",
                dependencies: [
                    .target(name: "RHVoice")
                ],
                path: "Sources/PlayerLib",
                cSettings: ([
                    .headerSearchPath("../Mock")
                ]
                            + commonCSettings(prefix: "../../RHVoice/")
                )
               ),
        .executableTarget(
            name: "RHVoiceSwiftSample",
            dependencies: [
                .target(name: "RHVoiceSwift")
            ],
            path: "Sources/RHVoiceSwiftSample",
            cSettings: ([
                .headerSearchPath("../Mock")
            ]
                        + commonCSettings(prefix: "../../RHVoice/")
            ),
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        /// Plugin to copy languages and voices data files
        .executableTarget(
            name: "PackDataExecutable",
            dependencies: [
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
