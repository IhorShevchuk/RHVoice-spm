//
//  String.swift
//
//
//  Created by Ihor Shevchuk on 09.03.2024.
//

import Foundation

extension String {

    func toPointer() -> UnsafePointer<CChar>? {
        return withCString { pointer in
            return pointer
        }
    }

    func toUnsafePointer() -> UnsafePointer<CChar> {

        guard let pointer = utf8CString.withUnsafeBufferPointer({ $0.baseAddress }) else {
            return UnsafePointer<CChar>(bitPattern: 0)!
        }
        return pointer
    }

    init(char: UnsafePointer<CChar>?) {

        guard let char else {
            self.init()
            return
        }

        self.init(cString: char)
    }
}
