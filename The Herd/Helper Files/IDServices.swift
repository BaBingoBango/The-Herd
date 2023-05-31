//
//  IDServices.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation

extension UUID {
    static func getTripleID() -> String {
        return UUID().uuidString + "-" + UUID().uuidString + "-" + UUID().uuidString
    }
}
