//
//  PackDataPluginExecutable.swift
//  
//
//  Created by Ihor Shevchuk on 16.07.2023.
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

import Foundation
import ArgumentParser

@main
struct PackDataExecutable: ParsableCommand {

    @Option(help: "Input containing the data files")
    var input: String

    @Option(help: "Directory containing the output files")
    var output: String

    @Option(help: "list of languages that should copied")
    var languages: String

    @Option(help: "list of voices that should copied")
    var voices: String

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
