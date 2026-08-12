//
//  Format.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/9.
//

import UIKit

 func prettyJSONString(_ string: String?) -> String {

    guard
        let string = string,
        let data = string.data(using: .utf8),
        let object = try? JSONSerialization.jsonObject(with: data),
        let prettyData = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        )
    else {
        return string ?? ""
    }

    return String(data: prettyData, encoding: .utf8) ?? string
}

 func prettyJSON(_ object: Any) -> String {

    guard JSONSerialization.isValidJSONObject(object),
          let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
          )
    else {
        return "\(object)"
    }

    return String(data: data, encoding: .utf8) ?? "\(object)"
}
