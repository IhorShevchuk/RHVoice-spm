//
//  RHVoiceLoggerImpl.swift
//
//
//  Created by Ihor Shevchuk on 12/29/2025.
//

import Foundation

final class RHVoiceLoggerImpl: RHVoiceLogger {
    func log(
        tag: String,
        level: RHVoiceLogLevel,
        message: String
    ) {
        print("[\(level)][\(tag)] \(message)")
    }
}
