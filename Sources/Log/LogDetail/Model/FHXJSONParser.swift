//
//  FHXJSONParser.swift
//  DebugCenter
//
//  Created by imac on 2026/9/5.
//

import Foundation

final class FHXJSONParser {

    private init() {}

    // MARK: - Parse Network Log

    static func parseNetworkLog(
        _ message: String
    ) -> FHXNetworkLogInfo {

        let method = value(
            after: "Method :",
            in: message
        )

        let url = value(
            after: "URL :",
            in: message
        )

        let statusCode = value(
            after: "StatusCode :",
            in: message
        )

        let costTime = value(
            after: "CostTime :",
            in: message
        )

        let error = value(
            after: "Error :",
            in: message
        )

        let headers = block(
            from: "Headers :",
            to: "Parameters :",
            in: message
        )

        let parameters = block(
            from: "Parameters :",
            to: "Response :",
            in: message
        )

        let response = block(
            from: "Response :",
            to: nil,
            in: message
        )

        let responseJSON =
            parseJSON(
                from: response
            )

        return FHXNetworkLogInfo(
            method: method,
            url: url,
            statusCode: statusCode,
            costTime: costTime,
            error: error,
            headers: headers,
            parameters: parameters,
            response: response,
            responseNode: responseJSON
        )
    }

    // MARK: - JSON

    private static func parseJSON(
        from text: String
    ) -> FHXJSONNode? {

        guard
            let jsonText = extractJSON(
                from: text
            ),
            let data = jsonText.data(
                using: .utf8
            )
        else {
            return nil
        }

        guard
            let object = try? JSONSerialization.jsonObject(
                with: data,
                options: [.fragmentsAllowed]
            )
        else {
            return nil
        }

        return makeNode(
            key: "root",
            object: object,
            parent: nil
        )
    }

    // MARK: - Extract JSON

    private static func extractJSON(
        from text: String
    ) -> String? {

        guard
            let startIndex = text.firstIndex(
                where: {
                    $0 == "{" || $0 == "["
                }
            )
        else {
            return nil
        }

        return String(
            text[startIndex...]
        )
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    // MARK: - Make Node

    private static func makeNode(
        key: String,
        object: Any,
        parent: FHXJSONNode?
    ) -> FHXJSONNode? {

        // Dictionary

        if let dictionary =
            object as? [String: Any] {

            let node = FHXJSONNode(
                key: key,
                value: .dictionary,
                parent: parent
            )

            // Dictionary 顺序固定，避免每次显示顺序变化
            let sortedKeys =
                dictionary.keys.sorted()

            for childKey in sortedKeys {

                guard
                    let childObject =
                        dictionary[childKey]
                else {
                    continue
                }

                if let childNode =
                    makeNode(
                        key: childKey,
                        object: childObject,
                        parent: node
                    ) {

                    node.children.append(
                        childNode
                    )
                }
            }

            return node
        }

        // Array

        if let array =
            object as? [Any] {

            let node = FHXJSONNode(
                key: key,
                value: .array,
                parent: parent
            )

            for (index, childObject)
                in array.enumerated() {

                if let childNode =
                    makeNode(
                        key: "[\(index)]",
                        object: childObject,
                        parent: node
                    ) {

                    node.children.append(
                        childNode
                    )
                }
            }

            return node
        }

        // String

        if let string =
            object as? String {

            return FHXJSONNode(
                key: key,
                value: .string(string),
                parent: parent
            )
        }

        // Number / Bool

        if let number =
            object as? NSNumber {

            if CFGetTypeID(number)
                == CFBooleanGetTypeID() {

                return FHXJSONNode(
                    key: key,
                    value: .bool(
                        number.boolValue
                    ),
                    parent: parent
                )
            }

            let doubleValue =
                number.doubleValue

            if doubleValue.rounded()
                == doubleValue {

                return FHXJSONNode(
                    key: key,
                    value: .integer(
                        number.intValue
                    ),
                    parent: parent
                )
            }

            return FHXJSONNode(
                key: key,
                value: .double(
                    doubleValue
                ),
                parent: parent
            )
        }

        // Null

        if object is NSNull {

            return FHXJSONNode(
                key: key,
                value: .null,
                parent: parent
            )
        }

        return nil
    }

    // MARK: - Single Value

    private static func value(
        after key: String,
        in text: String
    ) -> String {

        guard
            let range = text.range(
                of: key
            )
        else {
            return ""
        }

        let start =
            range.upperBound

        let remaining =
            text[start...]

        guard
            let lineEnd =
                remaining.firstIndex(
                    of: "\n"
                )
        else {
            return remaining
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
        }

        return String(
            remaining[..<lineEnd]
        )
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    // MARK: - Block

    private static func block(
        from startKey: String,
        to endKey: String?,
        in text: String
    ) -> String {

        guard
            let startRange =
                text.range(of: startKey)
        else {
            return ""
        }

        let start =
            startRange.upperBound

        let remaining =
            text[start...]

        if let endKey {

            guard
                let endRange =
                    remaining.range(of: endKey)
            else {

                return String(
                    remaining
                )
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }

            return String(
                remaining[..<endRange.lowerBound]
            )
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        }

        return String(
            remaining
        )
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
}

// MARK: - Network Log Info

struct FHXNetworkLogInfo {

    let method: String

    let url: String

    let statusCode: String

    let costTime: String

    let error: String

    let headers: String

    let parameters: String

    let response: String

    let responseNode: FHXJSONNode?
}
