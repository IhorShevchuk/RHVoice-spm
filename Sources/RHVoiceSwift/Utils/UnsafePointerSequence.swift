//
//  UnsafePointerSequence.swift
//
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation

struct UnsafePointerSequence<T>: Sequence {
    private let start: UnsafePointer<T>
    private let count: Int

    init(start: UnsafePointer<T>, count: Int) {
        self.start = start
        self.count = count
    }

    func makeIterator() -> UnsafePointerIterator<T> {
        return UnsafePointerIterator(start: start, count: count)
    }
}

struct UnsafePointerIterator<T>: IteratorProtocol {
    private var current: UnsafePointer<T>
    private let end: UnsafePointer<T>

    init(start: UnsafePointer<T>, count: Int) {
        self.current = start
        self.end = start + count
    }

    mutating func next() -> UnsafePointer<T>? {
        guard current != end else {
            return nil
        }
        defer { current = current.successor() }
        return current
    }
}
