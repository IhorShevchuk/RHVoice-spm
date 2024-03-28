//
//  PackDataPlugin.swift
//
//
//  Created by Ihor Shevchuk on 27.02.2023.
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

import PackagePlugin
import Foundation

struct JSONFormat: Decodable {
    let languages: [String]
    let voices: [String]
}

@main
struct PackDataPlugin: BuildToolPlugin {

    let config = "RHVoice.json"

    var packageRoot: String {
        let packageURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return packageURL.path
    }

    func output(baseOutput: Path) -> Path {
        return baseOutput.appending("RHVoiceData")
    }

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {

        let input = target.directory.appending(config)
        let output = output(baseOutput: context.pluginWorkDirectory)

        /// Workaround for https://github.com/apple/swift-package-manager/issues/6658
        /// You should build your package using Xcode in Release configuration without changing DerivedData folder
        let tool = context.pluginWorkDirectory.appending(["..",
                                                          "..",
                                                          "..",
                                                          "..",
                                                          "..",
                                                          "Build",
                                                          "Products",
                                                          "${CONFIGURATION}",
                                                          "PackDataExecutable"])
        return try commands(for: input,
                            and: output,
                            packTool: tool)
    }

    func commands(for input: Path, and output: Path, packTool: Path) throws -> [Command] {
        if !FileManager.default.fileExists(atPath: input.string) {
            return []
        }

        let inputURL = URL(fileURLWithPath: input.string)
        let jsonData = try Data(contentsOf: inputURL)
        let jsonInfo = try JSONDecoder().decode(JSONFormat.self, from: jsonData)

        let inputDataFolder = packageRoot + "/RHVoice/RHVoice/data"

        return [
            .buildCommand(
                displayName: "Pack Data",
                executable: packTool,
                arguments: [
                    "--input",
                    inputDataFolder,
                    "--output",
                    output,
                    "--languages",
                    jsonInfo.languages.joined(separator: ","),
                    "--voices",
                    jsonInfo.voices.joined(separator: ",")
                ],
                environment: [:],
                inputFiles: [input],
                outputFiles: [output]
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension PackDataPlugin: XcodeBuildToolPlugin {

    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {

        guard let input = context.xcodeProject.filePaths.first(where: { path in
            path.string.hasSuffix(config)
        }) else {
            return []
        }

        let output = output(baseOutput: context.pluginWorkDirectory)

        return try commands(for: input,
                            and: output,
                            packTool: try context.tool(named: "PackDataExecutable").path)
    }
}
#endif
