//
//  FHXJSONNode.swift
//  DebugCenter
//
//  Created by imac on 2026/9/5.
//

import Foundation

// MARK: - JSON Value

enum FHXJSONValue {

    case dictionary
    case array
    case string(String)
    case integer(Int)
    case double(Double)
    case bool(Bool)
    case null

    var isContainer: Bool {

        switch self {
        case .dictionary, .array:
            return true

        default:
            return false
        }
    }

    var openingSymbol: String {

        switch self {
        case .dictionary:
            return "{"

        case .array:
            return "["

        default:
            return ""
        }
    }

    var closingSymbol: String {

        switch self {
        case .dictionary:
            return "}"

        case .array:
            return "]"

        default:
            return ""
        }
    }
}

// MARK: - JSON Node

final class FHXJSONNode {

    let key: String

    let value: FHXJSONValue

    weak var parent: FHXJSONNode?

    var children: [FHXJSONNode] = []

    var isExpanded: Bool = false

    init(
        key: String,
        value: FHXJSONValue,
        parent: FHXJSONNode? = nil
    ) {

        self.key = key
        self.value = value
        self.parent = parent
    }

    var isContainer: Bool {
        value.isContainer
    }

    var depth: Int {

        var depth = 0

        var current = parent

        while current != nil {

            depth += 1

            current = current?.parent
        }

        return depth
    }
}
