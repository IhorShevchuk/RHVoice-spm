//
//  RHVersionInfo.swift
//  
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation

public struct RHVersionInfo {
    internal(set) public var format: Int
    internal(set) public var revision: Int

    public var string: String {
        return "\(format).\(revision)"
    }
}
