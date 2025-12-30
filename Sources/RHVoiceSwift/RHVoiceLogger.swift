//
//  RHVoiceLogger.swift
//
//
//  Created by Ihor Shevchuk on 12/29/2025.
//

import CxxStdlib
import Foundation
import RHVoice
import RHVoiceCpp

public enum RHVoiceLogLevel: Int32, Sendable {
    case trace
    case debug
    case info
    case warning
    case error
}

public protocol RHVoiceLogger {
    func log(tag: String, level: RHVoiceLogLevel, message: String)
}

final class LoggerBox {
    let logger: RHVoiceLogger
    init(_ logger: RHVoiceLogger) {
        self.logger = logger
    }
}

let logThunk:
    @convention(c) (
        UnsafeMutableRawPointer?,
        UnsafePointer<CChar>?,
        Int32,
        UnsafePointer<CChar>?
    ) -> Void = { ctx, tag, levelRaw, msg in
        guard
            let ctx,
            let tag,
            let msg,
            let level = RHVoiceLogLevel(rawValue: levelRaw)
        else { return }

        let box = Unmanaged<LoggerBox>
            .fromOpaque(ctx)
            .takeUnretainedValue()

        box.logger.log(
            tag: String(cString: tag),
            level: level,
            message: String(cString: msg)
        )
    }

let destroyLogThunk:
    @convention(c) (
        UnsafeMutableRawPointer?
    ) -> Void = { ctx in
        guard let ctx else { return }
        Unmanaged<LoggerBox>
            .fromOpaque(ctx)
            .release()
    }
