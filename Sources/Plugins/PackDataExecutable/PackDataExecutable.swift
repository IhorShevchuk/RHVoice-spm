//
//  PackDataPluginExecutable.swift
//  
//
//  Created by Ihor Shevchuk on 16.07.2023.
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

import Foundation

@main
struct PackDataExecutable {

    private enum PackDataError: Error {
        case runtimeError(String)
    }

    /// Input containing the data files
    private var input: String

    /// Directory containing the output files
    private var output: String

    /// list of languages that should copied")
    private var languages: String

    /// List of voices that should copied
    private var voices: String

    static func main() throws {
        let arguments = CommandLine.arguments
        var input: String?
        var output: String?
        var languages: String?
        var voices: String?

        for (index, argument) in arguments.enumerated() {
            switch argument {
            case "--input":
                input = arguments[index + 1]
            case "--output":
                output = arguments[index + 1]
            case "--languages":
                languages = arguments[index + 1]
            case "--voices":
                voices = arguments[index + 1]
            default:
                break
            }
        }

        guard let input,
              let output,
              let languages,
              let voices else {
            throw PackDataError.runtimeError("Not enough arguments!")
        }

        let executable = PackDataExecutable(input: input,
                                            output: output,
                                            languages: languages,
                                            voices: voices)

        try executable.run()
    }

    func run() throws {
        do {
            try FileManager.default.removeItem(atPath: output)
        } catch {
        }
        try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)

        try copy(type: "languages", folders: languages.components(separatedBy: ","))
        try copy(type: "voices", folders: voices.components(separatedBy: ","))
    }

    func copy(type: String, folders: [String]) throws {

        let baseInputPath = input + "/" + type
        let baseOutputPath = output + "/" + type

        do {
            try FileManager.default.removeItem(atPath: baseOutputPath)
        } catch {
        }

        try FileManager.default.createDirectory(atPath: baseOutputPath, withIntermediateDirectories: true)

        for folder in folders {
            let inputFolder = baseInputPath + "/" + folder
            let outputFolder = baseOutputPath + "/" + folder
            do {
                try FileManager.default.removeItem(atPath: outputFolder)
            } catch {
            }
            try FileManager.default.copyItem(atPath: inputFolder, toPath: outputFolder)

            if type == "voices" {
                do {
                    try FileManager.default.removeItem(atPath: outputFolder + "/16000")
                } catch {
                }
            }
        }
    }
}
