//
//  Chunker.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/21/23.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

